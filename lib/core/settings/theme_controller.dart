import 'package:flutter/material.dart';

import '../../data/services/app_settings_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  AppSettingsService _settingsService = AppSettingsService();
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void initialize({AppSettingsService? settingsService}) {
    _settingsService = settingsService ?? AppSettingsService();
    _themeMode = _settingsService.getThemeMode();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) {
      return;
    }

    await _settingsService.setThemeMode(themeMode);
    _themeMode = themeMode;
    notifyListeners();
  }
}
