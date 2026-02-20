use std::sync::Mutex;

use super::config::Config;

pub struct AppState {
    pub counter: Mutex<i32>,
    pub config: Mutex<Config>,
}


