#[cfg(test)]
mod tests {
    use meditimer_core::{logger, infrastructure::job};

    // fn setup() {
    //     // first method loaded in integration test, requires ENV env var
    //     dotenv::from_filename(format!(".env.{}", env::var("ENV").expect("ENV must be set"))).ok();
    // }

    #[tokio::test]
    async fn build_test() {
        // setup();
        logger::configure_logger(); 

        if let Some(_err) = job::start_jobs().await.err() {
            assert!(false);
            // panic!("{}",err);
        }

       tokio::time::sleep(std::time::Duration::from_secs(30)).await;
    }
}