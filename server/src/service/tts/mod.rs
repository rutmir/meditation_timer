use std::env;

use crate::entities::language::Language;
use crate::entities::meditation_script::ScriptItem;

mod ssml;
use ssml::{request::Request, input::Input, voice_selection_params::VoiceSelectionParams};
use ssml::{ssml_voice_gender::SsmlVoiceGender, audio_config::AudioConfig, audio_encoding::AudioEncoding};

fn get_lang_code_and_voice(language: Language) -> (String, String) {
    match language {
        Language::English => ("en-us".to_string(), "en-US-Standard-J".to_string()),
        Language::Russian => ("ru-ru".to_string(), "ru-RU-Standard-D".to_string()),
        Language::Spanish => ("es-es".to_string(), "es-ES-Standard-E".to_string()),
        Language::Franch => ("fr-fr".to_string(), "fr-FR-Standard-G".to_string()),
    }
}

pub async fn convert_text_to_speach(source: &ScriptItem, language: Language) -> (bool, Option<String>) {
    let tts_api_key = env::var("TTS_APIKEY").expect("expected 'TTS_APIKEY'");
    let tts_api_url = env::var("TTS_APIURL").expect("expected 'TTS_APIURL'");
    // let tts_api_model = env::var("TTS_MODEL").expect("expected 'TTS_MODEL'");
    // let tts_api_voice_name = env::var("TTS_VOICE_NAME").expect("expected 'TTS_VOICE_NAME'");

    let ssml = source.get_tts_speech_markup();
    let (language_code, voice_name ) = get_lang_code_and_voice(language);

    let request = Request{
        input: Input{
            text: None,
            ssml: Some(&ssml),
            custom_pronunciations: None,
            multi_speaker_markup: None,
        },
        audio_config: AudioConfig{
            audio_encoding: AudioEncoding::Mp3,
            speaking_rate: Some(0.80),
            pitch: None,
            volume_gain_db: None,
            sample_rate_hertz: None,
            effects_profile_id: None,
        },
        voice: VoiceSelectionParams{
            language_code: &language_code,
            name: &voice_name,
            ssml_gender: Some(SsmlVoiceGender::Male),
            custom_voice: None,
            voice_clone: None,
            model_name: None,
        },
        advanced_voice_options: None,
    };

    log::debug!("{}", serde_json::to_string_pretty(&request).unwrap());

    let request_builder = reqwest::Client::new()
        .post(format!("{}?key={}", tts_api_url, tts_api_key))
        .json(&request);
    let response = match request_builder.send().await {
        Ok(data) => data ,
        Err(e) => {
            log::error!("--> ERR (1) : {}", e);

            return (false, None);
        }
    };

    let json = match response.text().await {
        Ok(json) => json,
        Err(e) => {
            log::error!("--> ERR (2) : {}", e);

            return (false, None);
        }
    };

    let data = match serde_json::from_str::<ssml::response::Response>(&json) {
        Ok(data) => data.audio_content,
        Err(e) => {
            log::error!("--> ERR (3) : {}", e);

            return (false, None);
        }
    };

    (true, Some(data)) 
} 