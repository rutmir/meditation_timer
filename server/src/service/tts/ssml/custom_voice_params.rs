use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Debug)]
pub struct CustomVoiceParams<'a> {
    pub model: &'a str,
}

impl<'a> Clone for CustomVoiceParams<'a> 
{
    fn clone(&self) -> Self {
        CustomVoiceParams  {
            model: self.model,
        }
    }
}
