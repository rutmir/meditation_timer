use axum::Router;
use hyper_util::rt::{TokioExecutor, TokioIo};
use hyper_util::server::conn::auto::Builder;
use tokio::net::TcpListener;
use tower::Service;

/// Starts an HTTP server that supports both HTTP/1.1 and HTTP/2 cleartext (h2c).
///
/// Uses hyper-util's auto connection builder which detects the protocol
/// from the client's initial bytes — supporting h2c prior-knowledge,
/// HTTP/1.1 upgrade to h2c, and plain HTTP/1.1.
pub async fn serve_h2c(listener: TcpListener, app: Router) {
    loop {
        let (stream, addr) = match listener.accept().await {
            Ok(conn) => conn,
            Err(e) => {
                log::error!("Failed to accept connection: {}", e);
                continue;
            }
        };

        let tower_service = app.clone();

        tokio::spawn(async move {
            let io = TokioIo::new(stream);

            let hyper_service = hyper::service::service_fn(move |req| {
                let mut svc = tower_service.clone();
                async move { svc.call(req).await }
            });

            if let Err(err) = Builder::new(TokioExecutor::new())
                .serve_connection(io, hyper_service)
                .await
            {
                log::debug!("Connection closed from {}: {}", addr, err);
            }
        });
    }
}
