import '../player.dart';
import '../utils.dart';

class UnguidedMeditationSession {
  static const int _prestartMills = 5000;
  static const int _chainSoundLimit = 5;
  static const int _minorDurationMin = 1;
  static const int _roundDurationMin = 3;
  static const int _durationMin = 10;
  static const int _durationMax = 180;
  static const double volumeMin = 0.0;
  static const double volumeMax = 1.0;

  bool _prestartAnimation = true;
  int _durationMills = 0;
  int _remainMills = 0;
  int _remainPrestartMills = 0;

  int _sessionDuration = 60;
  double _sessionVolume = volumeMax;
  bool _useSessionSound = true;
  int _roundDuration = 20;
  double _roundVolume = volumeMax;
  bool _useRoundSound = true;
  int _minorDuration = 5;
  double _minorVolume = volumeMax;
  bool useMinorSound = true;

  // running stutus parameters
  bool _playSession = false;
  bool _playRound = false;
  bool _playMinor = false;
  int _lastMinorPlayByMinutes = 0;

  UnguidedMeditationSession({
    int? sessionDuration,
    bool? useSessionSound,
    double? sessionVolume,
    int? roundDuration,
    bool? useRoundSound,
    double? roundVolume,
    int? minorDuration,
    bool? useMinorSound,
    double? minorVolume,
  }) {
    if (useSessionSound != null) {
      _useSessionSound = useSessionSound;
    }

    if (sessionDuration != null) {
      _sessionDuration = trimInt(sessionDuration, _durationMin, _durationMax);
    }

    _durationMills = _sessionDuration * 60 * 1000;
    _remainMills = _durationMills;

    if (sessionVolume != null) {
      _sessionVolume = trimDouble(sessionVolume, volumeMin, volumeMax);
    }

    if (useRoundSound != null) {
      _useRoundSound = useRoundSound;
    }

    _roundDuration = trimInt(
      roundDuration ?? _roundDuration,
      _roundDurationMin,
      _roundDurationMax,
    );

    if (roundVolume != null) {
      _roundVolume = trimDouble(roundVolume, volumeMin, volumeMax);
    }

    if (useMinorSound != null) {
      this.useMinorSound = useMinorSound;
    }

    _minorDuration = trimInt(
      minorDuration ?? _minorDuration,
      _minorDurationMin,
      _minorDurationMax,
    );
    if (_minorDuration <= 0) useMinorSound = false;

    if (minorVolume != null) {
      _minorVolume = trimDouble(minorVolume, volumeMin, volumeMax);
    }
  }

  // --> Session

  bool get useSessionSound => _useSessionSound;
  set useSessionSound(bool val) {
    _useSessionSound = val;

    roundDuration = _roundDuration;
  }

  int get sessionDuration => _sessionDuration;
  set sessionDuration(int val) {
    _sessionDuration = trimInt(val, _durationMin, _durationMax);

    _durationMills = _sessionDuration * 60 * 1000;
    _remainMills = _durationMills;

    roundDuration = _roundDuration;
  }

  double get sessionDurationValue => _sessionDuration.toDouble();

  double get sessionVolume => _sessionVolume;
  set sessionVolume(double val) =>
      _sessionVolume = trimDouble(val, volumeMin, volumeMax);

  // <-- Session

  // --> Round

  bool get useRoundSound => _useRoundSound;
  set useRoundSound(bool val) {
    _useRoundSound = val;

    minorDuration = _minorDuration;
  }

  int get _roundDurationMax {
    final out = _sessionDuration - 1;
    return out > _roundDurationMin ? out : _roundDurationMin + 1;
  }

  double get roundDurationMax => _roundDurationMax.toDouble();

  int get roundDuration => _roundDuration;
  set roundDuration(int val) {
    _roundDuration = trimInt(val, _roundDurationMin, _roundDurationMax);

    minorDuration = _minorDuration;
  }

  double get roundDurationValue => _roundDuration.toDouble();

  double get roundVolume => _roundVolume;
  set roundVolume(double val) =>
      _roundVolume = trimDouble(val, volumeMin, volumeMax);

  // <-- Round

  // --> Minor

  int get _minorDurationMax {
    final out = _useRoundSound ? _roundDuration - 1 : _sessionDuration - 1;
    return out > _minorDurationMin ? out : _minorDurationMin + 1;
  }

  double get minorDurationMax => _minorDurationMax.toDouble();

  int get minorDuration => _minorDuration;
  set minorDuration(int val) {
    _minorDuration = trimInt(val, _minorDurationMin, _minorDurationMax);
  }

  double get minorDurationValue => _minorDuration.toDouble();

  double get minorVolume => _minorVolume;

  set minorVolume(double val) =>
      _minorVolume = trimDouble(val, volumeMin, volumeMax);

  // <-- Minor

  bool get _useChainForRound =>
      (_sessionDuration / _roundDuration).truncate() <= _chainSoundLimit;

  bool get _useChainForMinor {
    final limit = _useRoundSound ? _roundDuration : _sessionDuration;
    return (limit / _minorDuration).truncate() <= _chainSoundLimit;
  }

  bool get isCompleted => _remainMills < 0;

  bool get _isPrestartCompleted =>
      !_prestartAnimation || _remainPrestartMills < 0;

  double get remainDelta =>
      !_isPrestartCompleted && _remainPrestartMills < _prestartMills
          ? 1.0 - (((_remainPrestartMills / _prestartMills) - 0.5) * 2).abs()
          : _durationMills > 0
          ? 1.0 - (_remainMills / _durationMills)
          : 0.0;

  int get durationMils => _durationMills;

  double get durationMin => _durationMin.toDouble();
  double get durationMax => _durationMax.toDouble();
  double get roundDurationMin => _roundDurationMin.toDouble();
  double get minorDurationMin => _minorDurationMin.toDouble();
  set prestartAnimation(bool val) {
    _prestartAnimation = val;
  }

  void reset() {
    _remainPrestartMills = _prestartMills;
    _remainMills = _durationMills;
    _playSession = false;
    _playRound = false;
    _playMinor = false;
    _lastMinorPlayByMinutes = 0;
  }

  void processTick(
    AudioController player,
    int milliseconds,
    Function(String) setDisplayTime,
  ) {
    if (!_isPrestartCompleted) {
      _remainPrestartMills = _prestartMills - milliseconds;
      final newTimeMills =
          ((milliseconds * _durationMills) / _prestartMills).round();
      setDisplayTime(transformRemainMilliSeconds(newTimeMills));

      if (_useSessionSound && !_playSession && (milliseconds < 1000)) {
        _playSession = true;
        player.playAsset(
          asset: 'assets/session_sound.mp3',
          volume: _sessionVolume,
          priority: Prioriry.highest,
        );
      }

      return;
    }

    if (_prestartAnimation) milliseconds -= _prestartMills;
    _remainMills = _durationMills - milliseconds;
    setDisplayTime(transformRemainMilliSeconds(_remainMills));

    if (_remainMills < 0) return;

    final minutes =
        ((milliseconds / (60000)).truncate() % _sessionDuration).round();

    if (!_playSession &&
        ((minutes == 0 && !_prestartAnimation) || _remainMills < 1000)) {
      _playSession = true;

      player.playAsset(
        asset: 'assets/session_sound.mp3',
        volume: _sessionVolume,
        priority: Prioriry.highest,
      );
    } else if (!_playSession &&
        !_playRound &&
        _useRoundSound &&
        minutes % _roundDuration == 0) {
      _playRound = true;

      for (
        var i = _useChainForRound ? (minutes / _roundDuration).round() : 1;
        i > 0;
        i--
      ) {
        player.playAsset(
          asset: 'assets/round_sound.mp3',
          volume: _roundVolume,
          priority: Prioriry.high,
        );
      }
    } else if (!_playSession &&
        !_playRound &&
        !_playMinor &&
        useMinorSound &&
        minutes % _minorDuration == 0) {
      _playMinor = true;
      _lastMinorPlayByMinutes = minutes;
      final localMinutes =
          _useRoundSound ? (minutes % _roundDuration) : minutes;

      for (
        var i =
            _useChainForMinor ? (localMinutes / _minorDuration).round() : 1;
        i > 0;
        i--
      ) {
        player.playAsset(
          asset: 'assets/minor_sound.mp3',
          volume: _minorVolume,
          priority: Prioriry.medium,
        );
      }
    } else {
      if (minutes != 0 && _remainMills > 1000) {
        _playSession = false;
      }

      if (minutes % _roundDuration != 0) {
        _playRound = false;
      }

      if (_lastMinorPlayByMinutes != minutes ||
          minutes % _minorDuration != 0) {
        _playMinor = false;
      }
    }
  }
}
