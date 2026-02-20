use axum::{
    body::Body,
    http::{header, StatusCode},
    response::{IntoResponse, Response},
    Json,
};
use futures::stream;
use serde::Serialize;
use std::convert::Infallible;

/// Size threshold (in bytes) above which responses should be streamed.
/// Responses smaller than this will be sent as regular JSON.
const STREAM_THRESHOLD: usize = 64 * 1024; // 64KB

/// Chunk size for streaming large responses
const CHUNK_SIZE: usize = 16 * 1024; // 16KB chunks

pub enum ApiResult<T>
where
    T: Serialize,
{
    OK,
    JsonData(T),
    /// Streaming variant for large JSON payloads
    StreamingJson(T),
}

impl<T> IntoResponse for ApiResult<T>
where
    T: Serialize,
{
    fn into_response(self) -> Response {
        match self {
            Self::OK => StatusCode::OK.into_response(),
            Self::JsonData(data) => (StatusCode::OK, Json(data)).into_response(),
            Self::StreamingJson(data) => stream_json_response(data),
        }
    }
}

/// Creates a streaming response for large JSON payloads.
/// Serializes the data and streams it in chunks to avoid buffering
/// the entire response in memory.
fn stream_json_response<T: Serialize>(data: T) -> Response {
    // Serialize the data to bytes
    let bytes = match serde_json::to_vec(&data) {
        Ok(b) => b,
        Err(e) => {
            log::error!("Failed to serialize JSON for streaming: {}", e);
            return (
                StatusCode::INTERNAL_SERVER_ERROR,
                "Failed to serialize response",
            )
                .into_response();
        }
    };

    // If the data is small enough, just return it directly
    if bytes.len() < STREAM_THRESHOLD {
        return Response::builder()
            .status(StatusCode::OK)
            .header(header::CONTENT_TYPE, "application/json")
            .header(header::CONTENT_LENGTH, bytes.len())
            .body(Body::from(bytes))
            .unwrap();
    }

    // Stream the serialized bytes in chunks
    let chunks: Vec<Vec<u8>> = bytes.chunks(CHUNK_SIZE).map(|c| c.to_vec()).collect();

    let stream = stream::iter(chunks.into_iter().map(Ok::<_, Infallible>));

    let body = Body::from_stream(stream);

    Response::builder()
        .status(StatusCode::OK)
        .header(header::CONTENT_TYPE, "application/json")
        .body(body)
        .unwrap()
}

/// Helper function to determine if data should be streamed based on size.
/// Useful for endpoints that want to decide at runtime whether to stream.
pub fn should_stream<T: Serialize>(data: &T) -> bool {
    // Estimate size by serializing - this is a trade-off between
    // accuracy and performance. For hot paths, consider caching size estimates.
    match serde_json::to_vec(data) {
        Ok(bytes) => bytes.len() >= STREAM_THRESHOLD,
        Err(_) => false,
    }
}

/// Smart result that automatically chooses streaming for large payloads
pub fn auto_json<T: Serialize>(data: T) -> ApiResult<T> {
    if should_stream(&data) {
        ApiResult::StreamingJson(data)
    } else {
        ApiResult::JsonData(data)
    }
}
