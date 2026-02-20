use std::sync::Once;
use log::LevelFilter;
use log4rs::{
    append::{
        console::ConsoleAppender,
        file::FileAppender
    }, 
    config::{Appender, Config as lofConfig, Root}, 
    encode::pattern::PatternEncoder, 
    filter::threshold::ThresholdFilter,
};

use crate::entities::config::Config as appConfig;

static INIT: Once = Once::new();

pub fn configure_logger() {
    INIT.call_once(|| {
        let app_config = appConfig::instance();
        let stdout = ConsoleAppender::builder()
            .encoder(Box::new(PatternEncoder::new("{d(%Y-%m-%d %H:%M:%S)} {l} {t} - {m}{n}")))
            .build();
        let logfile = FileAppender::builder()
            .encoder(Box::new(PatternEncoder::new("{d(%Y-%m-%d %H:%M:%S)} {l} {t} - {m}{n}")))
            .build("log/data.log")
            .unwrap();
        let config = lofConfig::builder()
            .appender(Appender::builder()
                .filter(Box::new(ThresholdFilter::new(LevelFilter::Debug)))
                .build("stdout", Box::new(stdout))
            );
        let config = config.appender(Appender::builder()
             .filter(Box::new(ThresholdFilter::new(app_config.log_level.unwrap_or(LevelFilter::Error))))
             .build("logfile", Box::new(logfile))
            );
        let rb = Root::builder().appender("stdout");
        let rb = rb.appender("logfile");
        let config = config.build(rb.build(LevelFilter::Debug)).unwrap();
        _ = log4rs::init_config(config).unwrap();
    });
}
