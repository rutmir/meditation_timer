enum LanguageEnum {
  english,
  russian,
  spanish,
  franch;

  static String stringValue(LanguageEnum option) => switch (option) {
    LanguageEnum.english => 'English',
    LanguageEnum.russian => 'Russian',
    LanguageEnum.spanish => 'Spanish',
    LanguageEnum.franch => 'Franch',
  };

  static LanguageEnum? fromString(String option) {
    if (option == 'English' || option == 'en') {
      return LanguageEnum.english;
    }

    if (option == 'Russian' || option == 'ru') {
      return LanguageEnum.russian;
    }

    if (option == 'Spanish' || option == 'es') {
      return LanguageEnum.spanish;
    }

    if (option == 'Franch' || option == 'fr') {
      return LanguageEnum.franch;
    }

    return null;
  }
}
