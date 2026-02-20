// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Meditation Timer';

  @override
  String get action_start => 'START';

  @override
  String get action_stop => 'STOP';

  @override
  String get action_pause => 'PAUSE';

  @override
  String get action_continue => 'CONTINUE';

  @override
  String get action_stop_tooltip => 'stop timer';

  @override
  String get action_back => 'Back';

  @override
  String get lb_minute_short => 'min';

  @override
  String get lb_meditation => 'Meditation';

  @override
  String get lb_pranayama => 'Prāṇāyāma';

  @override
  String get lb_med_settings => 'Meditation';

  @override
  String get lb_med_session_duration => 'Meditation duration';

  @override
  String get lb_med_use_session_gong =>
      'Use a gong at the beginning and at the end';

  @override
  String get lb_med_session_gong_volume => 'Beginning gong volume';

  @override
  String get lb_med_use_round_gong => 'Use the gong of the round';

  @override
  String get lb_med_round_duration => 'Duration of the round';

  @override
  String get lb_med_round_gong_volume => 'Round gong volume';

  @override
  String get lb_med_use_minor_gong => 'Use a minor gong';

  @override
  String get lb_med_minor_duration => 'Duration of the minor cycle';

  @override
  String get lb_med_minor_gong_volume => 'Volume of the minor gong';

  @override
  String get lb_pra_settings => 'Pranayama';

  @override
  String get lb_pra_start_round => 'Start Pranayama round before Meditation';

  @override
  String get lb_pra_set_duration => 'Set duration';

  @override
  String get lb_pra_use_metronome => 'Use one second metronome';

  @override
  String get lb_pra_metronome_volume => 'Metronome sound volume';

  @override
  String get lb_app_settings => 'Settings';

  @override
  String get lb_app_use_silent_mode => 'Use the silent mode at startup';

  @override
  String get lb_app_color_scheme => 'Color scheme';

  @override
  String get lb_app_language => 'Language';

  @override
  String get lb_language_system_default => 'System default';

  @override
  String get permission_msg_title => 'Do Not Disturb';

  @override
  String get permission_msg_1 =>
      'The app can automatically silence your phone during meditation.';

  @override
  String get permission_msg_2 =>
      'This prevents distracting calls and notifications so you can focus on your practice.';

  @override
  String get permission_msg_3 =>
      'You can change this anytime in the app settings.';

  @override
  String get permission_msg_reject => 'Not now';

  @override
  String get permission_msg_accept => 'Allow';

  @override
  String get permission_msg_dont_ask => 'Don\'t ask again';

  @override
  String get permission_denied_msg =>
      'Silent mode permission was not granted. You can enable it later in Settings.';

  @override
  String get permission_permanently_denied_msg =>
      'Silent mode permission was denied. Please enable it in your device settings.';

  @override
  String get permission_open_settings => 'Open Settings';

  @override
  String get error_no_internet =>
      'Internet connection not detected. Please check your settings and try again.';

  @override
  String get error_app_version =>
      'The service returned an error. Make sure you are using the resent version of the app and try again.';

  @override
  String get error_unknown => 'Unknown error.';

  @override
  String get lb_miditation_from_ai => 'Meditation from AI';

  @override
  String get lb_created_by_ai => 'Created by AI';

  @override
  String get created_by_ai_msg =>
      'All guided meditations presented here were created and voiced by artificial intelligence. The AI determines the theme and content of meditation itself, and the AI offers different options every day.\nBefore downloading the meditation, you can view it by downloading only the text of the meditation first.\nHow does AI understand the essence and purpose of meditation? It was interesting for me to look in this mirror.';

  @override
  String get lb_introduction => 'Introduction';

  @override
  String get lb_conclusion => 'Completion';

  @override
  String get msg_session_active_locked =>
      'Session in progress: Some settings are locked.';

  @override
  String get help_pra_title => 'About Pranayama';

  @override
  String get help_pra_content =>
      'Pranayama is a yogic practice of breath control. In this app, it\'s used as a preparatory stage before the main meditation to calm the mind and focus.';

  @override
  String get help_silence_title => 'About Silence Mode';

  @override
  String get help_silence_content =>
      'When enabled, the app will automatically turn on \'Do Not Disturb\' mode on your device during the session to prevent interruptions. It will be restored after the session ends.';

  @override
  String get lb_pranayama_desc =>
      'Breathing exercises to prepare for meditation';

  @override
  String get lb_session_gong_desc =>
      'Plays at the start and end of your meditation';

  @override
  String get lb_round_gong_desc =>
      'Plays at regular intervals during meditation';

  @override
  String get lb_minor_gong_desc =>
      'Soft reminder sounds between round intervals';

  @override
  String get lb_metronome_desc => 'Rhythmic sound to pace your breathing';

  @override
  String get lb_silent_mode_desc => 'Mute device sounds during meditation';

  @override
  String get lb_reset_defaults => 'Reset to Defaults';

  @override
  String get lb_reset_confirm_title => 'Reset Settings?';

  @override
  String get lb_reset_confirm_message =>
      'All settings will be restored to their original values.';

  @override
  String lb_interval_example(int duration, String intervals) {
    return 'For $duration min session: at $intervals';
  }

  @override
  String get lb_no_meditations_available => 'No meditations available yet';

  @override
  String get lb_no_meditations_subtitle =>
      'New AI meditations are generated daily';

  @override
  String get lb_pull_to_refresh => 'Pull to refresh';

  @override
  String get lb_scheduling_mode => 'Sound scheduling mode';

  @override
  String get lb_mode_interval => 'Interval';

  @override
  String get lb_mode_advanced => 'Advanced';

  @override
  String get lb_advanced_schedule => 'Custom Sound Schedule';

  @override
  String get lb_advanced_schedule_desc => 'Set sounds at specific times';

  @override
  String get lb_add_sound_event => 'Add Sound';

  @override
  String get lb_edit_event => 'Edit';

  @override
  String get lb_delete_event => 'Delete';

  @override
  String get lb_event_time => 'Time';

  @override
  String get lb_event_sound_type => 'Sound Type';

  @override
  String get lb_event_volume => 'Volume';

  @override
  String get lb_save_schedule => 'Save Schedule';

  @override
  String get lb_load_schedule => 'Load Schedule';

  @override
  String get lb_schedule_name => 'Schedule Name';

  @override
  String get lb_no_events_scheduled => 'No sounds scheduled';

  @override
  String get lb_no_events_scheduled_desc => 'Tap + to add sound events';

  @override
  String get lb_saved_schedules => 'Saved Schedules';

  @override
  String get lb_no_saved_schedules => 'No saved schedules';

  @override
  String get lb_schedule_preview => 'Schedule Preview';

  @override
  String get lb_sound_session => 'Session';

  @override
  String get lb_sound_round => 'Round';

  @override
  String get lb_sound_minor => 'Minor';

  @override
  String get msg_time_exceeds_duration => 'Time cannot exceed session duration';

  @override
  String get msg_schedule_saved => 'Schedule saved';

  @override
  String get msg_schedule_loaded => 'Schedule loaded';

  @override
  String msg_events_filtered(int count) {
    return '$count events were removed (exceeded duration)';
  }

  @override
  String get lb_delete_schedule => 'Delete Schedule';

  @override
  String get msg_confirm_delete_schedule =>
      'Are you sure you want to delete this schedule?';

  @override
  String get lb_event_repeat_count => 'Repeat';

  @override
  String get msg_minute_already_used => 'This minute already has a sound';
}
