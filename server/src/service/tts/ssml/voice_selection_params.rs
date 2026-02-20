use serde::{Serialize, Deserialize};
use super::voice_clone_params::VoiceCloneParams;
use super::custom_voice_params::CustomVoiceParams;
use super::ssml_voice_gender::SsmlVoiceGender;

#[derive(Serialize, Deserialize, Debug)]
pub struct VoiceSelectionParams<'a> {
    #[serde(rename = "languageCode")]
    pub language_code: &'a str,
    pub name: &'a str,
    #[serde(rename = "ssmlGender", skip_serializing_if = "Option::is_none")]
    pub ssml_gender: Option<SsmlVoiceGender>,
    #[serde(rename = "customVoice", skip_serializing_if = "Option::is_none")]
    pub custom_voice: Option<CustomVoiceParams<'a>>,
    #[serde(rename = "voiceClone", skip_serializing_if = "Option::is_none")]
    pub voice_clone: Option<VoiceCloneParams<'a>>,
    #[serde(rename = "modelName", skip_serializing_if = "Option::is_none")]
    pub model_name: Option<&'a str>,
}

impl<'a> Clone for VoiceSelectionParams<'a> 
{
    fn clone(&self) -> Self {
        VoiceSelectionParams  {
            language_code: self.language_code,
            name: self.name,
            ssml_gender: self.ssml_gender.clone(),
            custom_voice: self.custom_voice.clone(),
            voice_clone: self.voice_clone.clone(),
            model_name: self.model_name.clone(),
        }
    }
}
