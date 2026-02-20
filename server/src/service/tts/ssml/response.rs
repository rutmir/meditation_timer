use serde::{Serialize, Deserialize};
use super::audio_config::AudioConfig;

#[derive(Serialize, Deserialize, Debug)]
pub struct Response {
    #[serde(rename = "audioContent")]
    pub audio_content: String, // base64-encoded string.
    #[serde(rename = "audioConfig")] // v1beta1
    pub audio_config: Option<AudioConfig>,
    // "timepoints": [],

}