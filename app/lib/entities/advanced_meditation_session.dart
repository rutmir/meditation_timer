import '../player.dart';
import '../utils.dart';
import 'sound_event.dart';

/// Runtime session entity for advanced mode playback.
/// Parallels UnguidedMeditationSession but plays sounds at user-defined times
/// instead of regular intervals.
class AdvancedMeditationSession {
  static const int _prestartMills = 5000;
  static const int _durationMin = 10;
  static const int _durationMax = 180;

  /// Duration of the session in minutes
  int _sessionDuration;

  /// Sound events to play during this session (sorted by timeMs)
  final List<SoundEvent> _events;

  /// Track which events have been played (by index)
  final Set<int> _playedEvents = {};

  /// Prestart animation state
  bool _prestartAnimation = true;
  int _durationMills = 0;
  int _remainMills = 0;
  int _remainPrestartMills = 0;

  AdvancedMeditationSession({
    required int sessionDuration,
    required List<SoundEvent> events,
  })  : _sessionDuration = sessionDuration.clamp(_durationMin, _durationMax),
        _events = List<SoundEvent>.from(events)
          ..sort((a, b) => a.timeMs.compareTo(b.timeMs)) {
    _durationMills = _sessionDuration * 60 * 1000;
    _remainMills = _durationMills;
  }

  // --> Getters

  int get sessionDuration => _sessionDuration;
  set sessionDuration(int val) {
    _sessionDuration = val.clamp(_durationMin, _durationMax);
    _durationMills = _sessionDuration * 60 * 1000;
    _remainMills = _durationMills;
  }

  double get sessionDurationValue => _sessionDuration.toDouble();

  List<SoundEvent> get events => List.unmodifiable(_events);

  int get eventCount => _events.length;

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

  set prestartAnimation(bool val) {
    _prestartAnimation = val;
  }

  // <-- Getters

  /// Reset session state for new playback
  void reset() {
    _remainPrestartMills = _prestartMills;
    _remainMills = _durationMills;
    _playedEvents.clear();
  }

  /// Process a timer tick and queue sounds that should play.
  /// Uses ±500ms tolerance window for timing accuracy.
  void processTick(
    AudioController player,
    int milliseconds,
    Function(String) setDisplayTime,
  ) {
    // Handle prestart animation phase
    if (!_isPrestartCompleted) {
      _remainPrestartMills = _prestartMills - milliseconds;
      final newTimeMills =
          ((milliseconds * _durationMills) / _prestartMills).round();
      setDisplayTime(transformRemainMilliSeconds(newTimeMills));

      // Check for events at time 0 during prestart
      if (milliseconds < 1000) {
        _playEventsAtTime(player, 0);
      }

      return;
    }

    // Adjust for prestart offset
    if (_prestartAnimation) milliseconds -= _prestartMills;
    _remainMills = _durationMills - milliseconds;
    setDisplayTime(transformRemainMilliSeconds(_remainMills));

    if (_remainMills < 0) return;

    // Play events that match current time (within tolerance window)
    _playEventsAtTime(player, milliseconds);

    // Handle end-of-session sounds (events at session duration)
    if (_remainMills < 1000) {
      _playEventsAtTime(player, _durationMills);
    }
  }

  /// Play all events that should trigger at the given elapsed time.
  /// Events are played in priority order (session > round > minor).
  void _playEventsAtTime(AudioController player, int elapsedMs) {
    const toleranceMs = 500;

    // Collect events that should play at this time
    final eventsToPlay = <int, SoundEvent>{};

    for (int i = 0; i < _events.length; i++) {
      if (_playedEvents.contains(i)) continue;

      final event = _events[i];
      final timeDiff = (event.timeMs - elapsedMs).abs();

      if (timeDiff <= toleranceMs) {
        eventsToPlay[i] = event;
      }
    }

    if (eventsToPlay.isEmpty) return;

    // Sort by priority (session first, then round, then minor)
    final sortedEntries = eventsToPlay.entries.toList()
      ..sort((a, b) => a.value.soundType.index.compareTo(b.value.soundType.index));

    // Play each event
    for (final entry in sortedEntries) {
      _playedEvents.add(entry.key);
      _playSound(player, entry.value);
    }
  }

  /// Play a single sound event using the audio controller
  void _playSound(AudioController player, SoundEvent event) {
    final String asset;
    final Prioriry priority;

    switch (event.soundType) {
      case SoundType.session:
        asset = 'assets/session_sound.mp3';
        priority = Prioriry.highest;
        break;
      case SoundType.round:
        asset = 'assets/round_sound.mp3';
        priority = Prioriry.high;
        break;
      case SoundType.minor:
        asset = 'assets/minor_sound.mp3';
        priority = Prioriry.medium;
        break;
    }

    // Play the sound repeatCount times (queued sequentially)
    for (int i = 0; i < event.repeatCount; i++) {
      player.playAsset(
        asset: asset,
        volume: event.volume,
        priority: priority,
      );
    }
  }

  /// Add a new event to the schedule
  void addEvent(SoundEvent event) {
    _events.add(event);
    _events.sort((a, b) => a.timeMs.compareTo(b.timeMs));
  }

  /// Remove an event at the given index
  void removeEventAt(int index) {
    if (index >= 0 && index < _events.length) {
      _events.removeAt(index);
      _playedEvents.remove(index);
      // Adjust played events indices
      _playedEvents.removeWhere((i) => i > index);
    }
  }

  /// Update an event at the given index
  void updateEventAt(int index, SoundEvent event) {
    if (index >= 0 && index < _events.length) {
      _events[index] = event;
      _events.sort((a, b) => a.timeMs.compareTo(b.timeMs));
    }
  }

  /// Clear all events
  void clearEvents() {
    _events.clear();
    _playedEvents.clear();
  }

  /// Get events that are valid for the current session duration
  List<SoundEvent> getValidEvents() {
    return _events.where((e) => e.timeMs <= _durationMills).toList();
  }

  /// Get events that exceed the current session duration
  List<SoundEvent> getInvalidEvents() {
    return _events.where((e) => e.timeMs > _durationMills).toList();
  }
}
