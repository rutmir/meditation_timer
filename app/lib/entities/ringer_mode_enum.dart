enum RingerModeEnum {
  modeSilent,
  modeVibrate,
  modeNormal;

  static String stringValue(RingerModeEnum option) => switch (option) {
    RingerModeEnum.modeSilent => 'RINGER_MODE_SILENT',
    RingerModeEnum.modeVibrate => 'RINGER_MODE_VIBRATE',
    RingerModeEnum.modeNormal => 'RINGER_MODE_NORMAL',
  };
}
