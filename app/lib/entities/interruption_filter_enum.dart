enum InterruptionFilterEnum {
  filterUnknown,
  filterAll,
  filterPriority,
  filterNone,
  filterAlarms;

  static String stringValue(InterruptionFilterEnum option) => switch (option) {
    InterruptionFilterEnum.filterUnknown => 'INTERRUPTION_FILTER_UNKNOWN',
    InterruptionFilterEnum.filterAll => 'INTERRUPTION_FILTER_ALL',
    InterruptionFilterEnum.filterPriority => 'INTERRUPTION_FILTER_PRIORITY',
    InterruptionFilterEnum.filterNone => 'INTERRUPTION_FILTER_NONE',
    InterruptionFilterEnum.filterAlarms => 'INTERRUPTION_FILTER_ALARMS',
  };
}
