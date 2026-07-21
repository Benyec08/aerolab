import 'package:flutter/material.dart';

import 'core/settings/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/hangar/aircraft_hangar_page.dart';

class AeroLabApp extends StatelessWidget {
  final ThemeController? themeController;

  const AeroLabApp({super.key, this.themeController});

  @override
  Widget build(BuildContext context) {
    final controller = themeController ?? ThemeController.instance;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'AeroLab',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: controller.themeMode,
          home: const DashboardPage(),
          routes: {'/hangar': (context) => const AircraftHangarPage()},
        );
      },
    );
  }
}
