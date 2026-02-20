use std::{env, sync::LazyLock};
use chrono::Utc;
use gemini_rs::types::{Schema, Type};
use crate::entities::{language::Language, meditation_script::{MeditationScript, MeditationScriptDTO}, meditation_style::MeditationStyle};

fn build_schema(deep: u32) -> Schema {
    let deep = if deep > 7 {
        7
    } else if deep < 3 {
        3
    } else {
        deep
    };

    Schema {
        schema_type: Some(Type::Object),
        properties: Some([
            (
                "title".to_string(), 
                Schema{
                    schema_type: Some(Type::String),
                    description: Some("title for meditation".to_string()),
                    ..Default::default()
                }
            ),
            (
                "introduction".to_string(), 
                Schema{
                    schema_type: Some(Type::String),
                    description: Some("introdution before meditation".to_string()),
                    ..Default::default()
                }
            ),
            (
                "body".to_string(), 
                Schema{
                    schema_type: Some(Type::Array),
                    items: Some(Box::new(
                        Schema{
                            schema_type: Some(Type::Object),
                            properties: Some([
                                (
                                    "phase".to_string(),
                                    Schema {
                                        schema_type: Some(Type::Object),
                                        properties: Some([(
                                                "name".to_string(),
                                                Schema {
                                                    schema_type: Some(Type::String),
                                                    description: Some("mediation phase description".to_string()),
                                                    ..Default::default()
                                                },
                                            ),
                                            (
                                                "items".to_string(),
                                                Schema {
                                                    schema_type: Some(Type::Array),
                                                    items: Some(
                                                        Box::new(
                                                            Schema { 
                                                                schema_type: Some(Type::Object),
                                                                properties: Some([
                                                                    (
                                                                        "startTime".to_string(),
                                                                        Schema {
                                                                            schema_type: Some(Type::Integer),
                                                                            // format: Some("date-time".to_string()),
                                                                            description: Some("quantity seconds shift from meditation start".to_string()),
                                                                            ..Default::default()
                                                                        },
                                                                    ),
                                                                    (
                                                                        "instructions".to_string(),
                                                                        Schema {
                                                                            schema_type: Some(Type::String),
                                                                            ..Default::default()
                                                                        },
                                                                    )
                                                                    ]
                                                                    .into_iter()
                                                                    .collect(),),
                                                                required: Some(vec!["instructions".to_string(), "startTime".to_string()]),
                                                                // description: (), 
                                                                // max_items: (), 
                                                                min_items: Some( format!("{}", deep)),
                                                                ..Default::default() 
                                                            }
                                                        )
                                                    ),
                                                    ..Default::default()
                                                },
                                            ),]
                                            .into_iter()
                                            .collect(),),
                                        description: Some("mediation phase".to_string()),
                                        ..Default::default()
                                    },
                                ),
                            ]
                            .into_iter()
                            .collect(),),
                            ..Default::default()
                        })),
                    ..Default::default()
                }
            ),
            (
                "conclusion".to_string(), 
                Schema{
                    schema_type: Some(Type::String),
                    ..Default::default()
                }
            ),
        ]            
        .into_iter()
        .collect(),),
        required: Some(vec!["body".to_string(), "title".to_string(), "introduction".to_string(), "conclusion".to_string()]),
        ..Default::default()
    }
}

fn build_message(language: Language, duration: u32, _style: Option<MeditationStyle>) -> String {
    match language {
        Language::English => format!("{} minute guided meditation detailed script", duration),
        Language::Russian => format!("подробный сценарий {}-минутной медитации с гидом", duration),
        Language::Spanish => format!("guión detallado de una meditación guiada de {} minutos", duration),
        Language::Franch => format!("script détaillé de méditation guidée de {} minutes", duration),
    }
}
pub struct GeminiService {
    api_key: String,
    model: String
}

impl Default for GeminiService {
    fn default() -> Self {
        let gemini_api_key = env::var("GEMINI_APIKEY").expect("expected 'GEMINI_APIKEY'");
        let gemini_model = env::var("GEMINI_MODEL").expect("expected 'GEMINI_MODEL'");
        Self { api_key: gemini_api_key, model: gemini_model }
    }
}

impl Clone for GeminiService {
    fn clone(&self) -> Self {
        Self { api_key: self.api_key.clone(), model: self.model.clone() }
    }
}

impl GeminiService {
    pub fn instance() -> GeminiService {
        static STATIC_INSTANCE: LazyLock<GeminiService> = LazyLock::new(GeminiService::default);
        STATIC_INSTANCE.clone()
    }

    pub async fn get_meditation_script(&self,  language: Language, duration: u32, style: Option<MeditationStyle>) -> Option<MeditationScript> {
        let client = gemini_rs::Client::new(self.api_key.clone());
        let message = build_message(language, duration, style); 

        // let ip = reqwest::Client::new().get("https://ipinfo.io");
        // match ip.send().await{
        //     Ok(data) => log::debug!("--> IP: {}", data.text().await.unwrap()),
        //     Err(e) => log::debug!("--> ERR : {}", e),
        // }

        // match client.models().await {
        //     Ok(models) => {
        //         log::info!("{models:#?}");
        //     },
        //     Err(e) => {
        //         log::error!("gemini models error: {}", e.to_string());
        //         return Err(ApiError::InternalServerError(e.to_string(), None));
        //     },
        // };
        
        let deep = duration/10 + 1;

        let data = match client.chat(&self.model)
        .to_json()
        .response_schema(build_schema(deep))            
        .json::<MeditationScriptDTO>(&message)
        .await
        {
            Ok(result) => {
                Some(result)
            },
            Err(e) => {
                log::error!("--> ERR : {}", e);
                None
            },
        };

        if let Some(data) = data {
            return Some(data.to_metitation_script(Utc::now().timestamp_millis()));
        }

        // match client.chat(&self.model)
        // .to_json()
        // .response_schema(build_schema(deep))            
        // .json::<serde_json::Value>(&message)
        // .await 
        // {
        //     Ok(result) => log::debug!("--> CHAT: {}", result),
        //     Err(e) => log::debug!("--> ERR : {}", e),
        // }
         
        None
    }

    //pub async fn get_limits(&self) {
    //    let client = gemini_rs::Client::new(self.api_key.clone());
    //
    //    match client.generate_content(model). .chat(&self.model)
    //    //.to_json()
    //    //.json::<serde_json::Value>(&message)
    //    .await
    //    {
    //        Ok(result) => log::debug!("--> CHAT: {}", result),
    //        Err(e) => log::debug!("--> ERR : {}", e),
    //    }
    //}
}

