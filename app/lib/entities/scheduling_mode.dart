/// Enum representing the user's chosen scheduling approach.
enum SchedulingMode {
  /// Existing: sounds at regular intervals (round/minor durations)
  interval,

  /// New: sounds at arbitrary user-defined times
  advanced,
}

/// Extension methods for SchedulingMode
extension SchedulingModeExtension on SchedulingMode {
  /// Convert to string for storage
  String toStorageString() => name;

  /// Parse from storage string
  static SchedulingMode fromStorageString(String? value) {
    if (value == null) return SchedulingMode.interval;
    return SchedulingMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SchedulingMode.interval,
    );
  }
}
