import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/dashboard_page.dart';

class AeroLabApp extends StatelessWidget {
  const AeroLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AeroLab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardPage(),
    );
  }
}