// import 'dart:ffi';
// import 'package:fixnum/fixnum.dart';

import './language_enum.dart';

class MeditationInfo {
  final int timestamp;
  final String title;
  final int duration;
  final LanguageEnum language;

  MeditationInfo({
    required this.timestamp,
    required this.title,
    required this.duration,
    required this.language,
  });
}
