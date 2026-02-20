import 'dart:ui';

abstract class LocaleService {
  List<Locale> get supportedLocales;
  Map<String, String> get localeLabels;

  Locale? get currentLocale;
  Future<void> setLocale(Locale locale);
  Future<void> clearLocale();
  bool get isRu;
  bool get isEn;
}
