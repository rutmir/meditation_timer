use std::{collections::{HashMap, HashSet}, sync::{atomic::{AtomicBool, Ordering}, Arc}};
use chrono::{DateTime, Datelike, Utc};
use bb8::Pool;
use bb8_redis::{bb8, redis::AsyncCommands, RedisConnectionManager};
use tokio::sync::{OnceCell, RwLock};
use crate::{
    entities::{
        config::Config, 
        language::Language, 
        meditation_script::MeditationScript, 
        meditation_script_info::MeditationScriptInfo, 
        statistic::Statistic, statistic_data::StatisticData }, 
    pkg::converters::build_millis_keys};

const _KEY_LAST_UPDATE_AT: &str = "ms_last_update_at";
const _LAZY_LOAD_MINUTES_FRAME: i64 = 15;

fn build_redis_script_key (language: Option<Language>, duration: Option<u32>) -> String {
    if let Some(language) = language {
        return match language {
            Language::English => format!("ms_en_{}", duration.map_or("".to_string(), |x| x.to_string())),
            Language::Russian => format!("ms_ru_{}", duration.map_or("".to_string(), |x| x.to_string())),
            Language::Spanish => format!("ms_es_{}", duration.map_or("".to_string(), |x| x.to_string())),
            Language::Franch => format!("ms_fr_{}", duration.map_or("".to_string(), |x| x.to_string())),
        };
    } 

    "ms_".to_string()
}

fn build_redis_stat_key (stat: Statistic, language: Option<Language>, duration: Option<u32>, month: Option<u32>) -> String {
    let key = if let Some(language) = language {
        let sub_key = if let Some(duration) = duration {
            format!("{}_{}", duration, month.map_or("".to_string(), |x| format!("{:0width$}", x, width = 2)))
        } else { "".to_string() };

        match language {
            Language::English => format!("stat_en_{}", sub_key),
            Language::Russian => format!("stat_ru_{}", sub_key),
            Language::Spanish => format!("stat_es_{}", sub_key),
            Language::Franch => format!("stat_fr_{}", sub_key),
        }
    } else { "".to_string() };

    match stat {
        Statistic::View => format!("stat_view_{}", key),
        Statistic::Get => format!("stat_get_{}", key),
    }
}

fn need_load(cache_update_at: Option<DateTime<Utc>>, redis_updated_at: DateTime<Utc>) -> bool {
    if let Some(cache_update_at) = cache_update_at {
        return redis_updated_at > cache_update_at;
    }

    true
}

struct DataCacheInner {
    pub languages: HashSet<Language>,
    pub language_durations: HashMap<Language, HashSet<u32>>,
    pub key_script_to_lang_dur: HashMap<String, (Language, u32)>,
    pub key_to_script_key: HashMap<String, String>,
    pub scripts: HashMap<String, MeditationScript>,
    pub pool: Pool<RedisConnectionManager>,
    pub last_update_at: Option<DateTime<Utc>>,
}

impl DataCacheInner {
    
    fn inner_languages(&self) -> HashSet<Language> {
        self.key_script_to_lang_dur.values().fold(
            HashSet::<Language>::new(),
            |mut hs, x | -> HashSet<Language> {
                hs.insert(x.0);
                hs
            })
    }

    fn inner_language_durations(&self) -> HashMap<Language, HashSet<u32>> {
        let mut out = HashMap::<Language, HashSet<u32>>::new();
        let languages = self.inner_languages();

        for language in languages {
            let mut durations = HashSet::<u32>::new();
            for kv in self.key_script_to_lang_dur.iter() {
                if kv.1.0 != language {
                    continue;
                }

                durations.insert(kv.1.1);
            }

            out.insert(language, durations);
        }

        out
    }

    fn set_script_inner(&mut self, script: MeditationScript, redis_key: String, language: Language, duration: u32) -> bool {
        let is_script_valid = script.is_valid();
        let general_key = build_redis_script_key(Some(language), Some(duration));
        _ = self.scripts.insert(redis_key.clone(), script);

        if !is_script_valid { return false; }

        _ = self.key_script_to_lang_dur.insert(redis_key.clone(), (language, duration));
        _ = self.key_to_script_key.insert(general_key, redis_key);

        true
    }

    fn need_reload_script(&self, key: &str) -> bool {
        let Some(script) = self.scripts.get(key) else { return true; }; 
        !script.is_valid()
    }

    async fn fetch_script_from_redis(&mut self, redis_key: &str) -> Option<MeditationScript> {
        let mut conn = match self.pool.get().await {
            Ok(conn) => conn,
            Err(e) => {
                log::error!("{}", e);
                return None;
            }
        };
        match conn.get::<&str, MeditationScript>(redis_key).await {
            Ok(script) => Some(script),
            Err(e) => {
                log::error!("{}", e);
                None
            }
        }
    }

    async fn upload_script_inner(&mut self, language: Language, duration: u32) -> bool {
        let Some(keys) = self.get_redis_keys(Some(language), Some(duration)).await else { return false; };
        let (mut millis, millis_to_key) = build_millis_keys(keys);
        millis.sort();

        // take the last script 
        let Some(key_millis) = millis.pop() else { return false; };
        let Some(redis_key) = millis_to_key.get(&key_millis) else { return false; };
        if !self.need_reload_script(redis_key) { return false; }

        let Some(script) = self.fetch_script_from_redis(redis_key).await else { return false; };

        if self.set_script_inner(script, redis_key.to_string(), language, duration) { return true; }

        // the last script is not completed, try next
        let Some(key_millis) = millis.pop() else { return true; };
        let Some(redis_key) = millis_to_key.get(&key_millis) else { return true; };
        if !self.need_reload_script(redis_key) { return true; }

        let Some(script) = self.fetch_script_from_redis(redis_key).await else { return true; };

        if script.is_valid() {
            _ = self.set_script_inner(script, redis_key.to_string(), language, duration);
        }

        true
    } 

    async fn upload_script(&mut self, language: Language, duration: u32) {
        let need_collapse = self.upload_script_inner(language, duration).await;
        if need_collapse {
            self.collapse(language, duration).await;
        }
    }

    async fn get_last_updated_mills(&mut self) -> i64 {
        let mut conn = match self.pool.get().await {
            Ok(conn) => conn,
            Err(e) => {
                log::error!("{}", e);
                panic!("{}", e);
            }
        };

        match conn.get::<&str, i64>(_KEY_LAST_UPDATE_AT).await {
            Ok(millis) => millis,
            // Ok(raw) => {
            //     match raw.parse::<u32>() {
            //         Ok(result) => result,
            //         Err(e) => {
            //             log::error!("{}", e);
            //             panic!("{}", e);
            //         }
            //     }
            // },
            Err(e) => {
                log::error!("{}", e);
                0
                // panic!("{}", e);
            }
        }
    }

    fn remove_key(&mut self, redis_key: String) {
        _ = self.key_script_to_lang_dur.remove(&redis_key);
        let keys = self.key_to_script_key.iter().fold(
            Vec::<String>::new(), 
            |mut v, x| -> Vec<String> {
                if *x.0 == redis_key {
                    v.push(x.0.to_string());
                }

                v
            });
        for key in keys.into_iter() {
            _ = self.key_to_script_key.remove(&key);
        }

        _ = self.scripts.remove(&redis_key);
    }

    async fn collapse(&mut self, language: Language, duration: u32) {
        let pattern = build_redis_script_key(Some(language), Some(duration));
        let keys = self.scripts.keys().fold(
            HashSet::<String>::new(), 
            |mut hs, x| -> HashSet<String> {
                if x.starts_with(&pattern) {
                    hs.insert(x.to_string());
                }

                hs
            });
        if keys.is_empty() {
            return;
        } 

        let (mut millis, millis_to_key) = build_millis_keys(keys);
        millis.sort();

        let Some(m) = millis.pop() else { return; };
        // m - date of the last saved script for target language 
        let Some(key) = millis_to_key.get(&m) else { return; };
        if let Some(script) = self.scripts.get(key) {
            if script.is_valid() {
                // last impoted script is valid we can remove other scripts
                let to_remove = millis.iter().fold(Vec::<String>::new(), |mut v, x| -> Vec<String>{
                    if let Some(key) = millis_to_key.get(x) {
                        v.push(key.to_string());
                    }

                    v
                });

                self.remove_keys(to_remove).await;
                return;
            }
        }

        if millis.is_empty() {
            return;
        }

        // last saved key not valid 

        millis.sort_by(|a, b| b.cmp(a));
        let mut keys_to_remove = Vec::<String>::new();
        let mut remove_all = false;

        for item in millis {
            let Some(key) = millis_to_key.get(&item) else { continue; };
            if remove_all {
                keys_to_remove.push(key.to_string());
            } else {
                if let Some(script) = self.scripts.get(key) {
                    if script.is_valid() {
                        remove_all = true;
                    }
                } else {
                    keys_to_remove.push(key.to_string());
                }
            }
        }

        self.remove_keys(keys_to_remove).await;
    }

    pub async fn log_statistic(&self, stat: Statistic, language: Language, duration: u32) {
        let mut conn = match self.pool.get().await {
            Ok(conn) => conn,
            Err(e) => {
                log::error!("{}", e);
                return;
            }
        };

        let redis_key = build_redis_stat_key(stat, Some(language), Some(duration), Some(Utc::now().month()));

        _ = conn.incr::<&str, u32, u32>(&redis_key, 1).await;
    }

    pub async fn remove_keys(&mut self, redis_keys: Vec<String>) {
        if redis_keys.is_empty() {
            return;
        }

        let mut remove_from_redis = Vec::<String>::new();

        for key in redis_keys.into_iter() {
            self.remove_key(key.clone());
            remove_from_redis.push(key);
        }

        let mut conn = match self.pool.get().await {
            Ok(conn) => conn,
            Err(e) => {
                log::error!("{}", e);
                return;
            }
        };

        for redis_key in remove_from_redis.iter() {
            _ = conn.del::<&str, MeditationScript>(redis_key).await;
        }
    }

    pub fn get_languages(&self) -> HashSet<Language> {
        self.languages.clone()
    }

    pub fn get_durations_for_lang(&self, language: Language) -> Option<HashSet<u32>> {
        if let Some(data) = self.language_durations.get(&language) {
            return Some(data.clone());
        }

        None
    }

    // return full script
    pub fn get_script(&self, language: Language, duration: u32, full: bool) -> Option<MeditationScript> {
        let key = build_redis_script_key(Some(language), Some(duration));
        let Some(redis_key) = self.key_to_script_key.get(&key) else { return None; };

        if let Some(data) = self.scripts.get(redis_key) {
            return Some(if full {data.clone()} else {data.to_script()});
        }

        None
    }

    // get any script directly by redis key
    pub fn get_script_local(&self, key: String) -> Option<MeditationScript> {
        if let Some(data) = self.scripts.get(&key) {
            return Some(data.clone());
        }

        None
    }

    pub async fn set_script(&mut self, script: MeditationScript, language: Language, duration: u32) {
        let redis_key = format!("{}_{}", build_redis_script_key(Some(language), Some(duration)), script.timestamp);
        _ = self.set_script_inner(script.clone(), redis_key.clone(), language, duration);

        if let Some(mut conn) = self.pool.get().await.ok() {
            let _ = conn.set::<&str, &MeditationScript, ()>(&redis_key, &script).await;
            let _ = conn.set::<&str, i64, ()>(_KEY_LAST_UPDATE_AT, Utc::now().timestamp_millis()).await;
        } 

        self.collapse(language, duration).await;
    }

    pub async fn lazy_load(&mut self) {
        let millis = self.get_last_updated_mills().await;

        if let Some(updated_at) = DateTime::from_timestamp_millis(millis) {
            if need_load(self.last_update_at, updated_at) {
                let config = Config::instance();

                // English
                for duration in config.durations.iter() {
                    self.upload_script(Language::English, *duration).await;
                }

                // Spanish
                for duration in config.durations.iter() {
                    self.upload_script(Language::Spanish, *duration).await;
                }

                // Franch
                for duration in config.durations.iter() {
                    self.upload_script(Language::Franch, *duration).await;
                }

                // Russian
                for duration in config.durations.iter() {
                    self.upload_script(Language::Russian, *duration).await;
                }

                // populate service tables
                let lang_durations = self.inner_language_durations();
                let languages = lang_durations.iter().fold(
                    HashSet::<Language>::new(), 
                    |mut hs, x| -> HashSet<Language> {
                        hs.insert(*x.0);
                        hs
                    });

                self.language_durations = lang_durations;
                self.languages = languages;
                self.last_update_at = Some(Utc::now());
            }
        }
    }

    pub async fn get_redis_keys(&self, language: Option<Language>, duration: Option<u32>) -> Option<HashSet<String>> {
        let pattern = format!("{}*", build_redis_script_key(language, duration));
        let mut conn = match self.pool.get().await {
            Ok(conn) => conn,
            Err(e) => {
                log::error!("{}", e);
                return None;
            }
        };

        if let Some(mut data) = conn.keys::<&str, Vec<String>>(&pattern).await.ok() {
            data.sort();
            return Some(HashSet::from_iter(data.iter().cloned()));
        }

        None
    }

    pub fn get_cached_keys(&self, language: Option<Language>, duration: Option<u32>) -> Option<HashSet<String>> {
        let pattern = build_redis_script_key(language, duration);
        let keys = self.scripts.keys().fold(
            HashSet::<String>::new(),
            |mut hs, x| -> HashSet<String> {
                if x.starts_with(&pattern) {
                    hs.insert(x.to_string());
                }
                hs
            });

        if keys.is_empty() { return None; }

        Some(keys)
    }

    pub fn get_script_info_list(&self, language: Language) -> Option<HashSet<MeditationScriptInfo>> {
        let Some(durations) = self.get_durations_for_lang(language) else { return None; };

        let out = durations.into_iter().fold(
            HashSet::<MeditationScriptInfo>::new(), 
            |mut hs, x| -> HashSet<MeditationScriptInfo> {
                if let Some(script) = self.get_script(language, x, false) {
                    hs.insert(MeditationScriptInfo{
                        timestamp: script.timestamp,
                        title: script.title,
                        duration: x,
                        language: language,
                    });
                }

                hs
            });

        if out.is_empty() {
            return None;
        }

        Some(out)
    }

    // pub fn get_statistic(&self, stat: Statistic, language: Option<Language>, duration: Option<u32>, month: Option<u32>) -> Vec<StatisticData> {
    //     
    // }
}

pub struct DataCache {
    inner: Arc<RwLock<DataCacheInner>>,
    readiness: Arc::<AtomicBool>
}

static ONCE: OnceCell<DataCache> = OnceCell::const_new();

impl Clone for DataCache {
    fn clone(&self) -> Self {
        Self { inner: self.inner.clone() , readiness: self.readiness.clone() }
    }
}

impl DataCache {
    pub async fn instance() -> DataCache {
        let data = ONCE.get_or_init(|| async {
            let config = Config::instance();
            let connection_string = format!("redis://:{}@{}:{}", config.redis.password, config.redis.host, config.redis.port);
            log::debug!("connection string: {}", connection_string);
            let manager = RedisConnectionManager::new(connection_string).unwrap();
            let pool = bb8::Pool::builder().build(manager).await.unwrap();

            {
                // ping the database before starting
                let mut conn = pool.get().await.unwrap();
                conn.set_ex::<&str, &str, ()>("data_cache_foo", "data_cache_bar", 10).await.unwrap();
                let result: String = conn.get("data_cache_foo").await.unwrap();
                assert_eq!(result, "data_cache_bar");
            }

            let mut out = DataCache { inner: Arc::new(RwLock::new(
                DataCacheInner {
                    languages: HashSet::new(),
                    language_durations: HashMap::new(),
                    key_script_to_lang_dur: HashMap::new(),
                    key_to_script_key: HashMap::new(),
                    scripts: HashMap::new(),
                    pool: pool,
                    last_update_at: None,

                })),
                readiness: Arc::new(AtomicBool::new(false)),
            };

            out.lazy_load().await;

            out
        }).await;

        data.clone()
    }

    pub async fn get_languages(&self) -> HashSet<Language> {
        self.inner.read().await.get_languages()
    }

    pub async fn get_durations_for_lang(&self, language: Language) -> Option<HashSet<u32>> {
        self.inner.read().await.get_durations_for_lang(language)
    }

    pub async fn get_script(&self, language: Language, duration: u32) -> Option<MeditationScript> {
        let inner = self.inner.read().await;
        let task = inner.log_statistic(Statistic::View, language, duration);
        let out = inner.get_script(language, duration, false);
        task.await;
        
        out
    }

    pub async fn get_meditation(&self, language: Language, duration: u32) -> Option<MeditationScript> {
        let inner = self.inner.read().await;
        let task = inner.log_statistic(Statistic::Get, language, duration);
        let out = inner.get_script(language, duration, true);
        task.await;

        out
    }

    pub async fn set_script(&mut self, script: MeditationScript, language: Language, duration: u32) {
        self.readiness.store(false, Ordering::SeqCst);
        self.inner.write().await.set_script(script, language, duration).await;
        self.readiness.store(true, Ordering::SeqCst);
    }

    pub async fn get_script_local(&self, key: String) -> Option<MeditationScript> {
        self.inner.read().await.get_script_local(key)
    }

    pub async fn lazy_load(&mut self) {
        self.readiness.store(false, Ordering::SeqCst);
        self.inner.write().await.lazy_load().await;
        self.readiness.store(true, Ordering::SeqCst);
    }

    pub async fn remove_keys(&mut self, redis_keys: Vec<String>) {
        self.readiness.store(false, Ordering::SeqCst);
        self.inner.write().await.remove_keys(redis_keys).await;
        self.readiness.store(true, Ordering::SeqCst);
    }

    pub async fn get_redis_keys(&self, language: Option<Language>, duration: Option<u32>) -> Option<HashSet<String>> {
        self.inner.read().await.get_redis_keys(language, duration).await
    }

    pub async fn get_cached_keys(&self, language: Option<Language>, duration: Option<u32>) -> Option<HashSet<String>> {
        self.inner.read().await.get_cached_keys(language, duration)
    }

    pub async fn get_script_info_list(&self, language: Language) -> Option<HashSet<MeditationScriptInfo>> {
        self.inner.read().await.get_script_info_list(language)
    }

    pub fn is_ready(&self) -> bool {
        self.readiness.load(Ordering::SeqCst)
    }
}
