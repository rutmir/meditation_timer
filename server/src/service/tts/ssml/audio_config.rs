use serde::{Serialize, Deserialize};
use super::audio_encoding::AudioEncoding;

#[derive(Serialize, Deserialize, Debug)]
pub struct AudioConfig {
    #[serde(rename = "audioEncoding")]
    pub audio_encoding: AudioEncoding,
    #[serde(rename = "speakingRate", skip_serializing_if = "Option::is_none")]
    pub speaking_rate: Option<f32>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub pitch: Option<f32>,
    #[serde(rename = "volumeGainDb", skip_serializing_if = "Option::is_none")]
    pub volume_gain_db: Option<f32>,
    #[serde(rename = "sampleRateHertz", skip_serializing_if = "Option::is_none")]
    pub sample_rate_hertz: Option<u32>,
    #[serde(rename = "effectsProfileId", skip_serializing_if = "Option::is_none")]
    pub effects_profile_id: Option<Vec<String>>,
}

impl Clone for AudioConfig 
{
    fn clone(&self) -> Self {
        AudioConfig  {
            audio_encoding: self.audio_encoding.clone(),
            speaking_rate: self.speaking_rate.clone(),
            pitch: self.pitch.clone(),
            volume_gain_db: self.volume_gain_db.clone(),
            sample_rate_hertz: self.sample_rate_hertz.clone(),
            effects_profile_id: self.effects_profile_id.clone(),
        }
    }
}
