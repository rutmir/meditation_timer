use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Copy, Clone)]
pub enum SsmlVoiceGender {
    #[serde(rename = "SSML_VOICE_GENDER_UNSPECIFIED")]
    SsmlVoiceGenderUnspecified,
    #[serde(rename = "MALE")]
    Male,
    #[serde(rename = "FEMALE")]
    Female,
    #[serde(rename = "NEUTRAL")]
    Neutral,
}
