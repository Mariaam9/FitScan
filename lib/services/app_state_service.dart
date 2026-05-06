import 'package:flutter/material.dart';

class AppStateService {
  static final AppStateService _instance = AppStateService._internal();
  factory AppStateService() => _instance;
  AppStateService._internal();

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('fr', 'FR');
  
  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
  }
  
  void setLocale(Locale locale) {
    _locale = locale;
  }
}