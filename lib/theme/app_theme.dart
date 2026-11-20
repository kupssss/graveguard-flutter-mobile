// ============================================================================
// app_theme.dart
// ============================================================================
import 'package:flutter/material.dart';

class AppColors {
  static const Color navy = Color(0xFF1B2A4A);
  static const Color navyDark = Color(0xFF111C33);
  static const Color navyLight = Color(0xFF2C4A7C);

  static const Color accentRed = Color(0xFFC62828);

  // Neutrals
  static const Color white = Colors.white;
  static const Color offWhite = Color(0xFFF5F7FA);
  static const Color lightBlueGray = Color(0xFFE8EEF5);
  static const Color textDark = Color(0xFF1B2A4A);
  static const Color textMuted = Color(0xFF6B7A8F);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.offWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.navy,
        secondary: AppColors.accentRed,
        surface: AppColors.white,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        headlineMedium: TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: AppColors.textDark),
        bodyMedium: TextStyle(color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}