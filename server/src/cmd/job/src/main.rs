use meditimer_core::{logger, infrastructure::job};

#[tokio::main]
async fn main() {
    logger::configure_logger();
    if let Some(err) = job::start_jobs().await.err() {
        panic!("{}",err);
    }

    tokio::signal::ctrl_c().await.expect("failed to listen for ctrl-c");
    log::info!("shutting down");
}
