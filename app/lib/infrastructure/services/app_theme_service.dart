import 'dart:ui';
import 'package:flutter/material.dart';
import '../../entities/app_style.dart';
import '../../service/storage_service.dart';
import '../../service/theme_service.dart';

class AppThemeService extends ThemeService {
  static const String _storageKey = 'theme_name';
  static const String _deepPurpleSchemeName = 'deepPurple';
  static const String _blackSchemeName = 'black';

  final Map<String, AppStyle> _styles = Map.from(<String, AppStyle>{
    _deepPurpleSchemeName: AppStyle(
      initial: Colors.deepPurple, // Keep identity
      primary: Color.fromARGB(
        255,
        94,
        53,
        177,
      ), // Rich purple #5E35B1 (deeper, more vibrant)
      inversePrimary: Color.fromARGB(
        255,
        179,
        157,
        219,
      ), // Soft lavender #B39DDB (elegant, not too bright)
      secondaryInitial: Colors.amberAccent,
      secondary: Color.from(
        alpha: 1.0000,
        red: 0.4392,
        green: 0.3647,
        blue: 0.0510,
        colorSpace: ColorSpace.sRGB,
      ),
      inverseSecondary: Color.from(
        alpha: 1.0000,
        red: 0.8745,
        green: 0.7725,
        blue: 0.4275,
        colorSpace: ColorSpace.sRGB,
      ), // Light rose #FFB3C1 (soft, feminine)
      formBackground: Color.fromARGB(
        255,
        250,
        250,
        250,
      ), // Soft white #FAFAFA (less harsh)
      formText: Color.fromARGB(
        255,
        33,
        33,
        33,
      ), // Dark charcoal #212121 (softer than black)
      formTextDisabled: Color.fromARGB(255, 158, 158, 158), // Colors.grey[500]
      iconDisabled: Color.fromARGB(255, 117, 117, 117), // Colors.grey[600]
      progressIndicatorTheme: ProgressIndicatorThemeData(
        circularTrackColor: Colors.transparent,
        linearTrackColor: const Color.fromARGB(0, 43, 31, 31),
        stopIndicatorColor: Colors.transparent,
        refreshBackgroundColor: Colors.transparent,
        trackGap: 0,
      ),
    ),
    _blackSchemeName: AppStyle(
      initial: Color.fromARGB(
        255,
        26,
        26,
        28,
      ), // Rich dark grey #1A1A1C (softer than pure black)
      primary: Color.fromARGB(255, 42, 42, 46), // Elevated dark surface #2A2A2E
      inversePrimary: Color.fromARGB(
        255,
        38,
        198,
        218,
      ), // Bright cyan #26C6DA (modern, vibrant)
      secondaryInitial: Color.fromARGB(
        255,
        255,
        107,
        107,
      ), // Coral #FF6B6B (warm, inviting)
      secondary: Color.from(
        alpha: 1.0000,
        red: 0.7843,
        green: 0.3216,
        blue: 0.3137,
        colorSpace: ColorSpace.sRGB,
      ), // Deep coral #C85250
      inverseSecondary: Color.fromARGB(
        255,
        255,
        138,
        128,
      ), // Light coral #FF8A80
      formBackground: Color.fromARGB(
        255,
        250,
        250,
        250,
      ), // Soft white #FAFAFA (less harsh)
      formText: Color.fromARGB(
        255,
        33,
        33,
        33,
      ), // Dark charcoal #212121 (softer than black)
      formTextDisabled: Color.fromARGB(255, 158, 158, 158), // Colors.grey[500]
      iconDisabled: Color.fromARGB(255, 117, 117, 117), // Colors.grey[600]
      progressIndicatorTheme: ProgressIndicatorThemeData(
        circularTrackColor: Colors.transparent,
        linearTrackColor: const Color.fromARGB(0, 43, 31, 31),
        stopIndicatorColor: Colors.transparent,
        refreshBackgroundColor: Colors.transparent,
        trackGap: 0,
      ),
    ),
  });

  final Map<String, AppStyle> _meditationStyles = Map.from(<String, AppStyle>{
    _deepPurpleSchemeName: AppStyle(
      initial: Colors.deepPurple, // Keep deep purple as seed color
      primary: Color.fromARGB(
        255,
        60,
        35,
        110,
      ), // Darker rich purple (dimmed from #5E35B1)
      inversePrimary: Color.fromARGB(
        255,
        120,
        105,
        145,
      ), // Dim lavender (muted from #B39DDB)
      secondaryInitial: Colors.amberAccent,
      secondary: Color.from(
        alpha: 1.0000,
        red: 0.3200,
        green: 0.2650,
        blue: 0.0400,
        colorSpace: ColorSpace.sRGB,
      ), // Dark amber (dimmed from user-friendly)
      inverseSecondary: Color.from(
        alpha: 1.0000,
        red: 0.6000,
        green: 0.5300,
        blue: 0.3000,
        colorSpace: ColorSpace.sRGB,
      ), // Muted gold (dimmed from user-friendly)
      formBackground: Color.fromARGB(255, 18, 18, 20), // Very dark grey-black
      formText: Color.fromARGB(
        255,
        180,
        170,
        175,
      ), // Warm soft grey with purple tint
      formTextDisabled: Color.fromARGB(255, 80, 75, 78), // Dim warm grey
      iconDisabled: Color.fromARGB(255, 60, 55, 58), // Very dim grey
      progressIndicatorTheme: ProgressIndicatorThemeData(
        circularTrackColor: Colors.transparent,
        linearTrackColor: const Color.fromARGB(0, 43, 31, 31),
        stopIndicatorColor: Colors.transparent,
        refreshBackgroundColor: Colors.transparent,
        trackGap: 0,
      ),
    ),
    _blackSchemeName: AppStyle(
      initial: Color.fromARGB(
        255,
        18,
        18,
        20,
      ), // Very dark grey (dimmed from #1A1A1C)
      primary: Color.fromARGB(
        255,
        28,
        28,
        32,
      ), // Dark elevated surface (dimmed from #2A2A2E)
      inversePrimary: Color.fromARGB(
        255,
        25,
        130,
        145,
      ), // Dim cyan (muted from #26C6DA)
      secondaryInitial: Color.fromARGB(
        255,
        160,
        70,
        70,
      ), // Dimmed coral (muted from #FF6B6B)
      secondary: Color.from(
        alpha: 1.0000,
        red: 0.5500,
        green: 0.2300,
        blue: 0.2250,
        colorSpace: ColorSpace.sRGB,
      ), // Darker coral (dimmed from deep coral)
      inverseSecondary: Color.fromARGB(
        255,
        170,
        95,
        85,
      ), // Muted coral (dimmed from #FF8A80)
      formBackground: Color.fromARGB(255, 18, 18, 20), // Very dark grey-black
      formText: Color.fromARGB(
        255,
        180,
        170,
        165,
      ), // Warm soft grey (not pure white)
      formTextDisabled: Color.fromARGB(255, 80, 75, 73), // Dim warm grey
      iconDisabled: Color.fromARGB(255, 60, 55, 53), // Very dim grey
      progressIndicatorTheme: ProgressIndicatorThemeData(
        circularTrackColor: Colors.transparent,
        linearTrackColor: const Color.fromARGB(0, 43, 31, 31),
        stopIndicatorColor: Colors.transparent,
        refreshBackgroundColor: Colors.transparent,
        trackGap: 0,
      ),
    ),
  });

  late String _currentSchemeName;
  bool _isMeditationMode = false;

  final StorageService storage;

  AppThemeService({required this.storage});

  Future<void> init() async {
    final themeName = await storage.read(key: _storageKey);
    _currentSchemeName =
        themeName == null || !_styles.containsKey(themeName)
            ? _deepPurpleSchemeName
            : themeName;
  }

  ThemeData? _currentTheme;

  @override
  String get currentThemeName => _currentSchemeName;

  @override
  List<String> get availableSchemas => [
    _deepPurpleSchemeName,
    _blackSchemeName,
  ];

  @override
  Map<String, String> get availableSchemasLabel => Map.from(<String, String>{
    _deepPurpleSchemeName: 'Deep Purple',
    _blackSchemeName: 'Black',
  });

  @override
  AppStyle get currentAppStyle {
    if (_isMeditationMode) {
      return _meditationStyles[_currentSchemeName] ??
          _styles[_currentSchemeName]!;
    }
    return _styles[_currentSchemeName]!;
  }

  @override
  ThemeData get currentTheme {
    if (_currentTheme == null) {
      final appStyle = currentAppStyle;

      _currentTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: appStyle.initial),
        progressIndicatorTheme: appStyle.progressIndicatorTheme,
        useMaterial3: true,
      );
    }

    return _currentTheme!;
  }

  @override
  Future<void> setAppStyle({required String themeName}) async {
    final style = _styles[themeName];
    if (style == null) {
      return;
    }

    _currentSchemeName = themeName;

    final appStyle = currentAppStyle;
    _currentTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: appStyle.initial),
      progressIndicatorTheme: appStyle.progressIndicatorTheme,
      useMaterial3: true,
    );

    await storage.write(key: _storageKey, value: themeName);
  }

  @override
  void setMeditationMode(bool enabled) {
    if (_isMeditationMode == enabled) {
      return; // No change needed
    }

    _isMeditationMode = enabled;

    // Rebuild theme with appropriate color scheme
    final appStyle = currentAppStyle;
    _currentTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: appStyle.initial),
      progressIndicatorTheme: appStyle.progressIndicatorTheme,
      useMaterial3: true,
    );
  }
}
