import 'package:meditimer/utils.dart';
import '../player.dart';
import 'meditation_script.dart';

enum SessionStage { introduction, body, conclusion }

class AiMeditationSession {
  static const int _prestartMills = 5000;

  final MeditationScript _script;
  Map<int, String> _tracks = {};

  SessionStage stage = SessionStage.introduction;

  int _durationMills = 0;
  int _remainMills = 0;
  bool _prestartAnimation = false;
  int _prestartAnimationLoops = 1;
  int _remainPrestartMills = 0;
  bool _firstBodyTick = true;
  int _timerShiftMills = 0;
  bool _isSessionCompleted = false;
  Function()? _playFinalizer;
  Function()? _playFinalizerWait;

  AiMeditationSession({
    required MeditationScript script,
    required int scriptDuration,
  }) : _script = script {
    _durationMills = scriptDuration * 60 * 1000;
    _remainMills = _durationMills;

    _prestartAnimation = _script.conclusionAudio != null;
    _tracks = _script.body.fold<Map<int, String>>({}, (prev, element) {
      prev.addAll(
        element.phase.items.fold<Map<int, String>>({}, (iprev, ielement) {
          if (ielement.audio != null) {
            iprev[ielement.startTime] = ielement.audio!;
          }

          return iprev;
        }),
      );

      return prev;
    });
  }

  double get remainDelta =>
      !_isPrestartCompleted && _remainPrestartMills < _prestartMills
          ? 1.0 - (((_remainPrestartMills / _prestartMills) - 0.5) * 2).abs()
          : _durationMills > 0
          ? 1.0 - (_remainMills / _durationMills)
          : 0.0;

  bool get _isPrestartCompleted =>
      stage != SessionStage.introduction || _prestartAnimation == false;

  int get durationMils => _durationMills;
  bool get isCompleted => _isSessionCompleted;

  Function()? get playFinalizer => _playFinalizer;

  void saveFinalizer() {
    _playFinalizerWait = _playFinalizer;
    _playFinalizer = null;
  }

  void restoreFinalizer() {
    _playFinalizer = _playFinalizerWait;
    _playFinalizerWait = null;
  }

  void processTick(
    AudioController player,
    int milliseconds,
    Function(String) setDisplayTime,
  ) {
    switch (stage) {
      case SessionStage.introduction:
        if (_script.introductionAudio == null) {
          _timerShiftMills = milliseconds;
          stage =
              _tracks.isNotEmpty ? SessionStage.body : SessionStage.conclusion;
          return;
        }

        if (!player.isBusy) {
          _playFinalizer = () {
            _prestartAnimation = false;
            _timerShiftMills = milliseconds;
            stage =
                _tracks.isNotEmpty
                    ? SessionStage.body
                    : SessionStage.conclusion;
          };
          player.playAudio(
            base64Data: _script.introductionAudio!,
            onComplete: () {
              if (_playFinalizer != null) _playFinalizer!();
            },
          );
        }

        _remainPrestartMills =
            (_prestartMills * _prestartAnimationLoops) - milliseconds;
        if (_remainPrestartMills <= 0 && _prestartAnimation) {
          _prestartAnimationLoops += 1;
          _remainPrestartMills = _prestartMills;
        }

        return;
      case SessionStage.body:
        if (_firstBodyTick) {
          _timerShiftMills = milliseconds;
          if (!player.isBusy) {
            _firstBodyTick = false;
            player.clear();
            player.playAsset(
              asset: 'assets/session_sound.mp3',
              // volume: _sessionVolume,
              priority: Prioriry.highest,
            );
          }

          return;
        }

        final currentTimeMills = milliseconds - _timerShiftMills;
        _remainMills = _durationMills - currentTimeMills;
        if (_remainMills >= 0) {
          setDisplayTime(transformRemainMilliSeconds(_remainMills));
        }

        if (!player.isBusy) {
          final currentTimeSec = currentTimeMills / 1000;

          final timemark = _tracks.keys.firstWhere(
            (x) => x < currentTimeSec,
            orElse: () => -1,
          );

          if (timemark >= 0) {
            final audio = _tracks.remove(timemark);
            if (audio != null) {
              _playFinalizer = () {
                if (_tracks.isEmpty) stage = SessionStage.conclusion;
              };
              player.isBusy = true;
              player.playAudio(
                base64Data: audio,
                onComplete: () {
                  if (_playFinalizer != null) _playFinalizer!();
                },
              );
            }
          }
        }

        return;
      case SessionStage.conclusion:
        if (_script.conclusionAudio == null) {
          _isSessionCompleted = true;
          return;
        }

        final currentTimeMills = milliseconds - _timerShiftMills;
        _remainMills = _durationMills - currentTimeMills;
        if (_remainMills >= 0) {
          setDisplayTime(transformRemainMilliSeconds(_remainMills));
        }

        if (!player.isBusy) {
          _playFinalizer = () => _isSessionCompleted = true;
          player.isBusy = true;
          player.playAudio(
            base64Data: _script.conclusionAudio!,
            onComplete: () {
              if (_playFinalizer != null) _playFinalizer!();
            },
          );
        }

        return;
    }
  }
}
