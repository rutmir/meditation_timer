#[cfg(test)]
mod tests {
    use std::{fs, io::Write, net::SocketAddr};
    use axum::{
        body::Body,
        extract::connect_info::MockConnectInfo,
        http::{self, Request, StatusCode},
        Router,
    };
    use http_body_util::BodyExt;
    use meditimer_core::{
        entities::{language::Language,
            meditation_script::{MeditationScript, ScriptItem}}, infrastructure::{api, app, server}, logger, service::{data_cache::DataCache, gemini::GeminiService, tts}};
    use serde_json::{json, Value};
    use tokio::net::TcpListener;
    use tower::{Service, ServiceExt};
    use tower_http::trace::TraceLayer;
    use base64::prelude::*;

    #[tokio::test]
    async fn data_cache_test() {
        logger::configure_logger();

        let cache = DataCache::instance().await;
        let keys = cache.get_cached_keys(None, None).await;

        if let Some(keys) = keys {
            log::debug!("Keys: {:?}", keys);
        } else {
            log::debug!("No Keys");
        }

        if let Some(script) = cache.get_script(Language::English, 60).await {
            log::debug!("script presented: valid: {}, valid source: {}", script.is_valid(), script.is_valid_source())
        }

        if let Some(script) = cache.get_meditation(Language::English, 60).await {
            log::debug!("meditation presented: valid: {}, valid source: {}", script.is_valid(), script.is_valid_source())
        }
    }

    #[tokio::test]
    async fn tts_test() {
        logger::configure_logger();

        let mut source = ScriptItem {
            instructions: "Continue to rest in this open, non-judgmental awareness. This is a practice of simply being, exactly as you are, in this moment.".to_string(),
            audio: None,
            start_time: 0
        };
        let (ok, mp3_string_option) = tts::convert_text_to_speach(&source, Language::English).await;

        assert!(ok);

        source.audio = mp3_string_option;

        let buffer = BASE64_STANDARD.decode(source.audio.unwrap()).unwrap();
        let mut file = fs::File::create("test.mp3").unwrap();
        file.write_all(&buffer).unwrap();
    }

    #[tokio::test]
    async fn gemini_test() {
        logger::configure_logger();

        let gemini = GeminiService::instance();
        let script = gemini.get_meditation_script(Language::Russian, 20, None).await;

        assert!(script.is_some() && script.unwrap().is_valid_source());
    }

    #[tokio::test]
    async fn json_test() {
        logger::configure_logger();

        let json = fs::read_to_string("test_data.json")
            .expect("Failed to read test_data.json");

        let script: MeditationScript = serde_json::from_str(&json)
            .expect("Failed to parse MeditationScript from JSON");

        assert!(script.is_valid_source());
    }

    #[tokio::test]
    async fn app_hello_world() {
        logger::configure_logger();

        let app = app::app();
        let response = app
            .oneshot(Request::builder().uri("/").body(Body::empty()).unwrap())
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);

        let body = response.into_body().collect().await.unwrap().to_bytes();
        assert_eq!(&body[..], b"Hello, Axum!");
    }

    #[tokio::test]
    async fn app_json() {
        logger::configure_logger();

        let app = app::app();
        let response = app
            .oneshot(
                Request::builder()
                    .method(http::Method::POST)
                    .uri("/json")
                    .header(http::header::CONTENT_TYPE, mime::APPLICATION_JSON.as_ref())
                    .body(Body::from(
                        serde_json::to_vec(&json!([1, 2, 3, 4])).unwrap(),
                    ))
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::OK);

        let body = response.into_body().collect().await.unwrap().to_bytes();
        let body: Value = serde_json::from_slice(&body).unwrap();
        assert_eq!(body, json!({ "data": [1, 2, 3, 4] }));
    }

    #[tokio::test]
    async fn app_not_found() {
        logger::configure_logger();

        let app = app::app();
        let response = app
            .oneshot(
                Request::builder()
                    .uri("/does-not-exist")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        assert_eq!(response.status(), StatusCode::NOT_FOUND);
        let body = response.into_body().collect().await.unwrap().to_bytes();
        assert!(body.is_empty());
    }

    #[tokio::test]
    async fn app_the_real_deal() {
        logger::configure_logger();

        let listener = TcpListener::bind("0.0.0.0:0").await.unwrap();
        let addr = listener.local_addr().unwrap();

        tokio::spawn(async move {
            server::serve_h2c(listener, app::app()).await;
        });

        let client =
            hyper_util::client::legacy::Client::builder(hyper_util::rt::TokioExecutor::new())
                .build_http();

        let response = client
            .request(
                Request::builder()
                    .uri(format!("http://{addr}"))
                    .header("Host", "localhost")
                    .body(Body::empty())
                    .unwrap(),
            )
            .await
            .unwrap();

        let body = response.into_body().collect().await.unwrap().to_bytes();
        assert_eq!(&body[..], b"Hello, Axum!");
    }

    #[tokio::test]
    async fn app_multiple_request() {
        logger::configure_logger();

        let mut app = app::app().into_service();

        let request = Request::builder().uri("/").body(Body::empty()).unwrap();
        let response = ServiceExt::<Request<Body>>::ready(&mut app)
            .await
            .unwrap()
            .call(request)
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::OK);

        let request = Request::builder().uri("/").body(Body::empty()).unwrap();
        let response = ServiceExt::<Request<Body>>::ready(&mut app)
            .await
            .unwrap()
            .call(request)
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn app_with_into_make_service_with_connect_info() {
        logger::configure_logger();

        let mut app = app::app()
            .layer(MockConnectInfo(SocketAddr::from(([0, 0, 0, 0], 3000))))
            .into_service();

        let request = Request::builder()
            .uri("/requires-connect-info")
            .body(Body::empty())
            .unwrap();
        let response = app.ready().await.unwrap().call(request).await.unwrap();

        assert_eq!(response.status(), StatusCode::OK);
    }

    #[tokio::test]
    async fn api_meditation_script_request() {
        logger::configure_logger();

        let mut app = Router::new()
            .merge(app::app())
            .nest("/api", api::api().await)
            .layer(TraceLayer::new_for_http())
            .into_service();

        // No API key → UNAUTHORIZED
        let request = Request::builder().uri("/api/meditation/script").body(Body::empty()).unwrap();
        let response = ServiceExt::<Request<Body>>::ready(&mut app)
            .await
            .unwrap()
            .call(request)
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::UNAUTHORIZED);

        // API key but no app version → BAD_REQUEST
        let request = Request::builder()
            .uri("/api/meditation/script")
            .header(api::HEADER_X_API_KEY, "111")
            .body(Body::empty()).unwrap();
        let response = ServiceExt::<Request<Body>>::ready(&mut app)
            .await
            .unwrap()
            .call(request)
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::BAD_REQUEST);

        // API key + app version, no query params → UNSUPPORTED_MEDIA_TYPE
        let request = Request::builder()
            .uri("/api/meditation/script")
            .header(api::HEADER_X_API_KEY, "111")
            .header(api::HEADER_X_APP_VERSION, "111")
            .body(Body::empty()).unwrap();
        let response = ServiceExt::<Request<Body>>::ready(&mut app)
            .await
            .unwrap()
            .call(request)
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::UNSUPPORTED_MEDIA_TYPE);

        // Non-standard duration with style → NOT_FOUND
        let request = Request::builder()
            .uri("/api/meditation/script?duration=30&lang=en&style=advaita")
            .header(api::HEADER_X_API_KEY, "111")
            .header(api::HEADER_X_APP_VERSION, "111")
            .body(Body::empty()).unwrap();
        let response = ServiceExt::<Request<Body>>::ready(&mut app)
            .await
            .unwrap()
            .call(request)
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::NOT_FOUND);

        // Valid request → OK
        let request = Request::builder()
            .uri("/api/meditation/script?duration=60&lang=en")
            .header(api::HEADER_X_API_KEY, "111")
            .header(api::HEADER_X_APP_VERSION, "111")
            .body(Body::empty()).unwrap();
        let response = ServiceExt::<Request<Body>>::ready(&mut app)
            .await
            .unwrap()
            .call(request)
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::OK);
    }
}
