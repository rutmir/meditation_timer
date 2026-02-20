import 'dart:async';
import 'dart:collection';
import 'package:synchronized/synchronized.dart';
import 'package:just_audio/just_audio.dart';

enum Prioriry { highest, high, medium, low, lowest }

extension EnumComparisonOperators<Prioriry extends Enum> on Prioriry {
  bool operator <(Prioriry other) {
    return index < other.index;
  }

  bool operator <=(Prioriry other) {
    return index <= other.index;
  }

  bool operator >(Prioriry other) {
    return index > other.index;
  }

  bool operator >=(Prioriry other) {
    return index >= other.index;
  }
}

class _PlayListItem {
  final String asset;
  final double? volume;

  _PlayListItem({required this.asset, this.volume});
}

class AudioController {
  final _playlock = Lock();
  final _servicelock = Lock();
  final _player = AudioPlayer();
  final _playList = Queue<_PlayListItem>();
  Function()? _onComplete;
  StreamSubscription<PlayerState>? _stateSubscription;

  AudioController() {
    _stateSubscription = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_onComplete != null) _onComplete!();
      }
    });
  }

  bool _inWork = false;
  Prioriry _currentPlayListPrioriry = Prioriry.lowest;

  bool get isBusy => _inWork || _playList.isNotEmpty;
  set isBusy(bool val) {
    _inWork = val;
  }

  Future<void> playAudio({
    required String base64Data,
    void Function()? onComplete,
  }) async {
    _inWork = true;
    _onComplete = () {
      _inWork = false;
      if (onComplete != null) onComplete();
    };

    try {
      final audioData = Uri.parse('data:audio/mpeg;base64,$base64Data');
      final source = AudioSource.uri(audioData);
      await _player.setAudioSource(source);
      await _player.play();
      // .then((_) {
      //   _inWork = false;
      //   if (onComplete != null) onComplete();
      // });
    } catch (_) {
      _inWork = false;
      _onComplete = null;
    }
  }

  Future<void> stop() async {
    _player.stop();
    _playList.clear();
    _inWork = false;
  }

  Future<void> pause() async {
    final inWork = _inWork;
    _player.pause().then((_) {
      if (inWork) _inWork = true;
    });
  }

  Future<void> play(void Function()? onComplete) async {
    if (_player.audioSource != null) {
      _inWork = true;
      _onComplete = () {
        _inWork = false;
        if (onComplete != null) onComplete();
      };
      await _player.play();
    }
  }

  void clear() => _playList.clear();

  Future<void> playAsset({
    required String asset,
    Prioriry? priority,
    double? volume,
  }) async {
    _onComplete = null;

    await _servicelock.synchronized(() async {
      final localPriority = priority ?? Prioriry.lowest;

      // Allow metronome (lowest priority) to always queue
      // Other lower priority sounds are dropped when higher priority is playing
      if (localPriority < _currentPlayListPrioriry &&
          _playList.isNotEmpty &&
          localPriority != Prioriry.lowest) {
        return;
      }

      // Same priority OR metronome - add to queue
      if (priority == _currentPlayListPrioriry || localPriority == Prioriry.lowest) {
        _playList.add(_PlayListItem(asset: asset, volume: volume));
        await _playNext();

        return;
      }

      // Higher priority - clear queue and interrupt
      _playList.clear();
      await _player.stop();

      _playList.add(_PlayListItem(asset: asset, volume: volume));
      _currentPlayListPrioriry = localPriority;
      _inWork = false;
      await _playNext();
    });
  }

  Future<void> _playNext() async {
    await _playlock.synchronized(() async {
      if (_playList.isEmpty) {
        _currentPlayListPrioriry = Prioriry.lowest;
        return;
      }

      if (_inWork) {
        return;
      }
      _inWork = true;

      final item = _playList.removeFirst();

      await _player.setAsset(item.asset);
      // Always set volume, use 1.0 as default if not specified
      await _player.setVolume(item.volume ?? 1.0);

      await _player.play();
      _inWork = false;

      // Process next item while still in lock to avoid race condition
      if (_playList.isNotEmpty) {
        await _playNext();
      } else {
        _currentPlayListPrioriry = Prioriry.lowest;
      }
    });
  }

  void dispose() {
    _stateSubscription?.cancel();
    _player.dispose();
  }
}
