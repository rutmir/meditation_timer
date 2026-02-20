use serde::{Serialize, Deserialize};
use super::phonetic_encoding::PhoneticEncoding;

#[derive(Serialize, Deserialize, Debug)]
pub struct CustomPronunciationParams<'a> {
    pub phrase: &'a str,
    #[serde(rename = "phoneticEncoding")]
    pub phonetic_encoding: PhoneticEncoding,
    pub pronunciation: &'a str,
}

impl<'a> Clone for CustomPronunciationParams<'a> 
{
    fn clone(&self) -> Self {
        CustomPronunciationParams  {
            phrase: self.phrase,
            phonetic_encoding: self.phonetic_encoding.clone(),
            pronunciation: self.pronunciation,
        }
    }
}
