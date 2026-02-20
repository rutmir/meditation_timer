use std::net::SocketAddr;
use axum::{extract::ConnectInfo, routing::{get, post}, Json, Router};
use serde_json::Value;

async fn root_handler() -> &'static str {
    "Hello, Axum!"
}

async fn json_handler(payload: Json<serde_json::Value>) -> Json<Value> {
    Json(serde_json::json!({ "data": payload.0 }))
}

async fn requires_connect_info(ConnectInfo(addr): ConnectInfo<SocketAddr>) -> String {
    format!("Hi {addr}")
}

// build our application with a route
pub fn app() -> Router {
    Router::new()
    .route(
        "/", 
        get(root_handler),
    )
    .route(
        "/json",
        post(json_handler),
    )
    .route(
        "/requires-connect-info",
        get(requires_connect_info),
    )
 }
