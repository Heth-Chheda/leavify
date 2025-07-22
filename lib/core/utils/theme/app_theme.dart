import 'package:flutter/material.dart';

class AppTheme {
  // Primary Blue Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBlueDark = Color(0xFF0D47A1);
  static const Color primaryBlueLight = Color(0xFF6EC6FF);
  static const Color primaryBlueLighter = Color(0xFF90CAF9);

  // Secondary Blue Colors
  static const Color secondaryBlue = Color(0xFF1976D2);
  static const Color secondaryBlueDark = Color(0xFF0277BD);

  // Accent Colors
  static const Color accentIndigo = Color(0xFF4338CA);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentViolet = Color(0xFF667EEA);
  static const Color accentPurpleDark = Color(0xFF764BA2);

  // Background Colors
  static const Color backgroundPrimary = Color(0xFFF8FAFC);
  static const Color backgroundSecondary = Color(0xFFFFFFFF);
  static const Color backgroundCard = Color(0xFFF8FAFC);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF374151);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF64748B);

  // Border Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E0);

  // Shadow Colors
  static const Color shadowLight = Color(0x14000000);
  static const Color shadowMedium = Color(0x1F000000);
  static const Color shadowDark = Color(0x40000000);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    primaryBlueLight,
    primaryBlue,
    primaryBlueDark,
  ];

  static const List<Color> secondaryGradient = [accentViolet, accentPurpleDark];

  static const List<Color> waveGradient = [
    primaryBlueLight,
    primaryBlue,
    primaryBlueDark,
  ];

  static const List<Color> overlayGradient = [accentIndigo, accentPurple];

  static const List<Color> logoGradient = [
    backgroundSecondary,
    Color(0xFFF0F9FF),
  ];

  static const List<Color> emailGradient = [
    Color(0xFF3B82F6),
    Color(0xFF1D4ED8),
  ];

  static const List<Color> phoneGradient = [primaryBlue, secondaryBlue];

  static const List<Color> passwordGradient = [
    Color(0xFFEF4444),
    Color(0xFFDC2626),
  ];

  static const List<Color> buttonGradient = [accentViolet, accentPurpleDark];

  // Common Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundPrimary,
      cardColor: backgroundSecondary,
      dividerColor: borderLight,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: secondaryBlue,
        surface: backgroundSecondary,
        background: backgroundPrimary,
        error: Color(0xFFEF4444),
        onPrimary: white,
        onSecondary: white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textSecondary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
