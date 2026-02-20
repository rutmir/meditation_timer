import 'package:flutter/material.dart';

String transformRemainMilliSeconds(int remainmilliseconds) {
  int hundreds = (remainmilliseconds / 10).truncate();
  int seconds = (hundreds / 100).truncate();

  if (seconds < 0) return '';

  int minutes = (seconds / 60).truncate();
  int hours = (minutes / 60).truncate();

  String hoursStr =
      hours > 0 ? (hours % 60).toString().padLeft(hours > 10 ? 2 : 1, '0') : '';
  String minutesStr = (minutes % 60).toString().padLeft(2, '0');
  String secondsStr = (seconds % 60).toString().padLeft(2, '0');

  return "${hours > 0 ? hoursStr : ''}${hours > 0 ? ':' : ''}$minutesStr:$secondsStr";
}

double trimDouble(double val, double min, double max) {
  return val > max
      ? max
      : val < min
      ? min
      : val;
}

int trimInt(int val, int min, int max) {
  return val > max
      ? max
      : val < min
      ? min
      : val;
}

Size textSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

// T? firstWhereOrNull(bool Function(T element) test) {
//   for (var element in this) {
//     if (test(element)) return element;
//   }
//   return null;
// }

String formatSecondsToMinutesString(int? totalSeconds) {
  if (totalSeconds == null) return '';

  int minutes = totalSeconds ~/ 60;
  int remainingSeconds = totalSeconds % 60;

  String minutesString = minutes.toString().padLeft(2, '0');
  String secondsString = remainingSeconds.toString().padLeft(2, '0');

  return '$minutesString:$secondsString';
}
