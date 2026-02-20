use serde::{Serialize, Deserialize};
use super::{input::Input, audio_config::AudioConfig, 
    voice_selection_params::VoiceSelectionParams, advanced_voice_options::AdvancedVoiceOptions};

#[derive(Serialize, Deserialize, Debug)]
pub struct Request<'a>  {
    #[serde(borrow)]
    pub input: Input<'a>,
    #[serde(rename = "audioConfig")]
    pub audio_config: AudioConfig,
    pub voice: VoiceSelectionParams<'a>,
    #[serde(rename = "advancedVoiceOptions", skip_serializing_if = "Option::is_none")]
    pub advanced_voice_options: Option<AdvancedVoiceOptions>,
}

impl<'a> Clone for Request<'a> 
{
    fn clone(&self) -> Self {
        Request  {
            input: self.input.clone(),
            audio_config: self.audio_config.clone(),
            voice: self.voice.clone(),
            advanced_voice_options:self.advanced_voice_options.clone(),
        }
    }
}
