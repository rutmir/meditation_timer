mod common;
mod requests;
mod api_state;
pub mod api_config;
pub mod get_meditation_script;
pub mod get_meditation;
pub mod get_meditation_list;
pub mod health_check;

use std::{convert::Infallible};
use axum::{extract::{Request, State}, middleware::from_fn, response::{IntoResponse, Response}, routing::get};
use axum::{Router, middleware::{from_fn_with_state, Next}};
// use bb8::Pool;
// use bb8_redis::{redis::AsyncCommands, RedisConnectionManager};
use tokio_cron_scheduler::{Job, JobScheduler};
use tower::ServiceBuilder;

use common::api_error::ApiError;
use get_meditation_script::get_meditation_script;
use get_meditation::get_meditation;
use get_meditation_list::get_meditation_list;
use health_check::health_check;
use api_state::ApiState;
use crate::{entities::error::AppError, infrastructure::api::api_config::ApiConfig, service::data_cache::DataCache};

pub const HEADER_X_API_KEY: &'static str = "x-api-key";
pub const HEADER_X_APP_VERSION: &'static str = "x-app-version";
/// Solana wallet public key (base58). Required for ROEX-gated endpoints.
pub const HEADER_X_WALLET_PUBKEY: &'static str = "x-wallet-pubkey";

fn get_auth_header_value(req: &Request) -> Result<&str, AppError> {
    for (key, value) in req.headers().iter() {
        let header_name = key.as_str(); 

        if  header_name == HEADER_X_API_KEY {
            let out =  value.to_str()?;
            return Ok(out);
        }
    }

    Err(AppError::NotFound)
}

fn get_app_value_header(req: &Request) -> Result<&str, AppError> {
    for (key, value) in req.headers().iter() {
        let header_name = key.as_str(); 

        if  header_name == HEADER_X_APP_VERSION {
            let out =  value.to_str()?;
            return Ok(out);
        }
    }

    Err(AppError::NotFound)
}

// async fn authorized(pool: Pool<RedisConnectionManager>, key: &str) -> Result<bool, AppError> {
//     let mut conn = pool.get().await?;
//     let result: String = conn.get(format!("api_key{}", key).as_str()).await?;
// 
//     Ok(result.as_str() == "true")
// }

async fn auth_middleware(State(state): State<ApiState>, req: Request, next: Next) -> Result<Response, Infallible> {
    match get_auth_header_value(&req){
        Ok(key) => {
            if state.config.lock().unwrap().api_keys.contains(&key.to_string()) {
                return Ok(next.run(req).await);
            }
            
            return Ok(ApiError::Unauthorized.into_response());

            // match authorized(state.pool, key).await {
            //     Ok(success) => {
            //         if success {
            //             return Ok(next.run(req).await);
            //         }
            // 
            //         return Ok(ApiError::Unauthorized.into_response());
            //     },
            //     Err(e) => {
            //         return Ok(ApiError::InternalServerError(e.to_string(), None).into_response())
            //     },
            // }
        },
        Err(_) => {
            return Ok(ApiError::Unauthorized.into_response());
        },
    }
}

async fn app_version_middleware(req: Request, next: Next) -> Result<Response, Infallible> {
    match get_app_value_header(&req){
        Ok(_) => {
            return Ok(next.run(req).await);
        },
        Err(_) => {
            return Ok(ApiError::BadRequest("APP version parameter required".to_string(), None).into_response());
        },
    }
}

async fn start_api_jobs() -> Result<(), AppError> {
    let data_cache =  DataCache::instance().await;
    let sched = JobScheduler::new().await?;

    sched.add(
        Job::new_async("0 1/15 * * * *", {
            let cache = data_cache.clone();
            move |_, _| {
                let mut cache = cache.clone();
                Box::pin(async move {
                    cache.lazy_load().await;
                })
            }
        })?,
    ).await?;

    sched.start().await?;
    Ok(())
}

pub async fn api() -> Router {
    let state =  ApiState::new(ApiConfig::instance()).await;

    start_api_jobs().await.unwrap();
    
    let router = Router::new()
        .route(
            "/health", 
            get(health_check))
        .route(
            "/meditation/script", 
            get(get_meditation_script))
        .route(
            "/meditation", 
            get(get_meditation))
        .route(
            "/meditation/info/list/{language}", 
            get(get_meditation_list))
        .layer(
            ServiceBuilder::new().layer(from_fn(app_version_middleware))
        )
        .layer(
            ServiceBuilder::new().layer(from_fn_with_state(state.clone(), auth_middleware))
        )
        .with_state(state); 

    router
}
