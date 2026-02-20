use axum::extract::State;

use crate::entities::meditation_script::MeditationScript;
use super::common::{api_error::ApiError, api_result::{auto_json, ApiResult}};
use super::requests::meditation_script_request::MeditationScriptRequest;
use super::api_state::ApiState;

pub async fn get_meditation_script<'a>(State(_state): State<ApiState>, data: MeditationScriptRequest) -> Result<ApiResult<MeditationScript>, ApiError<'a>> {
    log::debug!("--> in the get_meditation_script:{:?}", data);
    match _state.data_cache.get_script(data.language, data.duration).await {
        // Use auto_json to automatically stream if response is large
        Some(script) => Ok(auto_json(script)),
        None => Err(ApiError::NotFound),
    }
}