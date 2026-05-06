import 'package:flutter/material.dart';

const Map<String, String> fr = {
  'settings_title': 'Paramètres',
  'settings_theme': 'Apparence',
  'settings_dark_mode': 'Mode sombre',
  'settings_language': 'Langue',
  'settings_sound': 'Son',
  'settings_sound_enabled': 'Effets sonores',
  'settings_vibration': 'Vibration',
  'about_title': 'À propos',
  'home_title': 'Accueil',
  'history_title': 'Historique',
};

const Map<String, String> en = {
  'settings_title': 'Settings',
  'settings_theme': 'Appearance',
  'settings_dark_mode': 'Dark mode',
  'settings_language': 'Language',
  'settings_sound': 'Sound',
  'settings_sound_enabled': 'Sound effects',
  'settings_vibration': 'Vibration',
  'about_title': 'About',
  'home_title': 'Home',
  'history_title': 'History',
};

const Map<String, String> ar = {
  'settings_title': 'الإعدادات',
  'settings_theme': 'المظهر',
  'settings_dark_mode': 'الوضع الداكن',
  'settings_language': 'اللغة',
  'settings_sound': 'الصوت',
  'settings_sound_enabled': 'المؤثرات الصوتية',
  'settings_vibration': 'الاهتزاز',
  'about_title': 'حول التطبيق',
  'home_title': 'الرئيسية',
  'history_title': 'السجل',
};

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'),
    Locale('en', 'US'),
    Locale('ar', 'TN'),
  ];

  Future<bool> load() async {
    switch (locale.languageCode) {
      case 'ar':
        _localizedStrings = ar;
        break;
      case 'en':
        _localizedStrings = en;
        break;
      default:
        _localizedStrings = fr;
    }
    return true;
  }

  String translate(String key) => _localizedStrings[key] ?? key;
  String t(String key) => translate(key);
  bool get isRtl => locale.languageCode == 'ar';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['fr', 'en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}