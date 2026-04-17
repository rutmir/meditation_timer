/// Live integration tests against the deployed API.
///
/// All tests are marked `#[ignore]` and do NOT run in normal `cargo test`.
///
/// Run them explicitly:
///   ENV=test cargo test --test live_test -- --ignored --nocapture
///
/// Environment variables (optional overrides):
///   MEDITIMER_API_URL  — default: https://api.roex.pro/meditation/v2
///   MEDITIMER_API_KEY  — default: Hnp8ZrmqSBG0Ey3ILOsN3g
///
/// Notes:
/// - The reverse proxy strips the /api prefix — server routes are reachable
///   directly at {base_url}/health, {base_url}/meditation, etc.
/// - Data-dependent tests (list, script, meditation) accept both 200 and 404
///   because the content cache may not be populated yet in a fresh deployment.
#[cfg(test)]
mod live {
    use reqwest::{Client, StatusCode};
    use serde_json::Value;

    fn base_url() -> String {
        std::env::var("MEDITIMER_API_URL")
            .unwrap_or_else(|_| "https://api.roex.pro/meditation/v2".to_string())
    }

    fn api_key() -> String {
        std::env::var("MEDITIMER_API_KEY")
            .unwrap_or_else(|_| "Hnp8ZrmqSBG0Ey3ILOsN3g".to_string())
    }

    fn client() -> Client {
        Client::builder()
            .timeout(std::time::Duration::from_secs(15))
            .build()
            .unwrap()
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Auth middleware
    // ──────────────────────────────────────────────────────────────────────────

    #[tokio::test]
    #[ignore]
    async fn live_no_api_key_returns_401() {
        let resp = client()
            .get(format!("{}/health", base_url()))
            .header("x-app-version", "test")
            .send().await.unwrap();
        assert_eq!(resp.status(), StatusCode::UNAUTHORIZED);
    }

    #[tokio::test]
    #[ignore]
    async fn live_wrong_api_key_returns_401() {
        let resp = client()
            .get(format!("{}/health", base_url()))
            .header("x-api-key", "wrong-key")
            .header("x-app-version", "test")
            .send().await.unwrap();
        assert_eq!(resp.status(), StatusCode::UNAUTHORIZED);
    }

    #[tokio::test]
    #[ignore]
    async fn live_missing_app_version_returns_400() {
        let resp = client()
            .get(format!("{}/health", base_url()))
            .header("x-api-key", api_key())
            // no x-app-version
            .send().await.unwrap();
        assert_eq!(resp.status(), StatusCode::BAD_REQUEST);
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Health — returns 200 OK with no body (ApiResult::OK)
    // ──────────────────────────────────────────────────────────────────────────

    #[tokio::test]
    #[ignore]
    async fn live_health_ok() {
        let resp = client()
            .get(format!("{}/health", base_url()))
            .header("x-api-key", api_key())
            .header("x-app-version", "test")
            .send().await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Cache smoke — fails explicitly when job has not populated Redis yet.
    // Run this test to check whether the content pipeline is working.
    // ──────────────────────────────────────────────────────────────────────────

    /// Asserts that at least one language has cached content.
    /// FAILS if the job has never run — use this as a content pipeline health check.
    #[tokio::test]
    #[ignore]
    async fn live_cache_is_populated() {
        let languages = ["en", "ru", "es", "fr"];
        let mut populated = vec![];

        for lang in languages {
            let resp = client()
                .get(format!("{}/meditation/info/list/{}", base_url(), lang))
                .header("x-api-key", api_key())
                .header("x-app-version", "test")
                .send().await.unwrap();

            if resp.status() == StatusCode::OK {
                let body: Value = resp.json().await.unwrap();
                let count = body["data"].as_array().map(|a| a.len()).unwrap_or(0);
                println!("  {}: {} items", lang, count);
                populated.push((lang, count));
            } else {
                println!("  {}: empty ({})", lang, resp.status());
            }
        }

        assert!(
            !populated.is_empty(),
            "cache is completely empty — meditimer-job has not run or is failing. \
             Check: kubectl logs -l app=meditimer-job"
        );

        println!("populated languages: {:?}", populated);
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Meditation list
    // ──────────────────────────────────────────────────────────────────────────

    #[tokio::test]
    #[ignore]
    async fn live_meditation_list_en() {
        let resp = client()
            .get(format!("{}/meditation/info/list/en", base_url()))
            .header("x-api-key", api_key())
            .header("x-app-version", "test")
            .send().await.unwrap();

        // 200 if cache is populated, 404 if job hasn't run yet — both are valid.
        println!("list/en status: {}", resp.status());
        match resp.status() {
            StatusCode::OK => {
                let body: Value = resp.json().await.unwrap();
                println!("list/en body: {}", body);
                let items = body["data"].as_array().expect("'data' must be array");
                assert!(!items.is_empty(), "list must contain at least one item");
                // Each item must have duration and language fields.
                for item in items {
                    assert!(item.get("duration").is_some() || item.get("lang").is_some(),
                        "item must have duration or lang: {}", item);
                }
            }
            StatusCode::NOT_FOUND => println!("NOTICE: cache is empty, job has not populated data yet"),
            s => panic!("unexpected status: {}", s),
        }
    }

    #[tokio::test]
    #[ignore]
    async fn live_meditation_list_ru() {
        let resp = client()
            .get(format!("{}/meditation/info/list/ru", base_url()))
            .header("x-api-key", api_key())
            .header("x-app-version", "test")
            .send().await.unwrap();

        println!("list/ru status: {}", resp.status());
        assert!(
            resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND,
            "unexpected status: {}", resp.status()
        );
    }

    #[tokio::test]
    #[ignore]
    async fn live_meditation_list_invalid_lang_returns_400() {
        let resp = client()
            .get(format!("{}/meditation/info/list/xx", base_url()))
            .header("x-api-key", api_key())
            .header("x-app-version", "test")
            .send().await.unwrap();
        assert_eq!(resp.status(), StatusCode::BAD_REQUEST);
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Meditation script (text only)
    // ──────────────────────────────────────────────────────────────────────────

    #[tokio::test]
    #[ignore]
    async fn live_meditation_script_en_60s() {
        let resp = client()
            .get(format!("{}/meditation/script?duration=60&lang=en", base_url()))
            .header("x-api-key", api_key())
            .header("x-app-version", "test")
            .send().await.unwrap();

        println!("script/en/60 status: {}", resp.status());
        match resp.status() {
            StatusCode::OK => {
                let body: Value = resp.json().await.unwrap();
                println!("script/en/60 data keys: {:?}",
                    body["data"].as_object().map(|o| o.keys().collect::<Vec<_>>()));
                assert!(body.get("data").is_some());
            }
            StatusCode::NOT_FOUND => println!("NOTICE: no cached script for en/60 yet"),
            s => panic!("unexpected status: {}", s),
        }
    }

    #[tokio::test]
    #[ignore]
    async fn live_meditation_script_missing_params_returns_415() {
        let resp = client()
            .get(format!("{}/meditation/script", base_url()))
            .header("x-api-key", api_key())
            .header("x-app-version", "test")
            .send().await.unwrap();
        assert_eq!(resp.status(), StatusCode::UNSUPPORTED_MEDIA_TYPE);
    }

    #[tokio::test]
    #[ignore]
    async fn live_meditation_script_nonexistent_duration_returns_404() {
        let resp = client()
            .get(format!("{}/meditation/script?duration=999&lang=en", base_url()))
            .header("x-api-key", api_key())
            .header("x-app-version", "test")
            .send().await.unwrap();
        assert_eq!(resp.status(), StatusCode::NOT_FOUND);
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Meditation (with audio)
    // ──────────────────────────────────────────────────────────────────────────

    #[tokio::test]
    #[ignore]
    async fn live_meditation_en_60s() {
        let resp = client()
            .get(format!("{}/meditation?duration=60&lang=en", base_url()))
            .header("x-api-key", api_key())
            .header("x-app-version", "test")
            .send().await.unwrap();

        println!("meditation/en/60 status: {}", resp.status());
        match resp.status() {
            StatusCode::OK => {
                let body: Value = resp.json().await.unwrap();
                println!("meditation/en/60 data keys: {:?}",
                    body["data"].as_object().map(|o| o.keys().collect::<Vec<_>>()));
                assert!(body.get("data").is_some());
            }
            StatusCode::NOT_FOUND => println!("NOTICE: no cached meditation for en/60 yet"),
            s => panic!("unexpected status: {}", s),
        }
    }

    #[tokio::test]
    #[ignore]
    async fn live_meditation_missing_params_returns_415() {
        let resp = client()
            .get(format!("{}/meditation", base_url()))
            .header("x-api-key", api_key())
            .header("x-app-version", "test")
            .send().await.unwrap();
        assert_eq!(resp.status(), StatusCode::UNSUPPORTED_MEDIA_TYPE);
    }

    #[tokio::test]
    #[ignore]
    async fn live_meditation_nonexistent_duration_returns_404() {
        let resp = client()
            .get(format!("{}/meditation?duration=999&lang=en", base_url()))
            .header("x-api-key", api_key())
            .header("x-app-version", "test")
            .send().await.unwrap();
        assert_eq!(resp.status(), StatusCode::NOT_FOUND);
    }

    /// Gate is disabled (roex_mint is empty) — wallet header must be ignored.
    /// Status is 200 (cached data) or 404 (cache empty), never 402.
    #[tokio::test]
    #[ignore]
    async fn live_meditation_wallet_header_ignored_when_gate_disabled() {
        let resp = client()
            .get(format!("{}/meditation?duration=60&lang=en", base_url()))
            .header("x-api-key", api_key())
            .header("x-app-version", "test")
            .header("x-wallet-pubkey", "11111111111111111111111111111111")
            .send().await.unwrap();

        let status = resp.status();
        println!("meditation+wallet status: {}", status);
        assert_ne!(status, StatusCode::PAYMENT_REQUIRED,
            "gate is disabled — must not return 402");
        assert_ne!(status, StatusCode::UNAUTHORIZED,
            "must not return 401 due to wallet header");
        assert!(
            status == StatusCode::OK || status == StatusCode::NOT_FOUND,
            "expected 200 or 404, got {}", status
        );
    }

    // ──────────────────────────────────────────────────────────────────────────
    // ROEX gate — 402 / 400 paths (only testable when roex_mint is set).
    // Run against a staging server with roex_mint configured.
    // ──────────────────────────────────────────────────────────────────────────

    /// When gate is enabled and no wallet header is provided → 402 with JSON body.
    #[tokio::test]
    #[ignore]
    async fn live_meditation_no_wallet_returns_402_when_gate_enabled() {
        let resp = client()
            .get(format!("{}/meditation?duration=60&lang=en", base_url()))
            .header("x-api-key", api_key())
            .header("x-app-version", "test")
            // no x-wallet-pubkey
            .send().await.unwrap();

        if resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND {
            println!("SKIP: roex_mint is empty on this server, gate is disabled");
            return;
        }

        assert_eq!(resp.status(), StatusCode::PAYMENT_REQUIRED);
        let body: Value = resp.json().await.unwrap();
        println!("402 body: {}", body);
        assert_eq!(body["error"]["code"], 402);
        assert!(body["error"]["required_roex"].as_f64().unwrap_or(0.0) > 0.0,
            "required_roex must be positive");
        assert!(body["error"]["price_usd"].as_f64().unwrap_or(0.0) > 0.0,
            "price_usd must be positive");
    }

    /// When gate is enabled and wallet pubkey is malformed → 400.
    #[tokio::test]
    #[ignore]
    async fn live_meditation_invalid_wallet_returns_400_when_gate_enabled() {
        let resp = client()
            .get(format!("{}/meditation?duration=60&lang=en", base_url()))
            .header("x-api-key", api_key())
            .header("x-app-version", "test")
            .header("x-wallet-pubkey", "not-a-valid-base58!!!")
            .send().await.unwrap();

        if resp.status() == StatusCode::OK || resp.status() == StatusCode::NOT_FOUND {
            println!("SKIP: roex_mint is empty on this server, gate is disabled");
            return;
        }

        assert_eq!(resp.status(), StatusCode::BAD_REQUEST);
    }
}
