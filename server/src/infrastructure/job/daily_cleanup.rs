use std::{collections::HashMap, sync::Arc};
use chrono::{Duration, Utc};
use crate::{entities::language::Language, pkg::converters::build_millis_keys};
use super::job_state::JobState;

pub async fn daily_cleanup_job_handler(state: Arc<JobState>) {
    log::info!("Cron job {} running at: {:?}", state.config.lock().unwrap().clean_data.name, Utc::now());

    let terminator = (Utc::now() - Duration::days(7)).timestamp_millis();
    let mut key_for_delete = Vec::<String>::new();
    let mut cache = state.data_cache.clone();

    for language in Language::iterator() {
        let Some(redis_keys) = cache.get_redis_keys(Some(language), None).await else { return; };
        let (_, millis_to_key) = build_millis_keys(redis_keys);
        let millis_to_key = millis_to_key.into_iter().filter(|x| x.0 < terminator).collect::<HashMap<i64, String>>();

        for item in millis_to_key.into_iter() {
            let some_script = state.data_cache.get_script_local(item.1.clone()).await;
            if some_script.is_some() { key_for_delete.push(item.1); }
        } 
    }

    cache.remove_keys(key_for_delete).await;
 }