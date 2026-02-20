use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Copy, Clone)]
pub enum AudioEncoding {
    #[serde(rename = "AUDIO_ENCODING_UNSPECIFIED")]
    AudioEncodingUnspecified,
    #[serde(rename = "LINEAR16")]
    Linear16,
    #[serde(rename = "MP3")]
    Mp3,
    #[serde(rename = "OGG_OPUS")]
    OggOpus,
    #[serde(rename = "MULAW")]
    Mulaw,
    #[serde(rename = "ALAW")]
    Alaw,
    #[serde(rename = "PCM")]
    Pcm,
}
