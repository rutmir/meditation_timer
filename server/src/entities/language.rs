use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Copy, Clone, Hash, Eq, PartialEq)]
pub enum Language {
    #[serde(rename = "en")]
    English,
    #[serde(rename = "ru")]
    Russian,
    #[serde(rename = "es")]
    Spanish,
    #[serde(rename = "fr")]
    Franch,
}

impl Language {
    pub fn iterator() -> impl Iterator<Item = Language> {
        [Language::English, Language::Russian, Language::Spanish, Language::Franch].iter().copied()
    }
}