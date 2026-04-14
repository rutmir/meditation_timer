use std::sync::{Arc, Mutex};
use bb8::Pool;
use bb8_redis::{bb8, redis::AsyncCommands, RedisConnectionManager};
use reqwest::Client;
use crate::{infrastructure::api::api_config::ApiConfig, service::data_cache::DataCache};

pub struct ApiState {
    pub config: Arc<Mutex<ApiConfig>>,
    /// Shared Redis pool used for ROEX balance / price caching.
    pub pool: Pool<RedisConnectionManager>,
    /// Shared HTTP client for Jupiter Price API and Solana JSON-RPC calls.
    pub http_client: Client,
    pub data_cache: DataCache,
}

impl ApiState {
    pub async fn new(config: ApiConfig) -> Self {
        let redis = &config.app_config.redis;
        let connection_string = format!(
            "redis://:{}@{}:{}",
            redis.password, redis.host, redis.port
        );
        log::debug!("api redis connection: redis://:<password>@{}:{}", redis.host, redis.port);

        let manager = RedisConnectionManager::new(connection_string).unwrap();
        let pool = bb8::Pool::builder().build(manager).await.unwrap();

        {
            // Smoke-test the connection before serving requests.
            let mut conn = pool.get().await.unwrap();
            conn.set_ex::<&str, &str, ()>("api_ping", "pong", 10).await.unwrap();
            let result: String = conn.get("api_ping").await.unwrap();
            assert_eq!(result, "pong");
        }

        let data_cache = DataCache::instance().await;
        let http_client = Client::new();

        Self {
            config: Arc::new(Mutex::new(config)),
            pool,
            http_client,
            data_cache,
        }
    }
}

impl Clone for ApiState {
    fn clone(&self) -> Self {
        ApiState {
            config: self.config.clone(),
            pool: self.pool.clone(),
            http_client: self.http_client.clone(),
            data_cache: self.data_cache.clone(),
        }
    }
}
