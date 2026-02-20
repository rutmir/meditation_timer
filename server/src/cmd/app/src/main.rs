use axum::Router;
use tokio::net::TcpListener;
use tower_http::trace::TraceLayer;
use meditimer_core::{logger, infrastructure::app};

#[tokio::main]
async fn main() {
    logger::configure_logger();

    let app = Router::new()
        .merge(app::app())
        .layer(TraceLayer::new_for_http()); 

    // run our app with hyper, listening globally on port 3000
    let listener = TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
