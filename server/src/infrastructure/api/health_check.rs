use axum::extract::State;

use super::common::{api_error::ApiError, api_result::ApiResult};
use super::api_state::ApiState;

pub async fn health_check<'a>(State(_state): State<ApiState>) -> Result<ApiResult<bool>, ApiError<'a>> {
    log::debug!("--> in the health_check");
    Ok(ApiResult::OK)
}