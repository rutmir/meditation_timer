use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Debug)]
pub struct VoiceCloneParams<'a> {
    #[serde(rename = "voiceCloningKey")]
    pub voice_cloning_key: &'a str,
}

impl<'a> Clone for VoiceCloneParams<'a> 
{
    fn clone(&self) -> Self {
        VoiceCloneParams  {
            voice_cloning_key: self.voice_cloning_key,
        }
    }
}
