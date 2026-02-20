use serde::{Serialize, Deserialize};
use super::turn::Turn;

#[derive(Serialize, Deserialize, Debug)]
pub struct MultiSpeakerMarkup<'a> {
    #[serde(borrow)]
    pub turns: Vec<Turn<'a>>,
}
impl<'a> Clone for MultiSpeakerMarkup<'a> 
{
    fn clone(&self) -> Self {
        MultiSpeakerMarkup  {
            turns: self.turns.clone(),
        }
    }
}
