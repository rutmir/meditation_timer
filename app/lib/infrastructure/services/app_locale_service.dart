import 'dart:ui';
import '../../service/locale_service.dart';
import '../../service/storage_service.dart';

class AppLocaleService extends LocaleService {
  static const String _storageKey = 'app_locale';

  final StorageService storage;

  Locale? _currentLocale;

  AppLocaleService({required this.storage});

  Future<void> init() async {
    final localeCode = await storage.read(key: _storageKey);
    if (localeCode != null && _isValidLocale(localeCode)) {
      _currentLocale = Locale(localeCode);
    }
  }

  bool _isValidLocale(String localeCode) {
    return supportedLocales.any((locale) => locale.languageCode == localeCode);
  }

  @override
  List<Locale> get supportedLocales => const [
    Locale('en'),
    Locale('ru'),
    Locale('es'),
    Locale('fr'),
  ];

  @override
  Map<String, String> get localeLabels => {
    'en': 'English',
    'ru': 'Русский',
    'es': 'Español',
    'fr': 'Français',
  };

  @override
  Locale? get currentLocale => _currentLocale;

  @override
  Future<void> setLocale(Locale locale) async {
    if (!_isValidLocale(locale.languageCode)) {
      return;
    }

    _currentLocale = locale;
    await storage.write(key: _storageKey, value: locale.languageCode);
  }

  @override
  Future<void> clearLocale() async {
    _currentLocale = null;
    await storage.delete(key: _storageKey);
  }

  @override
  bool get isRu => _currentLocale?.languageCode == 'ru';

  @override
  bool get isEn => _currentLocale?.languageCode == 'en';
}
