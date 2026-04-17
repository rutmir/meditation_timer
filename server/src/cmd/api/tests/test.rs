#[cfg(test)]
mod tests {
    use axum::{
        body::Body,
        http::{Request, StatusCode},
        Router,
    };
    use tower::{Service, ServiceExt};
    use tower_http::trace::TraceLayer;
    use meditimer_core::{infrastructure::api, logger};
    // #[allow(unused_imports)]
    // use http_body_util::BodyExt; // for collect
    // use base64::prelude::*;

    #[tokio::test]
    async fn api_meditation_script_request() {
        logger::configure_logger();

        let mut app = Router::new()
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
        
        // let body = response.into_body().collect().await.unwrap().to_bytes();
        // let s = match str::from_utf8(&body) {
        //     Ok(v) => v,
        //     Err(e) => panic!("Invalid UTF-8 sequence: {}", e),
        // };
        // log::debug!("result {}", s);
    }

    #[tokio::test]
    async fn api_meditation_request() {
        logger::configure_logger();

        let mut app = Router::new()
            .nest("/api", api::api().await)
            .layer(TraceLayer::new_for_http())
            .into_service();

        // No API key → UNAUTHORIZED
        let request = Request::builder().uri("/api/meditation").body(Body::empty()).unwrap();
        let response = ServiceExt::<Request<Body>>::ready(&mut app)
            .await
            .unwrap()
            .call(request)
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::UNAUTHORIZED);

        // API key but no app version → BAD_REQUEST
        let request = Request::builder()
            .uri("/api/meditation")
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
            .uri("/api/meditation")
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
            .uri("/api/meditation?duration=30&lang=en&style=advaita")
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
            .uri("/api/meditation?duration=60&lang=en")
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

        // let body = response.into_body().collect().await.unwrap().to_bytes();
        // let s = match str::from_utf8(&body) {
        //     Ok(v) => v,
        //     Err(e) => panic!("Invalid UTF-8 sequence: {}", e),
        // };
        // log::debug!("result {}", s);
    }

    #[tokio::test]
    async fn api_meditation_list_request() {
        logger::configure_logger();

        let mut app = Router::new()
            .nest("/api", api::api().await)
            .layer(TraceLayer::new_for_http())
            .into_service();

        // No API key → UNAUTHORIZED
        let request = Request::builder().uri("/api/meditation/info/list/en").body(Body::empty()).unwrap();
        let response = ServiceExt::<Request<Body>>::ready(&mut app)
            .await
            .unwrap()
            .call(request)
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::UNAUTHORIZED);

        // Valid language → OK
        let request = Request::builder()
            .uri("/api/meditation/info/list/en")
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

        // Language with no cached data → NOT_FOUND
        let request = Request::builder()
            .uri("/api/meditation/info/list/fr")
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

        // Non-existent language → BAD_REQUEST
        let request = Request::builder()
            .uri("/api/meditation/info/list/tt")
            .header(api::HEADER_X_API_KEY, "111")
            .header(api::HEADER_X_APP_VERSION, "111")
            .body(Body::empty()).unwrap();
        let response = ServiceExt::<Request<Body>>::ready(&mut app)
            .await
            .unwrap()
            .call(request)
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::BAD_REQUEST);

        // let body = response.into_body().collect().await.unwrap().to_bytes();
        // let s = match str::from_utf8(&body) {
        //     Ok(v) => v,
        //     Err(e) => panic!("Invalid UTF-8 sequence: {}", e),
        // };
        // log::debug!("result {}", s);
    }

    /// When `roex_mint` is empty (gate disabled), `x-wallet-pubkey` header must be
    /// accepted, rejected, or absent — all yield the same result as a plain request.
    #[tokio::test]
    async fn api_meditation_wallet_gate_disabled() {
        logger::configure_logger();

        let mut app = Router::new()
            .nest("/api", api::api().await)
            .layer(TraceLayer::new_for_http())
            .into_service();

        // No wallet header → 200 (gate off, treated as normal request)
        let request = Request::builder()
            .uri("/api/meditation?duration=60&lang=en")
            .header(api::HEADER_X_API_KEY, "111")
            .header(api::HEADER_X_APP_VERSION, "111")
            .body(Body::empty()).unwrap();
        let response = ServiceExt::<Request<Body>>::ready(&mut app)
            .await.unwrap().call(request).await.unwrap();
        assert_eq!(response.status(), StatusCode::OK, "gate disabled — no wallet header should yield 200");

        // Valid wallet pubkey header → 200 (header present but ignored, gate off)
        let request = Request::builder()
            .uri("/api/meditation?duration=60&lang=en")
            .header(api::HEADER_X_API_KEY, "111")
            .header(api::HEADER_X_APP_VERSION, "111")
            .header(api::HEADER_X_WALLET_PUBKEY, "11111111111111111111111111111111")
            .body(Body::empty()).unwrap();
        let response = ServiceExt::<Request<Body>>::ready(&mut app)
            .await.unwrap().call(request).await.unwrap();
        assert_eq!(response.status(), StatusCode::OK, "gate disabled — valid wallet header should yield 200");

        // Garbage wallet pubkey header → 200 (ignored when gate is off, NOT validated)
        let request = Request::builder()
            .uri("/api/meditation?duration=60&lang=en")
            .header(api::HEADER_X_API_KEY, "111")
            .header(api::HEADER_X_APP_VERSION, "111")
            .header(api::HEADER_X_WALLET_PUBKEY, "not-a-valid-pubkey")
            .body(Body::empty()).unwrap();
        let response = ServiceExt::<Request<Body>>::ready(&mut app)
            .await.unwrap().call(request).await.unwrap();
        assert_eq!(response.status(), StatusCode::OK, "gate disabled — invalid wallet pubkey should still yield 200");
    }

    #[tokio::test]
    async fn api_health_request() {
        logger::configure_logger();

        let mut app = Router::new()
            .nest("/api", api::api().await)
            .layer(TraceLayer::new_for_http())
            .into_service();

        // No API key → UNAUTHORIZED
        let request = Request::builder().uri("/api/health").body(Body::empty()).unwrap();
        let response = ServiceExt::<Request<Body>>::ready(&mut app)
            .await
            .unwrap()
            .call(request)
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::UNAUTHORIZED);

        // API key but no app version → BAD_REQUEST
        let request = Request::builder()
            .uri("/api/health")
            .header(api::HEADER_X_API_KEY, "111")
            .body(Body::empty()).unwrap();
        let response = ServiceExt::<Request<Body>>::ready(&mut app)
            .await
            .unwrap()
            .call(request)
            .await
            .unwrap();
        assert_eq!(response.status(), StatusCode::BAD_REQUEST);

        // API key + app version → OK
        let request = Request::builder()
            .uri("/api/health")
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

        // let body = response.into_body().collect().await.unwrap().to_bytes();
        // let s = match str::from_utf8(&body) {
        //     Ok(v) => v,
        //     Err(e) => panic!("Invalid UTF-8 sequence: {}", e),
        // };
        // log::debug!("result {}", s);
    }
}
