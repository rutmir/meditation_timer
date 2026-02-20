import 'package:uuid/uuid.dart';
import 'sound_event.dart';

/// A named collection of sound events that can be saved and loaded.
class CustomSchedule {
  /// Unique identifier (UUID)
  final String id;

  /// User-provided name for the schedule
  final String name;

  /// List of sound events (sorted by timeMs)
  final List<SoundEvent> events;

  /// When the schedule was created
  final DateTime createdAt;

  /// When the schedule was last modified
  final DateTime modifiedAt;

  CustomSchedule({
    String? id,
    required this.name,
    required List<SoundEvent> events,
    DateTime? createdAt,
    DateTime? modifiedAt,
  })  : id = id ?? const Uuid().v4(),
        events = List<SoundEvent>.from(events)
          ..sort((a, b) => a.timeMs.compareTo(b.timeMs)),
        createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now();

  /// Creates a copy with optional field overrides
  CustomSchedule copyWith({
    String? id,
    String? name,
    List<SoundEvent>? events,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return CustomSchedule(
      id: id ?? this.id,
      name: name ?? this.name,
      events: events ?? this.events,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
    );
  }

  /// JSON serialization
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'events': events.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
      };

  /// JSON deserialization
  factory CustomSchedule.fromJson(Map<String, dynamic> json) {
    return CustomSchedule(
      id: json['id'] as String,
      name: json['name'] as String,
      events: (json['events'] as List<dynamic>)
          .map((e) => SoundEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
    );
  }

  /// Get events that are valid for the given session duration
  List<SoundEvent> getValidEventsForDuration(int sessionDurationMs) {
    return events.where((e) => e.timeMs <= sessionDurationMs).toList();
  }

  /// Get events that exceed the given session duration
  List<SoundEvent> getInvalidEventsForDuration(int sessionDurationMs) {
    return events.where((e) => e.timeMs > sessionDurationMs).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomSchedule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CustomSchedule(id: $id, name: $name, events: ${events.length})';
}
