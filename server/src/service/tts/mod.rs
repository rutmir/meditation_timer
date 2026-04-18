use std::env;
use std::error::Error as StdError;
use base64::{Engine as _, engine::general_purpose};

use crate::entities::language::Language;
use crate::entities::meditation_script::ScriptItem;

fn get_lang_and_voice(language: Language) -> (&'static str, &'static str) {
    match language {
        Language::English => ("en-US", "en-US-GuyNeural"),
        Language::Russian => ("ru-RU", "ru-RU-DmitryNeural"),
        Language::Spanish => ("es-ES", "es-ES-AlvaroNeural"),
        Language::Franch  => ("fr-FR", "fr-FR-HenriNeural"),
    }
}

fn build_ssml(inner: &str, lang: &str, voice: &str) -> String {
    format!(
        "<speak version='1.0' xml:lang='{lang}' xmlns='http://www.w3.org/2001/10/synthesis'>\
         <voice name='{voice}'>{inner}</voice></speak>",
    )
}

pub async fn convert_text_to_speach(source: &ScriptItem, language: Language) -> (bool, Option<String>) {
    let api_key = env::var("TTS_APIKEY").expect("expected 'TTS_APIKEY'");
    let region  = env::var("TTS_REGION").expect("expected 'TTS_REGION'");

    let (lang_code, voice_name) = get_lang_and_voice(language);
    let inner = source.get_tts_speech_markup();
    let ssml = build_ssml(&inner, lang_code, voice_name);
    let url = format!("https://{}.tts.speech.microsoft.com/cognitiveservices/v1", region);

    log::debug!("Azure TTS → {} voice={}", url, voice_name);
    log::debug!("SSML: {}", ssml);

    let client = reqwest::Client::builder()
        .timeout(std::time::Duration::from_secs(30))
        .build()
        .expect("failed to build reqwest client");

    let response = match client
        .post(&url)
        .header("Ocp-Apim-Subscription-Key", &api_key)
        .header("Content-Type", "application/ssml+xml")
        .header("X-Microsoft-OutputFormat", "audio-16khz-128kbitrate-mono-mp3")
        .body(ssml)
        .send()
        .await
    {
        Ok(r) => r,
        Err(e) => {
            log::error!("--> ERR (1) Azure TTS: {}", e);
            let mut src = e.source();
            while let Some(cause) = src {
                log::error!("    caused by: {}", cause);
                src = cause.source();
            }
            return (false, None);
        }
    };

    let status = response.status();
    if !status.is_success() {
        let headers = response.headers().clone();
        let body = response.bytes().await.unwrap_or_default();
        log::error!("--> ERR (2) Azure TTS HTTP {} headers={:?} body_len={} body={:?}",
            status, headers, body.len(), String::from_utf8_lossy(&body));
        return (false, None);
    }

    let bytes = match response.bytes().await {
        Ok(b) => b,
        Err(e) => {
            log::error!("--> ERR (3) Azure TTS read bytes: {}", e);
            return (false, None);
        }
    };

    (true, Some(general_purpose::STANDARD.encode(&bytes)))
}
