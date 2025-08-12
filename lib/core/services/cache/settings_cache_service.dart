import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsCacheService {
  final SharedPreferences _prefs;

  static const _kThemeKey = 'app_theme';
  static const _kLocaleKey = 'app_locale';

  SettingsCacheService(this._prefs);


  Future<void> saveTheme(ThemeMode themeMode) async {
    await _prefs.setString(_kThemeKey, themeMode.name);
  }

  ThemeMode loadTheme() {
    final themeString = _prefs.getString(_kThemeKey);
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  Future<void> saveLocale(Locale locale) async {
    await _prefs.setString(_kLocaleKey, locale.languageCode);
  }

  Locale loadLocale() {
    final langCode = _prefs.getString(_kLocaleKey);
    if (langCode != null && langCode.isNotEmpty) {
      return Locale(langCode);
    }
    
    return const Locale('en');
  }
}