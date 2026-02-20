use axum::{extract::{FromRequest, Query, Request}, http::header, 
    response::{IntoResponse, Response}, Form, Json};
use serde::{Deserialize, Serialize};
use crate::{infrastructure::api::common::api_error::ApiError, entities::{language::Language, meditation_style::MeditationStyle}};

const HEADER_X_APP_VERSION: &'static str = "x-app-version";

#[derive(Debug, Serialize, Deserialize)]
pub struct MeditationScriptRequest {
    pub duration: u32,
    #[serde(rename = "lang")]
    pub language: Language,
    pub style: Option<MeditationStyle>,
    #[serde(skip_serializing_if = "Option::is_none", rename = "appVersion")]
    pub app_version: Option<String>,
}

impl<S> FromRequest<S> for MeditationScriptRequest
where
    S: Send + Sync,
{
    type Rejection = Response;

    async fn from_request(req: Request, _state: &S) -> Result<Self, Self::Rejection> {
        let content_type_header = req.headers().get(header::CONTENT_TYPE);
        let content_type = content_type_header.and_then(|value| value.to_str().ok());
        let app_version_header = req.headers().get(HEADER_X_APP_VERSION);
        let Some(app_version) = app_version_header.and_then(|value| value.to_str().ok()) else {
            return Err(ApiError::BadRequest("APP version parameter required".to_string(), None).into_response());
        };
        let app_version = app_version.to_string();

        if let Some(content_type) = content_type {
            if content_type.starts_with("application/json") {
                let Json(mut payload) = Json::<MeditationScriptRequest>::from_request(req, &()).await.map_err(IntoResponse::into_response)?;
                payload.app_version = Some(app_version.to_string());
                return Ok(payload);
            }

            if content_type.starts_with("application/x-www-form-urlencoded") {
                let Form(mut payload) = Form::<MeditationScriptRequest>::from_request(req, &()).await.map_err(IntoResponse::into_response)?;
                payload.app_version = Some(app_version.to_string());
                return Ok(payload);
            }
        }

        match Query::<MeditationScriptRequest>::from_request(req, &()).await {
            Ok(Query(mut payload)) => {
                payload.app_version = Some(app_version.to_string());
                return Ok(payload);
            },
            Err(_) => {
                return Err(ApiError::UnsupportedMediaType.into_response());
            },
        }
    }
}