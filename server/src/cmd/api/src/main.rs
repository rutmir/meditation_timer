use axum::Router;
use tokio::net::TcpListener;
use tower_http::trace::TraceLayer;
use meditimer_core::{infrastructure::{api, server}, logger};

#[tokio::main]
async fn main() {
    logger::configure_logger();

    let api = Router::new()
        .nest("/api", api::api().await)
        .layer(TraceLayer::new_for_http()); 

    // run our app with hyper, listening globally on port 3000 (HTTP/1.1 + h2c)
    let listener = TcpListener::bind("0.0.0.0:3000").await.unwrap();
    server::serve_h2c(listener, api).await;
}
