use bb8::Pool;
use bb8_redis::{redis::AsyncCommands, RedisConnectionManager};
use reqwest::Client;
use serde::Deserialize;
use solana_sdk::pubkey::Pubkey;
use std::str::FromStr;

/// SPL Token program ID (standard token, not Token-2022).
const SPL_TOKEN_PROGRAM_ID: &str = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA";
/// Associated Token Account program ID.
const SPL_ATA_PROGRAM_ID: &str = "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJe8zdh";

/// Derives the Associated Token Account (ATA) address for a given wallet and mint.
///
/// ATA seeds: `[wallet, spl_token_program, mint]` under the ATA program.
/// This replicates `spl_associated_token_account::get_associated_token_address`
/// without importing the crate (which has transitive dependency conflicts).
fn get_ata(wallet: &Pubkey, mint: &Pubkey) -> Pubkey {
    let token_program: Pubkey = SPL_TOKEN_PROGRAM_ID.parse().expect("static constant");
    let ata_program: Pubkey   = SPL_ATA_PROGRAM_ID.parse().expect("static constant");
    let (ata, _) = Pubkey::find_program_address(
        &[wallet.as_ref(), token_program.as_ref(), mint.as_ref()],
        &ata_program,
    );
    ata
}

use crate::entities::config::SolanaConfig;

const JUPITER_PRICE_URL: &str = "https://api.jup.ag/price/v2";
const REDIS_KEY_PRICE: &str = "roex:price";
const REDIS_KEY_BALANCE_PREFIX: &str = "roex:balance:";

#[derive(Deserialize)]
struct JupiterTokenPrice {
    price: String,
}

#[derive(Deserialize)]
struct JupiterPriceResponse {
    data: std::collections::HashMap<String, JupiterTokenPrice>,
}

/// Result of checking whether a wallet qualifies for meditation access.
pub enum AccessResult {
    /// Wallet holds enough ROEX — access granted.
    Granted,
    /// Wallet balance is below the required threshold.
    Denied {
        /// ROEX token units required at the current price (6 decimals, ui amount).
        required_roex: f64,
        /// ROEX/USD price used for the calculation.
        price_usd: f64,
    },
    /// Input is malformed (invalid pubkey, etc.) — return 400, not 402.
    InvalidInput(String),
}

/// Returns the current ROEX/USD price.
///
/// - Checks Redis cache first (TTL = `config.price_cache_ttl`).
/// - On cache miss, fetches from the Jupiter Price API v2.
/// - On Jupiter failure, returns `config.roex_price_fallback` and logs a warning.
pub async fn get_roex_price_usd(
    config: &SolanaConfig,
    pool: &Pool<RedisConnectionManager>,
    client: &Client,
) -> f64 {
    // 1. Cache hit
    if let Ok(mut conn) = pool.get().await {
        if let Ok(cached) = conn.get::<_, f64>(REDIS_KEY_PRICE).await {
            log::debug!("roex price cache hit: {}", cached);
            return cached;
        }
    }

    // 2. Jupiter Price API
    match fetch_jupiter_price(config, client).await {
        Some(price) => {
            log::info!("roex price from jupiter: {}", price);
            if let Ok(mut conn) = pool.get().await {
                let _ = conn
                    .set_ex::<_, f64, ()>(REDIS_KEY_PRICE, price, config.price_cache_ttl)
                    .await;
            }
            price
        }
        None => {
            log::warn!(
                "jupiter price unavailable, using fallback {}",
                config.roex_price_fallback
            );
            config.roex_price_fallback
        }
    }
}

async fn fetch_jupiter_price(config: &SolanaConfig, client: &Client) -> Option<f64> {
    let url = format!("{}?ids={}", JUPITER_PRICE_URL, config.roex_mint);
    let resp = client.get(&url).send().await.ok()?;
    let data: JupiterPriceResponse = resp.json().await.ok()?;
    let price_str = data.data.get(&config.roex_mint)?.price.clone();
    price_str.parse::<f64>().ok()
}

/// Checks whether `wallet_str` holds enough ROEX for meditation access.
///
/// Flow:
/// 1. Validate pubkey.
/// 2. Derive Associated Token Account (ATA) for the ROEX mint.
/// 3. Check Redis cache for a recent balance.
/// 4. On cache miss, query Solana RPC via `getTokenAccountBalance` JSON-RPC.
/// 5. Compare balance against `tier_meditation_usd / current_price`.
///
/// **Fail-open policy**: if the Solana RPC is temporarily unreachable,
/// access is granted and a warning is logged to avoid blocking paying users.
pub async fn check_meditation_access(
    config: &SolanaConfig,
    pool: &Pool<RedisConnectionManager>,
    client: &Client,
    wallet_str: &str,
) -> AccessResult {
    // Validate wallet pubkey
    let wallet = match Pubkey::from_str(wallet_str) {
        Ok(pk) => pk,
        Err(_) => return AccessResult::InvalidInput(format!("invalid wallet pubkey: {}", wallet_str)),
    };

    // Validate mint (config error — treat as invalid input so it's visible)
    let mint = match Pubkey::from_str(&config.roex_mint) {
        Ok(pk) => pk,
        Err(_) => {
            return AccessResult::InvalidInput(
                "roex_mint in server config is not a valid pubkey".to_string(),
            )
        }
    };

    // Derive Associated Token Account
    let ata = get_ata(&wallet, &mint);

    // Check Redis cache
    let cache_key = format!("{}{}", REDIS_KEY_BALANCE_PREFIX, wallet_str);
    let cached_balance: Option<f64> = if let Ok(mut conn) = pool.get().await {
        conn.get::<_, f64>(&cache_key).await.ok()
    } else {
        None
    };

    let balance = match cached_balance {
        Some(b) => {
            log::debug!("roex balance cache hit for {}: {}", wallet_str, b);
            b
        }
        None => {
            match fetch_ata_ui_balance(config, client, &ata.to_string()).await {
                Ok(b) => {
                    log::debug!("roex balance from rpc for {}: {}", wallet_str, b);
                    if let Ok(mut conn) = pool.get().await {
                        let _ = conn
                            .set_ex::<_, f64, ()>(&cache_key, b, config.balance_cache_ttl)
                            .await;
                    }
                    b
                }
                Err(e) => {
                    // Fail-open: RPC is down, don't block legitimate users.
                    log::warn!("rpc balance check failed for {} — granting access: {}", wallet_str, e);
                    return AccessResult::Granted;
                }
            }
        }
    };

    let price_usd = get_roex_price_usd(config, pool, client).await;
    let required_roex = config.tier_meditation_usd / price_usd;

    log::debug!(
        "access check: balance={} required={} (tier={}$ price={}$)",
        balance, required_roex, config.tier_meditation_usd, price_usd
    );

    if balance >= required_roex {
        AccessResult::Granted
    } else {
        AccessResult::Denied { required_roex, price_usd }
    }
}

/// Calls `getTokenAccountBalance` on the Solana RPC endpoint.
///
/// Returns `0.0` when the ATA doesn't exist (the account has never held the token).
/// Returns an `Err` only on network/parse failures so callers can decide whether
/// to fail-open or fail-closed.
async fn fetch_ata_ui_balance(
    config: &SolanaConfig,
    client: &Client,
    ata: &str,
) -> Result<f64, String> {
    let body = serde_json::json!({
        "jsonrpc": "2.0",
        "id":      1,
        "method":  "getTokenAccountBalance",
        "params":  [ata]
    });

    let resp = client
        .post(&config.rpc_url)
        .json(&body)
        .send()
        .await
        .map_err(|e| e.to_string())?;

    let json: serde_json::Value = resp.json().await.map_err(|e| e.to_string())?;

    // RPC-level error (e.g. account not found) → treat as 0 balance
    if json["error"].is_object() {
        log::debug!("getTokenAccountBalance rpc error for {}: {}", ata, json["error"]);
        return Ok(0.0);
    }

    Ok(json["result"]["value"]["uiAmount"].as_f64().unwrap_or(0.0))
}
