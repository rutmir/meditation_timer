use bb8_redis::redis::{FromRedisValue, ToRedisArgs, Value, RedisResult, RedisError, ErrorKind, RedisWrite};
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ScriptItem {
    pub instructions: String,
    pub audio: Option<String>,
    #[serde(rename = "startTime")]
    pub start_time: u32,
}

impl ScriptItem {
    pub fn is_valid_source(&self) -> bool {
        !self.instructions.is_empty()
    }

    pub fn is_valid(&self) -> bool {
        !self.instructions.is_empty() && self.audio.as_ref().is_some_and(|x| !x.is_empty())
    }

    pub fn get_tts_speech_markup(&self) -> String {
        let ssml = self.instructions
            .replace(".", ".<break time=\"4s\"/> ")
            .replace(",", ",<break time=\"1100ms\"/> ");
        format!("<speak>{}</speak>", ssml)
    }

    pub fn to_script(&self) -> ScriptItem {
        ScriptItem{ instructions: self.instructions.clone(), audio: None, start_time: self.start_time }
    }
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ScriptPhase {
    pub name: String,
    pub items: Vec<ScriptItem>,
}

impl ScriptPhase {
    pub fn is_valid_source(&self) -> bool {
        if self.items.is_empty() {
            return false
        }

        !self.items.iter().any(|f| !f.is_valid_source())
    }

    pub fn is_valid(&self) -> bool {
        if self.items.is_empty() {
            return false
        }

        !self.items.iter().any(|f| !f.is_valid())
    }

    pub fn to_script(&self) -> ScriptPhase {
        ScriptPhase { name: self.name.clone(), items: self.items.iter().map(|x| x.to_script()).collect() }
    }
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ScriptPhaseItem {
    pub phase: ScriptPhase,
}

impl ScriptPhaseItem {
    pub fn to_script(&self) -> ScriptPhaseItem {
        ScriptPhaseItem {
            phase: ScriptPhase{
                name: self.phase.name.clone(),
                items: self.phase.items.iter().map(|x| x.to_script()).collect(),
            }
        }
    }
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct MeditationScript {
    pub timestamp: i64,
    pub title: String,
    pub conclusion: String,
    #[serde(rename = "conclusionAudio")]
    pub conclusion_audio: Option<String>,
    pub introduction: String,
    #[serde(rename = "introductionAudio")]
    pub introduction_audio: Option<String>,
    pub body: Vec<ScriptPhaseItem>,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct MeditationScriptDTO {
    pub title: String,
    pub conclusion: String,
    #[serde(rename = "conclusionAudio")]
    pub conclusion_audio: Option<String>,
    pub introduction: String,
    #[serde(rename = "introductionAudio")]
    pub introduction_audio: Option<String>,
    pub body: Vec<ScriptPhaseItem>,
}

impl MeditationScriptDTO {
    pub fn to_metitation_script(self, timestamp: i64) -> MeditationScript {
        MeditationScript {
            timestamp,
            title: self.title,
            conclusion: self.conclusion,
            conclusion_audio: self.conclusion_audio,
            introduction: self.introduction,
            introduction_audio: self.introduction_audio,
            body: self.body,
        }
    }
}

/*
impl<'de> Deserialize<'de> for MeditationScript {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        // Define a visitor to handle the deserialization logic
        struct MeditationScriptVisitor;

        impl<'de> Visitor<'de> for MeditationScriptVisitor {
            type Value = MeditationScript;

            fn expecting(&self, formatter: &mut fmt::Formatter) -> fmt::Result {
                formatter.write_str("a struct with a 'timestamp', 'title', 'conclusion' and other fields")
            }

            fn visit_map<A>(self, mut map: A) -> Result<Self::Value, A::Error>
            where
                A: MapAccess<'de>,
            {
                let mut timestamp = None;
                let mut title = None;
                let mut conclusion = None;
                let mut conclusion_audio = None;
                let mut introduction = None;
                let mut introduction_audio = None;
                let mut body_value = None;

                // Iterate over map entries
                while let Some(key) = map.next_key::<String>()? {
                    match key.as_str() {
                        "timestamp" => {
                            if timestamp.is_some() {
                                return Err(de::Error::duplicate_field("timestamp"));
                            }
                            timestamp = Some(map.next_value()?);
                        }
                        "title" => {
                            if title.is_some() {
                                return Err(de::Error::duplicate_field("title"));
                            }
                            title = Some(map.next_value()?);
                        }
                        "conclusion" => {
                            if conclusion.is_some() {
                                return Err(de::Error::duplicate_field("conclusion"));
                            }
                            conclusion = Some(map.next_value()?);
                        }
                        "conclusionAudio" => {
                            if conclusion_audio.is_some() {
                                return Err(de::Error::duplicate_field("conclusionAudio"));
                            }
                            conclusion_audio = Some(map.next_value()?);
                        }
                        "introduction" => {
                            if introduction.is_some() {
                                return Err(de::Error::duplicate_field("introduction"));
                            }
                            introduction = Some(map.next_value()?);
                        }
                        "introductionAudio" => {
                            if introduction_audio.is_some() {
                                return Err(de::Error::duplicate_field("introductionAudio"));
                            }
                            introduction_audio = Some(map.next_value()?);
                        }
                        "body" => {
                            if body_value.is_some() {
                                return Err(de::Error::duplicate_field("body"));
                            }
                            body_value = Some(map.next_value()?);
                        }
                        _ => {
                            // Ignore unknown fields or handle them as needed
                            let _ = map.next_value::<de::IgnoredAny>()?;
                        }
                    }
                }

                // Construct MeditationScript instance
                let timestamp = timestamp.or(Some(Utc::now().timestamp_millis()));
                let title = title.ok_or_else(|| de::Error::missing_field("title"))?;
                let conclusion = conclusion.ok_or_else(|| de::Error::missing_field("conclusion"))?;
                // optional let conclusion_audio = conclusion_audio.ok_or_else(|| de::Error::missing_field("conclusionAudio"))?;
                let introduction = introduction.ok_or_else(|| de::Error::missing_field("introduction"))?;
                // optional let introduction_audio = introduction_audio.ok_or_else(|| de::Error::missing_field("introductionAudio"))?;
                let body_value: String = body_value.ok_or_else(|| de::Error::missing_field("body"))?;
                let body: Vec<ScriptPhaseItem> = match serde_json::from_str(&body_value) {
                    Ok(body) => body,
                    Err(e) => {
                        return Err(de::Error::custom(e.to_string()));
                    },
                };

                Ok(MeditationScript {
                    timestamp: timestamp.unwrap(),
                    title,
                    conclusion,
                    conclusion_audio,
                    introduction,
                    introduction_audio,
                    body,
                })
            }
        }

        deserializer.deserialize_map(MeditationScriptVisitor)
    }
}
*/

impl ToRedisArgs for &MeditationScript {
    fn write_redis_args<W>(&self, out: &mut W)
    where
        W: ?Sized + RedisWrite {
        let serialized = serde_json::to_string(self).expect("Can't serialize MeditationScript as string");

        out.write_arg_fmt(serialized);
    }
}

impl FromRedisValue for MeditationScript {
    fn from_redis_value(v: &Value) -> RedisResult<Self> {
        match v {
            Value::BulkString(data) => {
                let script: MeditationScript = serde_json::from_slice(data)
                    .map_err(|e| RedisError::from((ErrorKind::TypeError, "Failed to deserialize MeditationScript", e.to_string())))?;
                Ok(script)
            }
            _ => Err((ErrorKind::TypeError, "Invalid value type for MeditationScript").into()),
        }
    }
}

impl MeditationScript {
    pub fn is_valid_source(&self) -> bool {
        if self.title.is_empty() {
            return false
        }

        if self.conclusion.is_empty() {
            return false
        }

        if self.introduction.is_empty() {
            return false
        }

        !self.body.iter().any(|f| !f.phase.is_valid_source())
    }

    pub fn is_valid(&self) -> bool {
        if self.title.is_empty() {
            return false
        }

        if self.conclusion.is_empty() && self.conclusion_audio.as_ref().is_some_and(|x| !x.is_empty()) {
            return false
        }


        if self.introduction.is_empty() && self.introduction_audio.as_ref().is_some_and(|x| !x.is_empty()) {
            return false
        }

        !self.body.iter().any(|f| !f.phase.is_valid())
    }

    pub fn to_script(&self) -> MeditationScript {
        MeditationScript { 
            timestamp: self.timestamp.clone(),
            title: self.title.clone(), 
            conclusion: self.conclusion.clone(), 
            conclusion_audio: None, 
            introduction: self.introduction.clone(), 
            introduction_audio: None, 
            body: self.body.iter().map(|x| x.to_script()).collect(),
        }
    }
}