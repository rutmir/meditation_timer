import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'infrastructure/l10n/generated/app_localizations.dart';
import 'infrastructure/locator.dart';
import 'service/locale_service.dart';
import 'service/theme_service.dart';
import 'views/meditation_timer_page.dart';

// final _colorScheme = ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent);

class ThemeProvider extends ChangeNotifier {
  final ThemeService service;

  ThemeProvider({required this.service});

  ThemeData get currentTheme => service.currentTheme;

  void toggleTheme() async {
    final current = service.currentThemeName;
    final guess = service.availableSchemas.firstWhere(
      (test) => test != current,
    );

    await service.setAppStyle(themeName: guess);

    notifyListeners();
  }
}

class LocaleProvider extends ChangeNotifier {
  final LocaleService service;

  LocaleProvider({required this.service});

  Locale? get currentLocale => service.currentLocale;

  Future<void> setLocale(Locale locale) async {
    await service.setLocale(locale);
    notifyListeners();
  }

  Future<void> clearLocale() async {
    await service.clearLocale();
    notifyListeners();
  }
}

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();

  final locator = await buildServices();
  final themeService = locator.get<ThemeService>();
  final localeService = locator.get<LocaleService>();

  // await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  // await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  //SystemChrome.setEnabledSystemUIMode(
  //  SystemUiMode.manual,
  //  overlays: [SystemUiOverlay.top],
  //);
  // SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
  //   _debouncer.run(() {
  //     SystemChrome.setEnabledSystemUIMode(
  //       SystemUiMode.manual,
  //       overlays: [SystemUiOverlay.top],
  //     );
  //   });
  // });

  // SystemChrome.setSystemUIOverlayStyle(
  //   SystemUiOverlayStyle(
  //     statusBarColor: AppColors.transparent,
  //     statusBarBrightness: Brightness.light,
  //     statusBarIconBrightness: Brightness.light,
  //     systemNavigationBarColor: AppColors.transparent,
  //     systemNavigationBarDividerColor: null,
  //     systemNavigationBarIconBrightness: Brightness.light,
  //   ),
  // );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then(
    (value) => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => ThemeProvider(service: themeService),
          ),
          ChangeNotifierProvider(
            create: (context) => LocaleProvider(service: localeService),
          ),
        ],
        child: MediTimerApp(),
      ),
    ),
  );
}

class MediTimerApp extends StatelessWidget {
  const MediTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context).currentLocale;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meditation Timer',
      theme: Provider.of<ThemeProvider>(context).currentTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // supportedLocales: [Locale('fr')],
      home: const MeditationTimerPage(),
    );
  }
}
