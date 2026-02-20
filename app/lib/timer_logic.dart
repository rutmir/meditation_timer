import 'dart:async';
import 'base_logic.dart';
import 'entities/advanced_meditation_session.dart';
import 'entities/app_settings.dart';
import 'entities/scheduling_mode.dart';
import 'entities/sound_event.dart';
import 'entities/unguided_meditation_session.dart';
import 'entities/pranayama_session.dart';
import 'player.dart';
import 'service/ai_meditation_service.dart';
import 'service/settings_service.dart';
import 'service/system_channel_service.dart';
import 'service/theme_service.dart';

class TimerLogic {
  final _player = AudioController();
  final _watch = Stopwatch();
  final ThemeService theme;
  final AiMeditationService aiService;
  final Function() afterInitCb;

  late Timer _timer;
  late PranayamaSession _pranayamaSession;
  late UnguidedMeditationSession _uMeditationSession;
  late BaseLogic _baseLogic;
  final Completer<void> _initCompleter = Completer<void>();

  // Advanced scheduling mode
  SchedulingMode _schedulingMode = SchedulingMode.interval;
  AdvancedMeditationSession? _advancedSession;
  List<SoundEvent> _advancedEvents = [];

  bool _isInitialized = false;
  bool _startStop = false;
  String _displayTime = '';

  bool _isAiServiceOnline = false;

  TimerLogic({
    required SettingsService settings,
    required this.theme,
    required SystemChannelService system,
    required this.aiService,
    required String Function(String) l10n,
    required Function() trigger,
    required this.afterInitCb,
  }) {
    () async {
      _pranayamaSession = await settings.getPranayamaSession();
      _uMeditationSession = await settings.getMeditationSession();
      _schedulingMode = await settings.getSchedulingMode();
      _advancedEvents = await settings.getCurrentAdvancedSchedule();
      _baseLogic = await BaseLogic.buildBaseLogic(
        l10n,
        system,
        settings,
        trigger,
      );
      _uMeditationSession.prestartAnimation = _pranayamaSession.enabled;
      _isInitialized = true;
      _initCompleter.complete();

      afterInitCb();
    }();

    lazyInit();
  }

  void lazyInit() async {
    await _initCompleter.future;

    var hasChanges = false;
    if (await aiService.isAiServiceOnline()) {
      hasChanges = true;
      _isAiServiceOnline = true;
    }

    if (hasChanges) {
      _baseLogic.trigger();
    }
  }

  void trigger() => _baseLogic.trigger();

  Future<bool> needUserPermission() => _baseLogic.needUserPermission();

  void verifyPermission() => _baseLogic.verifyPermission();

  void dismissPermissionDialog() => _baseLogic.dismissPermissionDialog();

  bool popShouldOpenAppSettings() =>
      !_isInitialized ? false : _baseLogic.popShouldOpenAppSettings();

  bool get isInitialized => _isInitialized;
  bool get isRunning => _startStop;
  String get displayTime => _displayTime;

  void startTimer() {
    _baseLogic.setInterruptionFilter(true);
    _pranayamaSession.reset();

    // Reset appropriate session based on scheduling mode
    if (_schedulingMode == SchedulingMode.advanced) {
      _advancedSession = AdvancedMeditationSession(
        sessionDuration: _uMeditationSession.sessionDuration,
        events: _advancedEvents,
      );
      _advancedSession!.prestartAnimation = _pranayamaSession.enabled;
      _advancedSession!.reset();
    } else {
      _uMeditationSession.reset();
    }

    _startStop = true;
    _watch.start();
    _timer = Timer.periodic(Duration(milliseconds: 50), _updateTime);

    // Switch to meditation-friendly color scheme
    theme.setMeditationMode(true);
    _baseLogic.trigger(); // Trigger UI update
  }

  void stopTimer() {
    _baseLogic.setInterruptionFilter(false);
    _startStop = false;
    _watch.stop();
    _watch.reset();
    _timer.cancel();

    // Switch back to normal color scheme
    theme.setMeditationMode(false);
    _baseLogic.trigger(); // Trigger UI update
  }

  void dispose() {
    if (_startStop) {
      _timer.cancel();
    }
    _baseLogic.dispose();
    _player.dispose();
  }

  void _updateTime(Timer timer) {
    if (!_watch.isRunning) {
      return;
    }

    int millsec = _watch.elapsedMilliseconds;
    String previousDisplayTime = _displayTime;

    if (!_pranayamaSession.isCompleted) {
      _pranayamaSession.processTick(
        _player,
        millsec,
        (val) => _displayTime = val,
      );
      // Only trigger UI update if display time actually changed
      if (_displayTime != previousDisplayTime) {
        _baseLogic.trigger();
      }

      return;
    }

    millsec -= _pranayamaSession.durationMils;

    // Use appropriate session based on scheduling mode
    if (_schedulingMode == SchedulingMode.advanced && _advancedSession != null) {
      if (!_advancedSession!.isCompleted) {
        _advancedSession!.processTick(
          _player,
          millsec,
          (val) => _displayTime = val,
        );
        // Only trigger UI update if display time actually changed
        if (_displayTime != previousDisplayTime) {
          _baseLogic.trigger();
        }

        return;
      }
    } else {
      if (!_uMeditationSession.isCompleted) {
        _uMeditationSession.processTick(
          _player,
          millsec,
          (val) => _displayTime = val,
        );
        // Only trigger UI update if display time actually changed
        if (_displayTime != previousDisplayTime) {
          _baseLogic.trigger();
        }

        return;
      }
    }

    stopTimer();
  }

  //--> PRANAYAMA

  PranayamaSession get pranayamaSession => _pranayamaSession;
  set pranayamaEnabled(bool val) {
    _pranayamaSession.enabled = val;
    _uMeditationSession.prestartAnimation = val;
    _baseLogic.settings.writePranayamaEnabled(_pranayamaSession.enabled);

    _baseLogic.trigger();
  }

  set pranayamaDuration(double val) {
    _pranayamaSession.duration = val.round();
    _baseLogic.settings.writePranayamaDuration(_pranayamaSession.duration);

    _baseLogic.trigger();
  }

  set pranayamaUseMetronome(bool val) {
    _pranayamaSession.useMetronome = val;
    _baseLogic.settings.writePranayamaUseMetronome(
      _pranayamaSession.useMetronome,
    );

    _baseLogic.trigger();
  }

  set pranayamaMetronomeVolume(double val) {
    _pranayamaSession.volume = val;
    _baseLogic.settings.writePranayamaVolume(_pranayamaSession.volume);

    _baseLogic.trigger();
  }

  //<-- PRANAYAMA

  //--> MEDITATION

  UnguidedMeditationSession get unguidedMeditationSession =>
      _uMeditationSession;

  /// Returns the current session's remain delta for progress indicator.
  /// Uses advanced session when in advanced mode, otherwise uses unguided session.
  double get currentSessionRemainDelta {
    if (_schedulingMode == SchedulingMode.advanced && _advancedSession != null) {
      return _advancedSession!.remainDelta;
    }
    return _uMeditationSession.remainDelta;
  }

  set meditationSessionDuration(double val) {
    _uMeditationSession.sessionDuration = val.round();
    _baseLogic.settings.writeMeditationSessionDuration(
      _uMeditationSession.sessionDuration,
    );

    _baseLogic.trigger();
  }

  set meditationUseSession(bool val) {
    _uMeditationSession.useSessionSound = val;
    _baseLogic.settings.writeMeditationUseSession(
      _uMeditationSession.useSessionSound,
    );

    _baseLogic.trigger();
  }

  set meditationSessionVolume(double val) {
    _uMeditationSession.sessionVolume = val;
    _baseLogic.settings.writeMeditationSessionVolume(
      _uMeditationSession.sessionVolume,
    );

    _baseLogic.trigger();
  }

  set meditationRoundDuration(double val) {
    _uMeditationSession.roundDuration = val.round();
    _baseLogic.settings.writeMeditationRoundDuration(
      _uMeditationSession.roundDuration,
    );

    _baseLogic.trigger();
  }

  set meditationUseRound(bool val) {
    _uMeditationSession.useRoundSound = val;
    _baseLogic.settings.writeMeditationUseRound(
      _uMeditationSession.useRoundSound,
    );

    _baseLogic.trigger();
  }

  set meditationRoundVolume(double val) {
    _uMeditationSession.roundVolume = val;
    _baseLogic.settings.writeMeditationRoundVolume(
      _uMeditationSession.roundVolume,
    );

    _baseLogic.trigger();
  }

  set meditationMinorDuration(double val) {
    _uMeditationSession.minorDuration = val.round();
    _baseLogic.settings.writeMeditationMinorDuration(
      _uMeditationSession.minorDuration,
    );

    _baseLogic.trigger();
  }

  set meditationUseMinor(bool val) {
    _uMeditationSession.useMinorSound = val;
    _baseLogic.settings.writeMeditationUseMinor(
      _uMeditationSession.useMinorSound,
    );

    _baseLogic.trigger();
  }

  set meditationMinorVolume(double val) {
    _uMeditationSession.minorVolume = val;
    _baseLogic.settings.writeMeditationMinorVolume(
      _uMeditationSession.minorVolume,
    );

    _baseLogic.trigger();
  }

  //<-- MEDITATION

  //--> ADVANCED SCHEDULING

  SchedulingMode get schedulingMode => _schedulingMode;

  set schedulingMode(SchedulingMode mode) {
    _schedulingMode = mode;
    _baseLogic.settings.writeSchedulingMode(mode);
    _baseLogic.trigger();
  }

  List<SoundEvent> get advancedEvents => List.unmodifiable(_advancedEvents);

  set advancedEvents(List<SoundEvent> events) {
    _advancedEvents = List<SoundEvent>.from(events);
    _baseLogic.settings.writeCurrentAdvancedSchedule(_advancedEvents);
    _baseLogic.trigger();
  }

  void addAdvancedEvent(SoundEvent event) {
    _advancedEvents.add(event);
    _advancedEvents.sort((a, b) => a.timeMs.compareTo(b.timeMs));
    _baseLogic.settings.writeCurrentAdvancedSchedule(_advancedEvents);
    _baseLogic.trigger();
  }

  void updateAdvancedEventAt(int index, SoundEvent event) {
    if (index >= 0 && index < _advancedEvents.length) {
      _advancedEvents[index] = event;
      _advancedEvents.sort((a, b) => a.timeMs.compareTo(b.timeMs));
      _baseLogic.settings.writeCurrentAdvancedSchedule(_advancedEvents);
      _baseLogic.trigger();
    }
  }

  void removeAdvancedEventAt(int index) {
    if (index >= 0 && index < _advancedEvents.length) {
      _advancedEvents.removeAt(index);
      _baseLogic.settings.writeCurrentAdvancedSchedule(_advancedEvents);
      _baseLogic.trigger();
    }
  }

  void clearAdvancedEvents() {
    _advancedEvents.clear();
    _baseLogic.settings.writeCurrentAdvancedSchedule(_advancedEvents);
    _baseLogic.trigger();
  }

  //<-- ADVANCED SCHEDULING

  //--> APPSETTINGS

  AppSettings get appSettings => _baseLogic.appSettings;

  set appSettingsUseSilenceMode(bool val) =>
      _baseLogic.appSettingsUseSilenceMode = val;

  void enableSilenceModeWithPermission() =>
      _baseLogic.enableSilenceModeWithPermission();

  Future<void> resetToDefaults() async {
    await _baseLogic.settings.resetToDefaults();
    // Reload settings with default values
    _pranayamaSession = await _baseLogic.settings.getPranayamaSession();
    _uMeditationSession = await _baseLogic.settings.getMeditationSession();
    _schedulingMode = await _baseLogic.settings.getSchedulingMode();
    _advancedEvents = await _baseLogic.settings.getCurrentAdvancedSchedule();
    _uMeditationSession.prestartAnimation = _pranayamaSession.enabled;
    await _baseLogic.reloadAppSettings();
    _baseLogic.trigger();
  }

  //<-- APPSETTINGS

  // --> AI meditation

  bool get isAiServiceOnline => _isAiServiceOnline;

  // <-- AI meditation

  void previewSound(String soundType, double volume) {
    String asset;
    Prioriry priority;

    switch (soundType) {
      case 'session':
        asset = 'assets/session_sound.mp3';
        priority = Prioriry.highest;
        break;
      case 'round':
        asset = 'assets/round_sound.mp3';
        priority = Prioriry.high;
        break;
      case 'minor':
        asset = 'assets/minor_sound.mp3';
        priority = Prioriry.medium;
        break;
      case 'metronome':
        asset = 'assets/metronome_sound.mp3';
        priority = Prioriry.lowest;
        break;
      default:
        return;
    }

    _player.playAsset(asset: asset, volume: volume, priority: priority);
  }

  String popSnackInfoMessage() =>
      !_isInitialized ? '' : _baseLogic.popSnackInfoMessage();
}
