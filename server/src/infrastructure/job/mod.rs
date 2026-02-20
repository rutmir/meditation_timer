mod job_state;
mod daily_meditation_populate;
mod daily_cleanup;
mod job_config;

use std::sync::Arc;
use tokio_cron_scheduler::{Job, JobScheduler};
use job_state::JobState;
use daily_meditation_populate::daily_meditation_job_handler;
use daily_cleanup::daily_cleanup_job_handler;

use crate::entities::error::AppError;
use job_config::JobConfig;

pub async fn start_jobs() -> Result<(), AppError> {
    let job_state =  Arc::new(JobState::new(JobConfig::instance()).await);
    let sched = JobScheduler::new().await?;
    let job_config = job_state.config.lock().unwrap().clone();

    if job_config.daily_data.enabled {
        log::debug!("-> job daily_meditation_job_handler added");
        sched.add(
            Job::new_async(job_config.daily_data.schedule, {
                let state = job_state.clone();
                move |uuid, mut l| {
                    let state = state.clone();
                    Box::pin(async move {
                        log::info!("Running async daily_meditation_job_handler");
                        let next_tick = l.next_tick_for_job(uuid).await;
                        match next_tick {
                            Ok(Some(ts)) => log::info!("Next time for daily_data job is {:?}", ts),
                            _ => log::info!("Could not get next tick for daily_data job"),
                        }
                        daily_meditation_job_handler(state).await;
                    })
                }
            })?,
        ).await?;
    }

    if job_config.clean_data.enabled {
        log::debug!("-> job daily_cleanup_job_handler added");
        sched.add(
            Job::new_async(job_config.clean_data.schedule, {
                let state = job_state.clone();
                move |_uuid, mut _l| {
                    let state = state.clone();
                    Box::pin(async move {
                        log::info!("Running async daily_cleanup_job_handler");
                        daily_cleanup_job_handler(state).await;
                    })
                }
            })?,
        ).await?;
    }

    sched.start().await?;
    Ok(())
 }
