use std::hash::Hash;
use serde::{Serialize, Deserialize};
use crate::entities::language::Language;

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct MeditationScriptInfo {
    pub timestamp: i64, 
    pub title: String,
    pub duration: u32,
    pub language: Language,
}

impl PartialEq for MeditationScriptInfo {
    fn eq(&self, other: &Self) -> bool {
        self.timestamp == other.timestamp &&self.language == other.language && self.duration == other.duration
    }
}

impl Eq for MeditationScriptInfo {}

impl Hash for MeditationScriptInfo {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        self.timestamp.hash(state);
        self.duration.hash(state);
        self.language.hash(state);
    }
}