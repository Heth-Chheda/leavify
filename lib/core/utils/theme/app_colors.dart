import 'package:flutter/material.dart';

class AppColors {
  // Highlight colors (from image)
  static const Color highlightBlue = Color(0xFF4735DD);
  static const Color highBlue = Color(0xFF1111E1);
  static const Color highlightPink = Color(0xFFFF3E6C);
  static const Color highlightTeal = Color(0xFF61BFC2);
  static const Color highlightOrange = Color(0xFFFFA200);
  static const Color highlightGreen = Color(0xFF51DC8E);
  static const Color highGreen = Color(0xFF25B043);

  // Dark Theme
  static const Color darkBackground = Color(0xFF0A0A1F); // Deep navy
  static const Color darkSurface = Colors.black;
  static const Color darkText = Colors.white;

  // Light Theme
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightText = Colors.black;
}

class AppTheme2 {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightText,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightText),
      bodyMedium: TextStyle(color: AppColors.lightText),
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.highlightBlue,
      secondary: AppColors.highlightPink,
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: AppColors.lightText,
      onSurface: AppColors.lightText,
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkText,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText),
      bodyMedium: TextStyle(color: AppColors.darkText),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.highlightBlue,
      secondary: AppColors.highlightPink,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: AppColors.darkText,
      onSurface: AppColors.darkText,
    ),
  );
}
