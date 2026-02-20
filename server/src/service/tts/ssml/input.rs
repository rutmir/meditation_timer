use serde::{Serialize, Deserialize};

use super::custom_pronunciation_params::CustomPronunciationParams;
use super::multi_speaker_markup::MultiSpeakerMarkup;

#[derive(Serialize, Deserialize, Debug)]
pub struct Input<'a> {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub ssml: Option<&'a str>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub text: Option<&'a str>,
    #[serde(rename = "customPronunciations", skip_serializing_if = "Option::is_none")]
    pub custom_pronunciations: Option<CustomPronunciationParams<'a>>,
    #[serde(rename = "multiSpeakerMarkup", skip_serializing_if = "Option::is_none")]
    pub multi_speaker_markup: Option<MultiSpeakerMarkup<'a>>,
}

impl<'a> Clone for Input<'a> 
{
    fn clone(&self) -> Self {
        Input  {
            ssml: self.ssml.clone(),
            text: self.text.clone(),
            custom_pronunciations: self.custom_pronunciations.clone(),
            multi_speaker_markup: self.multi_speaker_markup.clone(),
        }
    }
}
