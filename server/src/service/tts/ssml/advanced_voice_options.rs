use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Debug)]
pub struct AdvancedVoiceOptions {
    #[serde(rename = "lowLatencyJourneySynthesis")]
    pub low_latency_journey_synthesis: bool,
}

impl Clone for AdvancedVoiceOptions 
{
    fn clone(&self) -> Self {
        AdvancedVoiceOptions  {
            low_latency_journey_synthesis: self.low_latency_journey_synthesis,
        }
    }
}
