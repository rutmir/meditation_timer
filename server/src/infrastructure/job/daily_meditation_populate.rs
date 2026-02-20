use std::sync::Arc;
use chrono::{DateTime, Utc};
use crate::pkg::converters::build_millis_keys;
use crate::{entities::{language::Language, meditation_script::{MeditationScript, ScriptItem}}, service::{data_cache::DataCache, gemini::GeminiService, tts}};
use super::job_state::JobState;

struct WorkItem {
    pub language: Language, 
    pub duration: u32,
    pub redis_key: Option<String>, 
}

async fn process_tts(mut cache: DataCache, mut script: MeditationScript, language: Language, duration: u32) {
    // introduction
    if !script.introduction.is_empty() && script.introduction_audio.as_ref().is_none() {
        let data = ScriptItem{instructions: script.introduction.clone(), audio: None, start_time: 0};
        let (ok, mp3_string_option) = tts::convert_text_to_speach(&data, language).await;
        if ok {
            script.introduction_audio = mp3_string_option;
        } else {
            cache.set_script(script, language, duration).await;
            return;
        }
    }

    // conclusion
    if !script.conclusion.is_empty() && script.conclusion_audio.as_ref().is_none() {
        let data = ScriptItem{instructions: script.conclusion.clone(), audio: None, start_time: 0};
        let (ok, mp3_string_option) = tts::convert_text_to_speach(&data, language).await;
        if ok {
            script.conclusion_audio = mp3_string_option;
        } else {
            cache.set_script(script, language, duration).await;
            return;
        }
    }

    // phases
    for item in script.body.iter_mut() {
        if item.phase.is_valid_source() && !item.phase.is_valid() {
            for element in item.phase.items.iter_mut() {
                if element.is_valid_source() && !element.is_valid() {
                    let (ok, mp3_string_option) = tts::convert_text_to_speach(element, language).await;
                    if ok {
                        element.audio = mp3_string_option;
                    } else {
                        cache.set_script(script, language, duration).await;
                        return;
                    }
                }
            }
        }
    }

    cache.set_script(script, language, duration).await;
}

async fn process_new_script(cache: DataCache, language: Language, duration: u32) {
    let gemini = GeminiService::instance();
    let Some(script) = gemini.get_meditation_script(language, duration, None).await else {
        return;
    };

    process_tts(cache, script, language, duration).await;
}

async fn process_tts_script(cache: DataCache, language: Language, duration: u32, redis_key: String) {
    if let Some(script) = cache.get_script_local(redis_key).await {
        process_tts(cache, script, language, duration).await;
    };    
}

async fn need_tts_meditation(cache: DataCache, language: Language, duration: u32) -> Option<String> {
    let Some(keys) = cache.get_cached_keys(Some(language), Some(duration)).await else {
        return None;
    };
    let (mut millis, mut millis_to_key) = build_millis_keys(keys);

    if millis.is_empty() {
        return None;
    }

    let Some(last_millis) = millis.pop() else { 
        return None;
    };

    let Some(redis_key) = millis_to_key.remove(&last_millis) else {
        return None;
    };

    let Some(script) = cache.get_script_local(redis_key.clone()).await else {
        return None;
    };

    if script.is_valid_source() && !script.is_valid() {
        return Some(redis_key);
    } 

    None
}

async fn need_new_meditation(cache: DataCache, language: Language, duration: u32) -> bool {
    let Some(keys) = cache.get_cached_keys(Some(language), Some(duration)).await else {
        return true;
    };
    let (mut millis, _) = build_millis_keys(keys);

    if millis.is_empty() {
        return true;
    }

    let Some(last_millis) = millis.pop() else { 
        return true;
    };

    let Some(at) = DateTime::from_timestamp_millis(last_millis) else {
        return true;
    };  

    if (Utc::now() - at).num_days() > 0 {
        return true;
    }

    false
}

pub async fn daily_meditation_job_handler(state: Arc<JobState>) {
    log::info!("Cron job {} running at: {:?}", state.config.lock().unwrap().daily_data.name, Utc::now());
    
    let mut work_items = Vec::<WorkItem>::new();
    let global_durations = state.config.lock().unwrap().app_config.durations.clone();
    
    for language in Language::iterator() {
        log::debug!("-->> Language: {:?}", language);
        for duration in global_durations.iter() {
            log::debug!("-->> Duration: {}", *duration);
            if need_new_meditation(state.data_cache.clone(), language, *duration).await {
                log::debug!("-->> Need New: Language: {:?} {}", language, *duration);
                work_items.push(WorkItem{language, duration: *duration, redis_key: None});
                break;
            }
        }

        if !work_items.is_empty() {
            break;
        }
    }

    if let Some(work_item) = work_items.pop() {
        log::debug!("-->> process_new_script: {:?}, {}", work_item.language, work_item.duration);
        process_new_script(state.data_cache.clone(), work_item.language, work_item.duration).await;
        return;
    }

    work_items.clear();

    for language in Language::iterator() {
        for duration in global_durations.iter() {
            if let Some(redis_key) = need_tts_meditation(state.data_cache.clone(), language, *duration).await {
                work_items.push(WorkItem{language, duration: *duration, redis_key: Some(redis_key)});
                break;
            }
        }

        if !work_items.is_empty() {
            break;
        }
    }

    if let Some(work_item) = work_items.pop() {
        process_tts_script(state.data_cache.clone(), work_item.language, work_item.duration, work_item.redis_key.unwrap()).await;
        return;
    }
}
