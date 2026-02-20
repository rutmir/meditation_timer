use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Debug)]
pub struct Turn<'a> {
    pub speaker: &'a str,
    pub text: &'a str,
}

impl<'a> Clone for Turn<'a> 
{
    fn clone(&self) -> Self {
        Turn  {
            speaker: self.speaker,
            text: self.text,
        }
    }
}
