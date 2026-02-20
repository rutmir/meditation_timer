import 'package:flutter/material.dart';

class AppStyle {
  final Color initial;
  final Color primary;
  final Color inversePrimary;
  final Color secondaryInitial;
  final Color secondary;
  final Color inverseSecondary;
  final Color formBackground;
  final Color formText;
  final Color formTextDisabled;
  final Color iconDisabled;
  final ProgressIndicatorThemeData progressIndicatorTheme;

  AppStyle({
    required this.initial,
    required this.primary,
    required this.inversePrimary,
    required this.secondaryInitial,
    required this.secondary,
    required this.inverseSecondary,
    required this.formBackground,
    required this.formText,
    required this.formTextDisabled,
    required this.iconDisabled,
    required this.progressIndicatorTheme,
  });
}
