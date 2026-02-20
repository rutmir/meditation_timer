/// Sound type determines audio file and playback priority.
enum SoundType {
  session, // Priority: highest - uses session sound asset
  round, // Priority: high - uses round sound asset
  minor, // Priority: medium - uses minor sound asset
}

/// Represents a single scheduled sound occurrence within a meditation session.
class SoundEvent {
  /// Time offset from session start (in milliseconds for precision)
  final int timeMs;

  /// Sound type: determines audio file and priority
  final SoundType soundType;

  /// Volume level (0.0 to 1.0)
  final double volume;

  /// Number of times to repeat the sound (1-4)
  final int repeatCount;

  const SoundEvent({
    required this.timeMs,
    required this.soundType,
    required this.volume,
    this.repeatCount = 1,
  });

  /// Validates that the event is within acceptable bounds
  bool isValid(int sessionDurationMs) {
    return timeMs >= 0 &&
        timeMs <= sessionDurationMs &&
        volume >= 0.0 &&
        volume <= 1.0 &&
        repeatCount >= 1 &&
        repeatCount <= 4;
  }

  /// Returns the time in minutes for display
  int get minutes => (timeMs / 60000).floor();

  /// Returns sound type display name
  String get soundTypeName {
    switch (soundType) {
      case SoundType.session:
        return 'Session';
      case SoundType.round:
        return 'Round';
      case SoundType.minor:
        return 'Minor';
    }
  }

  /// Creates a copy with optional field overrides
  SoundEvent copyWith({
    int? timeMs,
    SoundType? soundType,
    double? volume,
    int? repeatCount,
  }) {
    return SoundEvent(
      timeMs: timeMs ?? this.timeMs,
      soundType: soundType ?? this.soundType,
      volume: volume ?? this.volume,
      repeatCount: repeatCount ?? this.repeatCount,
    );
  }

  /// JSON serialization
  Map<String, dynamic> toJson() => {
        'timeMs': timeMs,
        'soundType': soundType.name,
        'volume': volume,
        'repeatCount': repeatCount,
      };

  /// JSON deserialization
  factory SoundEvent.fromJson(Map<String, dynamic> json) {
    return SoundEvent(
      timeMs: json['timeMs'] as int,
      soundType: SoundType.values.firstWhere(
        (e) => e.name == json['soundType'],
        orElse: () => SoundType.minor,
      ),
      volume: (json['volume'] as num).toDouble(),
      repeatCount: (json['repeatCount'] as int?) ?? 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SoundEvent &&
        other.timeMs == timeMs &&
        other.soundType == soundType &&
        other.volume == volume &&
        other.repeatCount == repeatCount;
  }

  @override
  int get hashCode => Object.hash(timeMs, soundType, volume, repeatCount);

  @override
  String toString() =>
      'SoundEvent(timeMs: $timeMs, soundType: $soundType, volume: $volume, repeatCount: $repeatCount)';
}
