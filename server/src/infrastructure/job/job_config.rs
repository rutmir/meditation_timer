use std::{env, sync::LazyLock};
use figment::{Figment, providers::{Format, Toml, Json, Env}};
use serde::Deserialize;

use crate::{entities::config::Config, pkg::figment_string};


#[derive(Deserialize, Debug)]
pub struct JobParameters {
    pub name: String,
    pub schedule: String,
    pub enabled: bool,
}

impl Clone for JobParameters
{
    fn clone(&self) -> Self {
        JobParameters {
            name: self.name.clone(),
            schedule: self.schedule.clone(),
            enabled: self.enabled.clone(),
        }
    }
}

#[derive(Deserialize, Debug)]
pub struct JobConfigPlane {
    #[serde(deserialize_with = "figment_string::deserialize_as_string")]
    pub version: String,
    pub daily_data: JobParameters,
    pub clean_data: JobParameters,
}

impl Clone for JobConfigPlane
{
    fn clone(&self) -> Self {
        JobConfigPlane {
            version: self.version.clone(),
            daily_data: self.daily_data.clone(),
            clean_data: self.clean_data.clone(),
        }
    }
}

#[derive(Deserialize, Debug)]
pub struct JobConfig {
    pub version: String,
    pub daily_data: JobParameters,
    pub clean_data: JobParameters,
    pub app_config: Config,
}

impl Clone for JobConfig
{
    fn clone(&self) -> Self {
        JobConfig {
            version: self.version.clone(),
            daily_data: self.daily_data.clone(),
            clean_data: self.clean_data.clone(),
            app_config: self.app_config.clone(),
        }
    }
}

impl Default for JobConfig {
    fn default() -> Self {
        let file_env = env::var("ENV").ok();
        let file_name = match file_env {
            Some(file_sufix) => format!("job_config.{}", file_sufix),
            None => "job_config".to_string(),
        };
        let figment = Figment::new()
        .merge(Toml::file(format!("{}.toml", file_name)))
        .merge(Env::prefixed("JOB_").split("_"))
        .join(Json::file(format!("{}.json", file_name)));
        
        match figment.extract::<JobConfigPlane>() {
            Ok(config) => {
                JobConfig {
                    version: config.version,
                    daily_data: config.daily_data,
                    clean_data: config.clean_data,
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

impl JobConfig {
    pub fn instance() -> JobConfig {
        static STATIC_INSTANCE: LazyLock<JobConfig> = LazyLock::new(JobConfig::default);
        STATIC_INSTANCE.clone()
    }
}
