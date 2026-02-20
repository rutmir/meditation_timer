use std::{env, sync::LazyLock};
use figment::{Figment, providers::{Format, Toml, Json, Env}};
use serde::Deserialize;

use crate::{entities::config::Config, pkg::figment_string};

#[derive(Deserialize, Debug)]
pub struct ApiConfigPlane {
    #[serde(deserialize_with = "figment_string::deserialize_as_string")]
    pub version: String,
    pub api_keys: Vec<String>,
}

impl Clone for ApiConfigPlane
{
    fn clone(&self) -> Self {
        ApiConfigPlane {
            version: self.version.clone(),
            api_keys: self.api_keys.clone(),
        }
    }
}

#[derive(Deserialize, Debug)]
pub struct ApiConfig {
    pub version: String,
    pub api_keys: Vec<String>,
    pub app_config: Config,
}

impl Clone for ApiConfig
{
    fn clone(&self) -> Self {
        ApiConfig {
            version: self.version.clone(),
            api_keys: self.api_keys.clone(),
            app_config: self.app_config.clone(),
        }
    }
}

impl Default for ApiConfig {
    fn default() -> Self {
        let file_env = env::var("ENV").ok();
        let file_name = match file_env {
            Some(file_sufix) => format!("api_config.{}", file_sufix),
            None => "api_config".to_string(),
        };
        let figment = Figment::new()
        .merge(Toml::file(format!("{}.toml", file_name)))
        .merge(Env::prefixed("API_").split("_"))
        .join(Json::file(format!("{}.json", file_name)));
        
        match figment.extract::<ApiConfigPlane>() {
            Ok(config) => {
                ApiConfig {
                    version: config.version,
                    api_keys: config.api_keys,
                    app_config: Config::instance(), 
                }
            },
            Err(e) => {
                log::error!("{}", e);
                panic!("{}", e);
            }
        }
    }
}

impl ApiConfig {
    pub fn instance() -> ApiConfig {
        static STATIC_INSTANCE: LazyLock<ApiConfig> = LazyLock::new(ApiConfig::default);
        STATIC_INSTANCE.clone()
    }
}
