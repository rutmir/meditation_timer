use axum::{response::{IntoResponse, Response, Json}};
use serde::Serialize;
use super::api_error::ErrorResponse;

const API_VERSION:&'static str = "0.1";

#[derive(Debug, Serialize)]
pub struct ApiResponse <'a, T> where
T: Serialize {
    #[serde(rename = "apiVersion")]
    pub api_version: &'static str,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<ErrorResponse<'a>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub data: Option<T>,
}

impl<'a, T> ApiResponse <'a, T> where
T: Serialize {
    pub fn new(data: Option<T>) -> Self {
        Self {api_version: API_VERSION, data: data, error: None, }
    }

    pub fn new_error(error: Option<ErrorResponse<'a>>) -> Self {
        Self {api_version: API_VERSION, data: None, error: error, }
    }
}

impl<'a, T> IntoResponse for ApiResponse<'a, T> where
T: Serialize{
    fn into_response(self) -> Response {
        Json(self).into_response()
    }
}
