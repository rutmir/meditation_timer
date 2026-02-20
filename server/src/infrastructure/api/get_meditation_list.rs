use std::collections::HashSet;
use axum::extract::{State, Path};

use crate::entities::language::Language;
use crate::entities::meditation_script_info::MeditationScriptInfo;
use super::common::{api_error::ApiError, api_result::ApiResult};
use super::api_state::ApiState;

pub async fn get_meditation_list<'a>(State(_state): State<ApiState>, Path(language): Path<Language>) -> Result<ApiResult<HashSet<MeditationScriptInfo>>, ApiError<'a>> {
    log::debug!("--> in the get_meditation_list:{:?}", language);
    match _state.data_cache.get_script_info_list(language).await {
        Some(script) => Ok(ApiResult::JsonData(script)),
        None => Err(ApiError::NotFound),
    }
}