use std::sync::{Arc, Mutex};
// use bb8::Pool;
// use bb8_redis::{bb8, redis::AsyncCommands, RedisConnectionManager};
use crate::{infrastructure::api::api_config::ApiConfig, service::data_cache::DataCache};

pub struct ApiState {
    pub config: Arc<Mutex<ApiConfig>>,
    // pub pool: Pool<RedisConnectionManager>,
    pub data_cache: DataCache,
}

impl ApiState {
    pub async fn new(config: ApiConfig) -> Self {
        // let connection_string = format!("redis://:{}@{}:{}", config.redis.password, config.redis.host, config.redis.port);
        // log::debug!("connection string: {}", connection_string);
        // let manager = RedisConnectionManager::new(connection_string).unwrap();
        // let pool = bb8::Pool::builder().build(manager).await.unwrap();
        // 
        // {
        //     // ping the database before starting
        //     let mut conn = pool.get().await.unwrap();
        //     conn.set_ex::<&str, &str, ()>("foo", "bar", 10).await.unwrap();
        //     let result: String = conn.get("foo").await.unwrap();
        //     assert_eq!(result, "bar");
        // 
        //     // populate API keys
        //     for key in config.api_keys.clone() {
        //         conn.set::<&str, &str, ()>(format!("api_key{}", key).as_str(), "true").await.unwrap();
        //     }
        // }

        let data_cache = DataCache::instance().await; 

        Self{ config: Arc::new(Mutex::new(config)), /* pool */ data_cache }
    }
}

impl Clone for ApiState
{
    fn clone(&self) -> Self {
        ApiState {
            config: self.config.clone(),
            // pool: self.pool.clone(),
            data_cache: self.data_cache.clone(),
        }
    }
}
