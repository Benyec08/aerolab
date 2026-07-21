import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';

import '../hive/hive_boxes.dart';

class AppSettingsService {
  static const String _themeModeKey = 'theme_mode';

  Box<dynamic> get _box {
    if (!Hive.isBoxOpen(HiveBoxes.settings)) {
      throw StateError('Ayarlar Hive kutusu henüz açılmadı.');
    }

    return Hive.box<dynamic>(HiveBoxes.settings);
  }

  ThemeMode getThemeMode() {
    final storedValue = _box.get(
      _themeModeKey,
      defaultValue: ThemeMode.system.name,
    );

    return ThemeMode.values.firstWhere(
      (mode) => mode.name == storedValue,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _box.put(_themeModeKey, themeMode.name);
  }
}
