import '../entities/app_settings.dart';
import '../entities/scheduling_mode.dart';
import '../entities/sound_event.dart';
import '../entities/unguided_meditation_session.dart';
import '../entities/pranayama_session.dart';

abstract class SettingsService {
  Future<PranayamaSession> getPranayamaSession();
  Future<void> writePranayamaEnabled(bool val);
  Future<void> writePranayamaDuration(int duration);
  Future<void> writePranayamaUseMetronome(bool val);
  Future<void> writePranayamaVolume(double val);
  Future<UnguidedMeditationSession> getMeditationSession();
  Future<void> writeMeditationSessionDuration(int duration);
  Future<void> writeMeditationUseSession(bool val);
  Future<void> writeMeditationSessionVolume(double val);
  Future<void> writeMeditationRoundDuration(int duration);
  Future<void> writeMeditationUseRound(bool val);
  Future<void> writeMeditationRoundVolume(double val);
  Future<void> writeMeditationMinorDuration(int duration);
  Future<void> writeMeditationUseMinor(bool val);
  Future<void> writeMeditationMinorVolume(double val);
  Future<AppSettings> getAppSettings();
  Future<void> writeAppSettingsUseSilenceMode(bool val);
  Future<void> writeAppSettingsPermissionDismissed(bool val);
  Future<void> resetToDefaults();

  // Advanced scheduling mode
  Future<SchedulingMode> getSchedulingMode();
  Future<void> writeSchedulingMode(SchedulingMode mode);
  Future<List<SoundEvent>> getCurrentAdvancedSchedule();
  Future<void> writeCurrentAdvancedSchedule(List<SoundEvent> events);
}
