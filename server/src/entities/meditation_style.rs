use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum MeditationStyle {
    Relaxation,
    Advaita,
    Ramana,
    Krishnamurti,
    Nisargadatta,
    BrethConcentration,
    SoundConcentration,
}