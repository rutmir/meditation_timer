use std::sync::{Arc, atomic::{AtomicBool, Ordering}};
use meditimer_core::{logger, infrastructure::job};


#[tokio::main]
async fn main() {
    logger::configure_logger();
    if let Some(err) = job::start_jobs().await.err() {
        panic!("{}",err);
    }

    let running = Arc::new(AtomicBool::new(true));
    let r = running.clone();

    ctrlc::set_handler(move || {
        r.store(false, Ordering::SeqCst);
    }).expect("Error setting Ctrl-C handler");

    // let path = std::env::current_dir().unwrap();
    // println!("The current directory is {}", path.display());

    println!("Waiting for Ctrl-C...");
    while running.load(Ordering::SeqCst) {}
    println!("Got it! Exiting...");
}
