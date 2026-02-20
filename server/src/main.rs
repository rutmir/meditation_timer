pub mod pkg;
mod entities;
mod infrastructure;
mod logger;
mod service;

use tower_http::trace::TraceLayer;
use axum::Router;

#[tokio::main]
async fn main() {
    logger::configure_logger();
    if let Some(err) = infrastructure::job::start_jobs().await.err() {
        panic!("{}",err);
    }

    let app = Router::new()
        .merge(infrastructure::app::app())
        .nest("/api", infrastructure::api::api().await)
        .layer(TraceLayer::new_for_http()); 

    // run our app with hyper, listening globally on port 3000 (HTTP/1.1 + h2c)
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    infrastructure::server::serve_h2c(listener, app).await;
}
