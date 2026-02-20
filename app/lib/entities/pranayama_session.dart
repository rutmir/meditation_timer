import '../player.dart';
import '../utils.dart';

class PranayamaSession {
  static const int durationMin = 1;
  static const int durationMax = 20;
  static const double volumeMin = 0.0;
  static const double volumeMax = 1.0;

  bool enabled = true;
  int _duration = 2;
  int _durationMils = 0;
  int _remainMils = 0;
  bool useMetronome = true;
  double _metronomeVolume = volumeMax;
  int _lastMetronomePlayMs = -1;

  PranayamaSession({
    bool? enabled,
    int? duration,
    bool? useMetronome,
    double? metronomeVolume,
  }) {
    if (enabled != null) {
      this.enabled = enabled;
    }

    if (duration != null) {
      _duration = trimInt(duration, durationMin, durationMax);
    }

    _durationMils = _duration * 60 * 1000;
    _remainMils = _durationMils;

    if (useMetronome != null) {
      this.useMetronome = useMetronome;
    }

    if (metronomeVolume != null) {
      _metronomeVolume = trimDouble(metronomeVolume, volumeMin, volumeMax);
    }
  }

  int get duration => _duration;
  set duration(int val) {
    _duration = trimInt(val, durationMin, durationMax);

    _durationMils = _duration * 60 * 1000;
    _remainMils = _durationMils;
  }

  double get durationValue => _duration.toDouble();

  double get volume => _metronomeVolume;
  set volume(double val) =>
      _metronomeVolume = trimDouble(val, volumeMin, volumeMax);

  bool get isCompleted => !enabled || _remainMils < 0;

  double get remainDelta =>
      _durationMils > 0
          ? 1.0 - _remainMils.toDouble() / _durationMils.toDouble()
          : 0.0;

  int get durationMils => enabled ? _durationMils : 0;

  void reset() {
    _remainMils = _durationMils;
    _lastMetronomePlayMs = -1;
  }

  void processTick(
    AudioController player,
    int milliseconds,
    Function(String) setDisplayTime,
  ) {
    if (!enabled) return;

    _remainMils = _durationMils - milliseconds;
    setDisplayTime(transformRemainMilliSeconds(_remainMils));

    if (_remainMils < 0) return;

    if (useMetronome) {
      // Calculate the next expected metronome time (next second boundary)
      int nextMetronomeMs = (_lastMetronomePlayMs ~/ 1000 + 1) * 1000;

      if (milliseconds >= nextMetronomeMs) {
        // Calculate how many seconds we've passed
        int secondsSkipped = (milliseconds - nextMetronomeMs) ~/ 1000 + 1;

        // Limit catch-up sounds to avoid overwhelming the user
        int soundsToPlay = secondsSkipped > 3 ? 1 : secondsSkipped;

        for (int i = 0; i < soundsToPlay; i++) {
          player.playAsset(
            asset: 'assets/metronome_sound.mp3',
            volume: _metronomeVolume,
            priority: Prioriry.lowest,
          );
        }

        // Update to the actual second boundary we just passed
        _lastMetronomePlayMs = nextMetronomeMs + (secondsSkipped - 1) * 1000;
      }
    }
  }
}
