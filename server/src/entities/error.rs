#[derive(thiserror::Error, Debug)]
pub enum AppError {
    #[error("SerDe error {0:?}")]              SerDeError(String),
    #[error("Platform not supported")]         PlatformNotSupported,
    #[error("IO error: {0:?}")]                IOError(#[from] std::io::Error),
    #[error("Figment error: {0:?}")]           FigmentError(#[from] figment::Error),
    #[error("Set logger error: {0:?}")]        SetLoggerError(#[from] log::SetLoggerError),
    #[error("Unknown error")]                  Unknown,
    #[error(transparent)]                      RedisPool(#[from] bb8::RunError<bb8_redis::redis::RedisError>),
    #[error(transparent)]                      Redis(#[from] bb8_redis::redis::RedisError),
    #[error("Not found")]                      NotFound,
    #[error(transparent)]                      ToStrError(#[from] axum::http::header::ToStrError),
    #[error(transparent)]                      JobSchedulerError(#[from] tokio_cron_scheduler::JobSchedulerError),
}
