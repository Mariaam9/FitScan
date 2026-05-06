import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/app_theme.dart';
import '../core/l10n/app_localizations.dart';
import '../services/settings_service.dart';
import 'routes.dart';

class FitScanApp extends StatefulWidget {
  const FitScanApp({super.key});

  @override
  FitScanAppState createState() => FitScanAppState(); 
}


class FitScanAppState extends State<FitScanApp> {
  final SettingsService _settingsService = SettingsService();
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('fr', 'FR');
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final themeMode = await _settingsService.getThemeMode();
      final locale = await _settingsService.getLocale();
      
      if (mounted) {
        setState(() {
          _themeMode = themeMode;
          _locale = locale;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur chargement settings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void updateTheme(ThemeMode mode) {
    if (mounted) {
      setState(() {
        _themeMode = mode;
      });
    }
  }

  void updateLocale(Locale locale) {
    if (mounted) {
      setState(() {
        _locale = locale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp.router(
      title: 'FitScan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
        Locale('ar', 'TN'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: routerConfig,
    );
  }
}