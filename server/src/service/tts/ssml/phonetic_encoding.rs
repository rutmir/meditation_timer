use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Copy, Clone)]
pub enum PhoneticEncoding {
     #[serde(rename = "PHONETIC_ENCODING_UNSPECIFIED")]
    PhoneticEncodingUnspecified,
     #[serde(rename = "PHONETIC_ENCODING_IPA")]
    PhoneticEncodingIpa,
     #[serde(rename = "PHONETIC_ENCODING_X_SAMPA")]
    PhoneticEncodingXSampa,
}
