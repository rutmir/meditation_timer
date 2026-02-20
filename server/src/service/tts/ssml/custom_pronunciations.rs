use serde::{Serialize, Deserialize};
use super::custom_pronunciation_params::CustomPronunciationParams;

#[derive(Serialize, Deserialize, Debug)]
pub struct CustomPronunciations<'a> {
    #[serde(borrow)]
    pub pronunciations: Vec<CustomPronunciationParams<'a>>,
}
impl<'a> Clone for CustomPronunciations<'a> 
{
    fn clone(&self) -> Self {
        CustomPronunciations  {
            pronunciations: self.pronunciations.clone(),
        }
    }
}
