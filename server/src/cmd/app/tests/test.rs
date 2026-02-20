#[cfg(test)]
mod tests {
    use std::net::SocketAddr;
    use axum::{
        body::Body,
        extract::connect_info::MockConnectInfo,
        http::{self, Request, StatusCode}, 
    };
    use http_body_util::BodyExt; // for `collect`
    use serde_json::{json, Value};
    use tokio::net::TcpListener;
    use tower::{Service, ServiceExt};
    // use tower_http::trace::TraceLayer; // for `call`, `oneshot`, and `ready`
    use meditimer_core::{logger, infrastructure::app};
     
    // fn setup() {
    //     // first method loaded in integration test, requires ENV env var
    //     dotenv::from_filename(format!(".env.{}", env::var("ENV").expect("ENV must be set"))).ok();
    // }

    #[tokio::test]
    async fn app_hello_world() {
        // setup();
        logger::configure_logger();

        let app = app::app();
        // `Router` implements `tower::Service<Request<Body>>` so we can
        // call it like any tower service, no need to run an HTTP server.
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

    // You can also spawn a server and talk to it like any other HTTP server:
    #[tokio::test]
    async fn app_the_real_deal() {
        logger::configure_logger();
        
        let listener = TcpListener::bind("0.0.0.0:0").await.unwrap();
        let addr = listener.local_addr().unwrap();

        tokio::spawn(async move {
            axum::serve(listener, app::app()).await.unwrap();
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

    // You can use `ready()` and `call()` to avoid using `clone()`
    // in multiple request
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

    // Here we're calling `/requires-connect-info` which requires `ConnectInfo`
    //
    // That is normally set with `Router::into_make_service_with_connect_info` but we can't easily
    // use that during tests. The solution is instead to set the `MockConnectInfo` layer during
    // tests.
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
        let status = response.status();
        // let body = response.into_body().collect().await.unwrap().to_bytes();
        // let s = match str::from_utf8(&body) {
        //     Ok(v) => v,
        //     Err(e) => panic!("Invalid UTF-8 sequence: {}", e),
        // };
        // println!("result {}", s);

        assert_eq!(status, StatusCode::OK);
    }
}