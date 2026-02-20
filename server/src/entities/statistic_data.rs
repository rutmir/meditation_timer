use serde::{Serialize, Deserialize};
use crate::entities::{language::Language, statistic::Statistic};

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct StatisticData {
    #[serde(rename = "stat")]
    pub statistic: Statistic,
    #[serde(skip_serializing_if = "Option::is_none", rename = "lang")]
    pub language: Option<Language>,
    #[serde(skip_serializing_if = "Option::is_none", rename = "dur")]
    pub duration: Option<u32>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub month: Option<u32>,
    pub count: u32,
}