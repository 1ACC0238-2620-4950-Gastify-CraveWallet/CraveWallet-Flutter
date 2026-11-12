import 'package:flutter/material.dart';

abstract final class CraveColors {
  static const navy = Color(0xFF0F172A);
  static const primary = Color(0xFF3B4FD8);
  static const orange = Color(0xFFF97316);
  static const surface = Color(0xFFF8FAFC);
  static const muted = Color(0xFF64748B);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFFBBF24);
  static const error = Color(0xFFEF4444);
}

abstract final class CraveTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: CraveColors.primary,
      brightness: Brightness.light,
      primary: CraveColors.primary,
      secondary: CraveColors.orange,
      surface: Colors.white,
      error: CraveColors.error,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: CraveColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: CraveColors.surface,
        foregroundColor: CraveColors.navy,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

