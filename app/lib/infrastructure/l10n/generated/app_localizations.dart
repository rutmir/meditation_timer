import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ru'),
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Meditation Timer'**
  String get app_name;

  /// No description provided for @action_start.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get action_start;

  /// No description provided for @action_stop.
  ///
  /// In en, this message translates to:
  /// **'STOP'**
  String get action_stop;

  /// No description provided for @action_pause.
  ///
  /// In en, this message translates to:
  /// **'PAUSE'**
  String get action_pause;

  /// No description provided for @action_continue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get action_continue;

  /// No description provided for @action_stop_tooltip.
  ///
  /// In en, this message translates to:
  /// **'stop timer'**
  String get action_stop_tooltip;

  /// No description provided for @action_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get action_back;

  /// No description provided for @lb_minute_short.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get lb_minute_short;

  /// No description provided for @lb_meditation.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get lb_meditation;

  /// No description provided for @lb_pranayama.
  ///
  /// In en, this message translates to:
  /// **'Prāṇāyāma'**
  String get lb_pranayama;

  /// No description provided for @lb_med_settings.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get lb_med_settings;

  /// No description provided for @lb_med_session_duration.
  ///
  /// In en, this message translates to:
  /// **'Meditation duration'**
  String get lb_med_session_duration;

  /// No description provided for @lb_med_use_session_gong.
  ///
  /// In en, this message translates to:
  /// **'Use a gong at the beginning and at the end'**
  String get lb_med_use_session_gong;

  /// No description provided for @lb_med_session_gong_volume.
  ///
  /// In en, this message translates to:
  /// **'Beginning gong volume'**
  String get lb_med_session_gong_volume;

  /// No description provided for @lb_med_use_round_gong.
  ///
  /// In en, this message translates to:
  /// **'Use the gong of the round'**
  String get lb_med_use_round_gong;

  /// No description provided for @lb_med_round_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration of the round'**
  String get lb_med_round_duration;

  /// No description provided for @lb_med_round_gong_volume.
  ///
  /// In en, this message translates to:
  /// **'Round gong volume'**
  String get lb_med_round_gong_volume;

  /// No description provided for @lb_med_use_minor_gong.
  ///
  /// In en, this message translates to:
  /// **'Use a minor gong'**
  String get lb_med_use_minor_gong;

  /// No description provided for @lb_med_minor_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration of the minor cycle'**
  String get lb_med_minor_duration;

  /// No description provided for @lb_med_minor_gong_volume.
  ///
  /// In en, this message translates to:
  /// **'Volume of the minor gong'**
  String get lb_med_minor_gong_volume;

  /// No description provided for @lb_pra_settings.
  ///
  /// In en, this message translates to:
  /// **'Pranayama'**
  String get lb_pra_settings;

  /// No description provided for @lb_pra_start_round.
  ///
  /// In en, this message translates to:
  /// **'Start Pranayama round before Meditation'**
  String get lb_pra_start_round;

  /// No description provided for @lb_pra_set_duration.
  ///
  /// In en, this message translates to:
  /// **'Set duration'**
  String get lb_pra_set_duration;

  /// No description provided for @lb_pra_use_metronome.
  ///
  /// In en, this message translates to:
  /// **'Use one second metronome'**
  String get lb_pra_use_metronome;

  /// No description provided for @lb_pra_metronome_volume.
  ///
  /// In en, this message translates to:
  /// **'Metronome sound volume'**
  String get lb_pra_metronome_volume;

  /// No description provided for @lb_app_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get lb_app_settings;

  /// No description provided for @lb_app_use_silent_mode.
  ///
  /// In en, this message translates to:
  /// **'Use the silent mode at startup'**
  String get lb_app_use_silent_mode;

  /// No description provided for @lb_app_color_scheme.
  ///
  /// In en, this message translates to:
  /// **'Color scheme'**
  String get lb_app_color_scheme;

  /// No description provided for @lb_app_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get lb_app_language;

  /// No description provided for @lb_language_system_default.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get lb_language_system_default;

  /// No description provided for @permission_msg_title.
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb'**
  String get permission_msg_title;

  /// No description provided for @permission_msg_1.
  ///
  /// In en, this message translates to:
  /// **'The app can automatically silence your phone during meditation.'**
  String get permission_msg_1;

  /// No description provided for @permission_msg_2.
  ///
  /// In en, this message translates to:
  /// **'This prevents distracting calls and notifications so you can focus on your practice.'**
  String get permission_msg_2;

  /// No description provided for @permission_msg_3.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in the app settings.'**
  String get permission_msg_3;

  /// No description provided for @permission_msg_reject.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get permission_msg_reject;

  /// No description provided for @permission_msg_accept.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get permission_msg_accept;

  /// No description provided for @permission_msg_dont_ask.
  ///
  /// In en, this message translates to:
  /// **'Don\'t ask again'**
  String get permission_msg_dont_ask;

  /// No description provided for @permission_denied_msg.
  ///
  /// In en, this message translates to:
  /// **'Silent mode permission was not granted. You can enable it later in Settings.'**
  String get permission_denied_msg;

  /// No description provided for @permission_permanently_denied_msg.
  ///
  /// In en, this message translates to:
  /// **'Silent mode permission was denied. Please enable it in your device settings.'**
  String get permission_permanently_denied_msg;

  /// No description provided for @permission_open_settings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get permission_open_settings;

  /// No description provided for @error_no_internet.
  ///
  /// In en, this message translates to:
  /// **'Internet connection not detected. Please check your settings and try again.'**
  String get error_no_internet;

  /// No description provided for @error_app_version.
  ///
  /// In en, this message translates to:
  /// **'The service returned an error. Make sure you are using the resent version of the app and try again.'**
  String get error_app_version;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown error.'**
  String get error_unknown;

  /// No description provided for @lb_miditation_from_ai.
  ///
  /// In en, this message translates to:
  /// **'Meditation from AI'**
  String get lb_miditation_from_ai;

  /// No description provided for @lb_created_by_ai.
  ///
  /// In en, this message translates to:
  /// **'Created by AI'**
  String get lb_created_by_ai;

  /// No description provided for @created_by_ai_msg.
  ///
  /// In en, this message translates to:
  /// **'All guided meditations presented here were created and voiced by artificial intelligence. The AI determines the theme and content of meditation itself, and the AI offers different options every day.\nBefore downloading the meditation, you can view it by downloading only the text of the meditation first.\nHow does AI understand the essence and purpose of meditation? It was interesting for me to look in this mirror.'**
  String get created_by_ai_msg;

  /// No description provided for @lb_introduction.
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get lb_introduction;

  /// No description provided for @lb_conclusion.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get lb_conclusion;

  /// No description provided for @msg_session_active_locked.
  ///
  /// In en, this message translates to:
  /// **'Session in progress: Some settings are locked.'**
  String get msg_session_active_locked;

  /// No description provided for @help_pra_title.
  ///
  /// In en, this message translates to:
  /// **'About Pranayama'**
  String get help_pra_title;

  /// No description provided for @help_pra_content.
  ///
  /// In en, this message translates to:
  /// **'Pranayama is a yogic practice of breath control. In this app, it\'s used as a preparatory stage before the main meditation to calm the mind and focus.'**
  String get help_pra_content;

  /// No description provided for @help_silence_title.
  ///
  /// In en, this message translates to:
  /// **'About Silence Mode'**
  String get help_silence_title;

  /// No description provided for @help_silence_content.
  ///
  /// In en, this message translates to:
  /// **'When enabled, the app will automatically turn on \'Do Not Disturb\' mode on your device during the session to prevent interruptions. It will be restored after the session ends.'**
  String get help_silence_content;

  /// No description provided for @lb_pranayama_desc.
  ///
  /// In en, this message translates to:
  /// **'Breathing exercises to prepare for meditation'**
  String get lb_pranayama_desc;

  /// No description provided for @lb_session_gong_desc.
  ///
  /// In en, this message translates to:
  /// **'Plays at the start and end of your meditation'**
  String get lb_session_gong_desc;

  /// No description provided for @lb_round_gong_desc.
  ///
  /// In en, this message translates to:
  /// **'Plays at regular intervals during meditation'**
  String get lb_round_gong_desc;

  /// No description provided for @lb_minor_gong_desc.
  ///
  /// In en, this message translates to:
  /// **'Soft reminder sounds between round intervals'**
  String get lb_minor_gong_desc;

  /// No description provided for @lb_metronome_desc.
  ///
  /// In en, this message translates to:
  /// **'Rhythmic sound to pace your breathing'**
  String get lb_metronome_desc;

  /// No description provided for @lb_silent_mode_desc.
  ///
  /// In en, this message translates to:
  /// **'Mute device sounds during meditation'**
  String get lb_silent_mode_desc;

  /// No description provided for @lb_reset_defaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get lb_reset_defaults;

  /// No description provided for @lb_reset_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings?'**
  String get lb_reset_confirm_title;

  /// No description provided for @lb_reset_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'All settings will be restored to their original values.'**
  String get lb_reset_confirm_message;

  /// No description provided for @lb_interval_example.
  ///
  /// In en, this message translates to:
  /// **'For {duration} min session: at {intervals}'**
  String lb_interval_example(int duration, String intervals);

  /// No description provided for @lb_no_meditations_available.
  ///
  /// In en, this message translates to:
  /// **'No meditations available yet'**
  String get lb_no_meditations_available;

  /// No description provided for @lb_no_meditations_subtitle.
  ///
  /// In en, this message translates to:
  /// **'New AI meditations are generated daily'**
  String get lb_no_meditations_subtitle;

  /// No description provided for @lb_pull_to_refresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get lb_pull_to_refresh;

  /// No description provided for @lb_scheduling_mode.
  ///
  /// In en, this message translates to:
  /// **'Sound scheduling mode'**
  String get lb_scheduling_mode;

  /// No description provided for @lb_mode_interval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get lb_mode_interval;

  /// No description provided for @lb_mode_advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get lb_mode_advanced;

  /// No description provided for @lb_advanced_schedule.
  ///
  /// In en, this message translates to:
  /// **'Custom Sound Schedule'**
  String get lb_advanced_schedule;

  /// No description provided for @lb_advanced_schedule_desc.
  ///
  /// In en, this message translates to:
  /// **'Set sounds at specific times'**
  String get lb_advanced_schedule_desc;

  /// No description provided for @lb_add_sound_event.
  ///
  /// In en, this message translates to:
  /// **'Add Sound'**
  String get lb_add_sound_event;

  /// No description provided for @lb_edit_event.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get lb_edit_event;

  /// No description provided for @lb_delete_event.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get lb_delete_event;

  /// No description provided for @lb_event_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get lb_event_time;

  /// No description provided for @lb_event_sound_type.
  ///
  /// In en, this message translates to:
  /// **'Sound Type'**
  String get lb_event_sound_type;

  /// No description provided for @lb_event_volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get lb_event_volume;

  /// No description provided for @lb_save_schedule.
  ///
  /// In en, this message translates to:
  /// **'Save Schedule'**
  String get lb_save_schedule;

  /// No description provided for @lb_load_schedule.
  ///
  /// In en, this message translates to:
  /// **'Load Schedule'**
  String get lb_load_schedule;

  /// No description provided for @lb_schedule_name.
  ///
  /// In en, this message translates to:
  /// **'Schedule Name'**
  String get lb_schedule_name;

  /// No description provided for @lb_no_events_scheduled.
  ///
  /// In en, this message translates to:
  /// **'No sounds scheduled'**
  String get lb_no_events_scheduled;

  /// No description provided for @lb_no_events_scheduled_desc.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add sound events'**
  String get lb_no_events_scheduled_desc;

  /// No description provided for @lb_saved_schedules.
  ///
  /// In en, this message translates to:
  /// **'Saved Schedules'**
  String get lb_saved_schedules;

  /// No description provided for @lb_no_saved_schedules.
  ///
  /// In en, this message translates to:
  /// **'No saved schedules'**
  String get lb_no_saved_schedules;

  /// No description provided for @lb_schedule_preview.
  ///
  /// In en, this message translates to:
  /// **'Schedule Preview'**
  String get lb_schedule_preview;

  /// No description provided for @lb_sound_session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get lb_sound_session;

  /// No description provided for @lb_sound_round.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get lb_sound_round;

  /// No description provided for @lb_sound_minor.
  ///
  /// In en, this message translates to:
  /// **'Minor'**
  String get lb_sound_minor;

  /// No description provided for @msg_time_exceeds_duration.
  ///
  /// In en, this message translates to:
  /// **'Time cannot exceed session duration'**
  String get msg_time_exceeds_duration;

  /// No description provided for @msg_schedule_saved.
  ///
  /// In en, this message translates to:
  /// **'Schedule saved'**
  String get msg_schedule_saved;

  /// No description provided for @msg_schedule_loaded.
  ///
  /// In en, this message translates to:
  /// **'Schedule loaded'**
  String get msg_schedule_loaded;

  /// No description provided for @msg_events_filtered.
  ///
  /// In en, this message translates to:
  /// **'{count} events were removed (exceeded duration)'**
  String msg_events_filtered(int count);

  /// No description provided for @lb_delete_schedule.
  ///
  /// In en, this message translates to:
  /// **'Delete Schedule'**
  String get lb_delete_schedule;

  /// No description provided for @msg_confirm_delete_schedule.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this schedule?'**
  String get msg_confirm_delete_schedule;

  /// No description provided for @lb_event_repeat_count.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get lb_event_repeat_count;

  /// No description provided for @msg_minute_already_used.
  ///
  /// In en, this message translates to:
  /// **'This minute already has a sound'**
  String get msg_minute_already_used;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
