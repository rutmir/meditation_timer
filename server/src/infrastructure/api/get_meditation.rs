use axum::extract::State;

use crate::entities::meditation_script::MeditationScript;
use super::common::{api_error::ApiError, api_result::{auto_json, ApiResult}};
use super::requests::meditation_script_request::MeditationScriptRequest;
use super::api_state::ApiState;

pub async fn get_meditation<'a>(State(_state): State<ApiState>, data: MeditationScriptRequest) -> Result<ApiResult<MeditationScript>, ApiError<'a>> {
    log::debug!("--> in the get_meditation:{:?}", data);
    match _state.data_cache.get_meditation(data.language, data.duration).await {
        // Use auto_json to automatically stream large meditation responses (with audio)
        Some(script) => Ok(auto_json(script)),
        None => Err(ApiError::NotFound),
    }
}