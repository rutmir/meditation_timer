import 'package:flutter/material.dart';
import '../entities/app_style.dart';

abstract class ThemeService {
  List<String> get availableSchemas;
  Map<String, String> get availableSchemasLabel;

  String get currentThemeName;
  AppStyle get currentAppStyle;
  ThemeData get currentTheme;
  Future<void> setAppStyle({required String themeName});
  void setMeditationMode(bool enabled);
}
