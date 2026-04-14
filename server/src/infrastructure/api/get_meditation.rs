use axum::{extract::State, http::HeaderMap};

use crate::{
    entities::meditation_script::MeditationScript,
    service::solana::{check_meditation_access, AccessResult},
};
use super::common::{api_error::ApiError, api_result::{auto_json, ApiResult}};
use super::requests::meditation_script_request::MeditationScriptRequest;
use super::api_state::ApiState;
use super::HEADER_X_WALLET_PUBKEY;

pub async fn get_meditation<'a>(
    State(state): State<ApiState>,
    headers: HeaderMap,
    data: MeditationScriptRequest,
) -> Result<ApiResult<MeditationScript>, ApiError<'a>> {
    log::debug!("--> in the get_meditation:{:?}", data);

    // ROEX gate — skipped when roex_mint is not yet configured (empty string).
    let solana_config = state.config.lock().unwrap().app_config.solana.clone();
    if !solana_config.roex_mint.is_empty() {
        let wallet = headers
            .get(HEADER_X_WALLET_PUBKEY)
            .and_then(|v| v.to_str().ok());

        match wallet {
            None => {
                // No wallet header — inform Flutter what it needs to provide.
                let price_usd = solana_config.roex_price_fallback;
                let required_roex = solana_config.tier_meditation_usd / price_usd;
                return Err(ApiError::PaymentRequired { required_roex, price_usd });
            }
            Some(pubkey) => {
                match check_meditation_access(
                    &solana_config,
                    &state.pool,
                    &state.http_client,
                    pubkey,
                )
                .await
                {
                    AccessResult::Granted => {}
                    AccessResult::Denied { required_roex, price_usd } => {
                        return Err(ApiError::PaymentRequired { required_roex, price_usd });
                    }
                    AccessResult::InvalidInput(msg) => {
                        return Err(ApiError::BadRequest(msg, None));
                    }
                }
            }
        }
    }

    match state.data_cache.get_meditation(data.language, data.duration).await {
        // auto_json streams large responses (with audio) instead of buffering them.
        Some(script) => Ok(auto_json(script)),
        None => Err(ApiError::NotFound),
    }
}