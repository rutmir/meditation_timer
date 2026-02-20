import 'dart:convert';

import '../../entities/app_settings.dart';
import '../../entities/scheduling_mode.dart';
import '../../entities/sound_event.dart';
import '../../entities/unguided_meditation_session.dart';
import '../../entities/pranayama_session.dart';
import '../../service/settings_service.dart';
import '../../service/storage_service.dart';

class AppSettingsService extends SettingsService {
  static const _pranayamaEnabledKey = 'pranayama_enabled';
  static const _pranayamaDurationKey = 'pranayama_duration';
  static const _pranayamaUseMetronomeKey = 'pranayama_use_metronome';
  static const _pranayamaMetronomeValueKey = 'pranayama_metronome_value';

  static const _meditationSessionDurationKey = 'meditation_session_duration';
  static const _meditationUseSessionSoundKey = 'meditation_use_session_sound';
  static const _meditationSessionVolumeKey = 'meditation_session_volume';
  static const _meditationRoundDurationKey = 'meditation_round_duration';
  static const _meditationUseRoundSoundKey = 'meditation_use_round_sound';
  static const _meditationRoundVolumeKey = 'meditation_round_volume';
  static const _meditationMinorDurationKey = 'meditation_minor_duration';
  static const _meditationUseMinorSoundKey = 'meditation_use_minor_sound';
  static const _meditationMinorVolumeKey = 'meditation_minor_volume';

  static const _settingsUseSilenceModeKey = 'settings_use_silence_mode';
  static const _settingsPermissionDismissedKey =
      'settings_silence_permission_dismissed';

  // Advanced scheduling mode keys
  static const _schedulingModeKey = 'scheduling_mode';
  static const _currentAdvancedScheduleKey = 'current_advanced_schedule';

  final StorageService storage;

  AppSettingsService({required this.storage});

  @override
  Future<PranayamaSession> getPranayamaSession() async {
    bool? enabled;
    int? duration;
    bool? useMetronome;
    double? metronomeValue;

    final rawEnabled = await storage.read(key: _pranayamaEnabledKey);
    if (rawEnabled != null) {
      enabled = rawEnabled == 'true';
    }

    final rawDuration = await storage.read(key: _pranayamaDurationKey);
    if (rawDuration != null) {
      duration = int.tryParse(rawDuration);
    }

    final rawUseMetronome = await storage.read(key: _pranayamaUseMetronomeKey);
    if (rawUseMetronome != null) {
      useMetronome = rawUseMetronome == 'true';
    }

    final rawMetronomeValue = await storage.read(
      key: _pranayamaMetronomeValueKey,
    );
    if (rawMetronomeValue != null) {
      metronomeValue = double.tryParse(rawMetronomeValue);
    }

    return PranayamaSession(
      enabled: enabled,
      duration: duration,
      useMetronome: useMetronome,
      metronomeVolume:
          metronomeValue != null &&
                  (metronomeValue >= 0.0 || metronomeValue <= 1.0)
              ? metronomeValue
              : null,
    );
  }

  @override
  Future<void> writePranayamaEnabled(bool val) =>
      storage.write(key: _pranayamaEnabledKey, value: val ? 'true' : 'false');

  @override
  Future<void> writePranayamaDuration(int duration) =>
      storage.write(key: _pranayamaDurationKey, value: duration.toString());

  @override
  Future<void> writePranayamaUseMetronome(bool val) => storage.write(
    key: _pranayamaUseMetronomeKey,
    value: val ? 'true' : 'false',
  );

  @override
  Future<void> writePranayamaVolume(double val) =>
      storage.write(key: _pranayamaMetronomeValueKey, value: val.toString());

  @override
  Future<UnguidedMeditationSession> getMeditationSession() async {
    int? sessionDuration;
    bool? useSessionSound;
    double? sessionVolume;
    int? roundDuration;
    bool? useRoundSound;
    double? roundVolume;
    int? minorDuration;
    bool? useMinorSound;
    double? minorVolume;

    final rawSessionDuration = await storage.read(
      key: _meditationSessionDurationKey,
    );
    if (rawSessionDuration != null) {
      sessionDuration = int.tryParse(rawSessionDuration);
    }

    final rawUseSessionSound = await storage.read(
      key: _meditationUseSessionSoundKey,
    );
    if (rawUseSessionSound != null) {
      useSessionSound = rawUseSessionSound == 'true';
    }

    final rawSessionVolume = await storage.read(
      key: _meditationSessionVolumeKey,
    );
    if (rawSessionVolume != null) {
      sessionVolume = double.tryParse(rawSessionVolume);
    }

    final rawRoundDuration = await storage.read(
      key: _meditationRoundDurationKey,
    );
    if (rawRoundDuration != null) {
      roundDuration = int.tryParse(rawRoundDuration);
    }

    final rawUseRoundSound = await storage.read(
      key: _meditationUseRoundSoundKey,
    );
    if (rawUseRoundSound != null) {
      useRoundSound = rawUseRoundSound == 'true';
    }

    final rawRoundVolume = await storage.read(key: _meditationRoundVolumeKey);
    if (rawRoundVolume != null) {
      roundVolume = double.tryParse(rawRoundVolume);
    }

    final rawMinorDuration = await storage.read(
      key: _meditationMinorDurationKey,
    );
    if (rawMinorDuration != null) {
      minorDuration = int.tryParse(rawMinorDuration);
    }

    final rawUseMinorSound = await storage.read(
      key: _meditationUseMinorSoundKey,
    );
    if (rawUseMinorSound != null) {
      useMinorSound = rawUseMinorSound == 'true';
    }

    final rawMinorVolume = await storage.read(key: _meditationMinorVolumeKey);
    if (rawMinorVolume != null) {
      minorVolume = double.tryParse(rawMinorVolume);
    }

    return UnguidedMeditationSession(
      useSessionSound: useSessionSound,
      sessionDuration: sessionDuration,
      sessionVolume: sessionVolume,
      useRoundSound: useRoundSound,
      roundDuration: roundDuration,
      roundVolume: roundVolume,
      useMinorSound: useMinorSound,
      minorDuration: minorDuration,
      minorVolume: minorVolume,
    );
  }

  @override
  Future<void> writeMeditationSessionDuration(int duration) => storage.write(
    key: _meditationSessionDurationKey,
    value: duration.toString(),
  );

  @override
  Future<void> writeMeditationUseSession(bool val) => storage.write(
    key: _meditationUseSessionSoundKey,
    value: val ? 'true' : 'false',
  );

  @override
  Future<void> writeMeditationSessionVolume(double val) =>
      storage.write(key: _meditationSessionVolumeKey, value: val.toString());

  @override
  Future<void> writeMeditationRoundDuration(int duration) => storage.write(
    key: _meditationRoundDurationKey,
    value: duration.toString(),
  );

  @override
  Future<void> writeMeditationUseRound(bool val) => storage.write(
    key: _meditationUseRoundSoundKey,
    value: val ? 'true' : 'false',
  );

  @override
  Future<void> writeMeditationRoundVolume(double val) =>
      storage.write(key: _meditationRoundVolumeKey, value: val.toString());

  @override
  Future<void> writeMeditationMinorDuration(int duration) => storage.write(
    key: _meditationMinorDurationKey,
    value: duration.toString(),
  );

  @override
  Future<void> writeMeditationUseMinor(bool val) => storage.write(
    key: _meditationUseMinorSoundKey,
    value: val ? 'true' : 'false',
  );

  @override
  Future<void> writeMeditationMinorVolume(double val) =>
      storage.write(key: _meditationMinorVolumeKey, value: val.toString());

  @override
  Future<AppSettings> getAppSettings() async {
    bool useSilenceMode = true;
    bool permissionDismissed = false;

    final rawUseSilenceMode = await storage.read(
      key: _settingsUseSilenceModeKey,
    );

    if (rawUseSilenceMode != null) {
      useSilenceMode = rawUseSilenceMode == 'true';
    }

    final rawPermissionDismissed = await storage.read(
      key: _settingsPermissionDismissedKey,
    );

    if (rawPermissionDismissed != null) {
      permissionDismissed = rawPermissionDismissed == 'true';
    }

    return AppSettings(
      useSilenceMode: useSilenceMode,
      silenceModePermissionDismissed: permissionDismissed,
    );
  }

  @override
  Future<void> writeAppSettingsUseSilenceMode(bool val) => storage.write(
    key: _settingsUseSilenceModeKey,
    value: val ? 'true' : 'false',
  );

  @override
  Future<void> writeAppSettingsPermissionDismissed(bool val) => storage.write(
    key: _settingsPermissionDismissedKey,
    value: val ? 'true' : 'false',
  );

  @override
  Future<void> resetToDefaults() async {
    // Delete all settings keys to reset to entity default values
    await Future.wait([
      storage.delete(key: _pranayamaEnabledKey),
      storage.delete(key: _pranayamaDurationKey),
      storage.delete(key: _pranayamaUseMetronomeKey),
      storage.delete(key: _pranayamaMetronomeValueKey),
      storage.delete(key: _meditationSessionDurationKey),
      storage.delete(key: _meditationUseSessionSoundKey),
      storage.delete(key: _meditationSessionVolumeKey),
      storage.delete(key: _meditationRoundDurationKey),
      storage.delete(key: _meditationUseRoundSoundKey),
      storage.delete(key: _meditationRoundVolumeKey),
      storage.delete(key: _meditationMinorDurationKey),
      storage.delete(key: _meditationUseMinorSoundKey),
      storage.delete(key: _meditationMinorVolumeKey),
      storage.delete(key: _settingsUseSilenceModeKey),
      storage.delete(key: _settingsPermissionDismissedKey),
      storage.delete(key: _schedulingModeKey),
      storage.delete(key: _currentAdvancedScheduleKey),
    ]);
  }

  // --> Advanced Scheduling Mode

  @override
  Future<SchedulingMode> getSchedulingMode() async {
    final rawMode = await storage.read(key: _schedulingModeKey);
    return SchedulingModeExtension.fromStorageString(rawMode);
  }

  @override
  Future<void> writeSchedulingMode(SchedulingMode mode) => storage.write(
        key: _schedulingModeKey,
        value: mode.toStorageString(),
      );

  @override
  Future<List<SoundEvent>> getCurrentAdvancedSchedule() async {
    final rawSchedule = await storage.read(key: _currentAdvancedScheduleKey);
    if (rawSchedule == null || rawSchedule.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(rawSchedule) as List<dynamic>;
      return jsonList
          .map((e) => SoundEvent.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.timeMs.compareTo(b.timeMs));
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> writeCurrentAdvancedSchedule(List<SoundEvent> events) async {
    final sortedEvents = List<SoundEvent>.from(events)
      ..sort((a, b) => a.timeMs.compareTo(b.timeMs));
    final jsonString = jsonEncode(sortedEvents.map((e) => e.toJson()).toList());
    await storage.write(key: _currentAdvancedScheduleKey, value: jsonString);
  }

  // <-- Advanced Scheduling Mode
}
