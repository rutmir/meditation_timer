use axum::{response::{IntoResponse, Response},  http::StatusCode};
use serde::Serialize;
use thiserror::Error;
use super::api_response::ApiResponse;

#[derive(Debug, Error)]
pub enum ApiError<'a> {
    #[error("bad request")]
    BadRequest(String, Option<Vec<ErrorDetail<'a>>>),
    #[error("route not allowed")]
    Forbidden,
    #[error("request not authorized")]
    Unauthorized,
    #[error("internal server error")]
    InternalServerError(String, Option<Vec<ErrorDetail<'a>>>),
    #[error("couldn't find the requested resource")]
    NotFound,
    #[error("not supported entity type")]
    UnsupportedMediaType
    // #[error(transparent)]
    // PaginationError(#[from] PaginationError),
}

impl<'a> IntoResponse for ApiError<'a>  {
    fn into_response(self) -> Response {
        let message = self.to_string();

        match self {
            Self::BadRequest(msg, details)=> (StatusCode::BAD_REQUEST, ErrorResponse::new(StatusCode::BAD_REQUEST.as_u16(), msg.as_str(), details)).into_response(),
            Self::Forbidden => (StatusCode::FORBIDDEN, ErrorResponse::new(StatusCode::FORBIDDEN.as_u16(), message.clone().as_str(), None)).into_response(),
            Self::Unauthorized => (StatusCode::UNAUTHORIZED, ErrorResponse::new(StatusCode::UNAUTHORIZED.as_u16(), message.as_str(), None)).into_response(),
            Self::InternalServerError(msg, details) => (StatusCode::INTERNAL_SERVER_ERROR, ErrorResponse::new(StatusCode::INTERNAL_SERVER_ERROR.as_u16(), msg.as_str(), details)).into_response(),
            Self::NotFound => (StatusCode::NOT_FOUND, ErrorResponse::new(StatusCode::NOT_FOUND.as_u16(), message.as_str(), None)).into_response(),
            Self::UnsupportedMediaType => (StatusCode::UNSUPPORTED_MEDIA_TYPE, ErrorResponse::new(StatusCode::UNSUPPORTED_MEDIA_TYPE.as_u16(), message.as_str(), None)).into_response(),
        }
    }
}

#[derive(Debug, Serialize)]
pub struct ErrorDetail<'a> {
    pub domain: &'a str,
    pub reason: &'a str,
    pub message: &'a str,
}

#[derive(Debug, Serialize)]
pub struct ErrorResponse<'a> {
    pub code: u16,
    pub message: &'a str,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub errors: Option<Vec<ErrorDetail<'a>>>,
}

impl<'a> ErrorResponse<'a> {
    pub fn new(code: u16, message: &'a str, errors: Option<Vec<ErrorDetail<'a>>>) -> Self {
        Self { code, message, errors, }
    }
}

impl<'a> IntoResponse for ErrorResponse<'a> {
    fn into_response(self) -> Response {
        ApiResponse::<String>::new_error(Some(self)).into_response()
    }
}
