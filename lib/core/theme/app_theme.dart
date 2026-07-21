import 'package:flutter/material.dart';

class AppTheme {
  static const Color _seedColor = Color(0xFF1565C0);

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF4F7FB),
      cardTheme: const CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF42A5F5),
      brightness: Brightness.dark,
      surface: const Color(0xFF172033),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E293B),
        surfaceTintColor: Colors.transparent,
      ),
      canvasColor: const Color(0xFF1E293B),
      dividerColor: const Color(0xFF475569),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFF8FAFC)),
        bodyMedium: TextStyle(color: Color(0xFFE2E8F0)),
        bodySmall: TextStyle(color: Color(0xFFCBD5E1)),
        titleLarge: TextStyle(color: Color(0xFFF8FAFC)),
        titleMedium: TextStyle(color: Color(0xFFF8FAFC)),
        titleSmall: TextStyle(color: Color(0xFFE2E8F0)),
        headlineSmall: TextStyle(color: Color(0xFFF8FAFC)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF263449),
        labelStyle: TextStyle(color: Color(0xFFE2E8F0)),
        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
        prefixIconColor: Color(0xFF90CAF9),
        suffixIconColor: Color(0xFFCBD5E1),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF64748B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF64B5F6), width: 1.6),
        ),
        border: OutlineInputBorder(),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF263449),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF1E293B),
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF334155),
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: Color(0xFFF8FAFC),
        iconColor: Color(0xFF90CAF9),
      ),
    );
  }
}
