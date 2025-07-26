import 'package:flutter/material.dart';

class AppTheme {
  // Primary Blue Colors (Based on your color palette)
  static const Color primaryBlue = Color(0xFF018ABE);        // Medium blue
  static const Color primaryBlueDark = Color(0xFF001B48);    // Deep navy
  static const Color primaryBlueLight = Color(0xFF97CADB);   // Light blue
  static const Color primaryBlueLighter = Color(0xFFD6E8EE); // Very light blue

  // Secondary Blue Colors
  static const Color secondaryBlue = Color(0xFF02457A);      // Dark blue
  static const Color secondaryBlueDark = Color(0xFF001B48);  // Deep navy
  static const Color secondaryBlueLight = Color(0xFF018ABE); // Medium blue

  // Accent Colors (Complementary to blue theme)
  static const Color accentTeal = Color(0xFF0891B2);
  static const Color accentCyan = Color(0xFF0E7490);
  static const Color accentSky = Color(0xFF0284C7);
  static const Color accentNavy = Color(0xFF1E3A8A);
  static const Color accentIndigo = Color(0xFF4338CA);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color accentViolet = Color(0xFF667EEA);
  static const Color accentPurpleDark = Color(0xFF764BA2);

  // Background Colors
  static const Color backgroundPrimary = Color(0xFFF8FAFC);
  static const Color backgroundSecondary = Color(0xFFFFFFFF);
  static const Color backgroundCard = Color(0xFFF1F8FC);
  static const Color backgroundOverlay = Color(0xFFF0F9FF);

  // Text Colors
  static const Color textPrimary = Color(0xFF001B48);        // Deep navy for primary text
  static const Color textSecondary = Color(0xFF02457A);      // Dark blue for secondary text
  static const Color textTertiary = Color(0xFF64748B);       // Neutral gray-blue
  static const Color textHint = Color(0xFF94A3B8);           // Light gray-blue
  static const Color textMuted = Color(0xFFCBD5E1);          // Very light gray-blue
  static const Color textOnDark = Color(0xFFD6E8EE);         // Light blue for dark backgrounds

  // Border Colors
  static const Color borderLight = Color(0xFFE1E7ED);
  static const Color borderMedium = Color(0xFFB8D4E3);
  static const Color borderDark = Color(0xFF97CADB);

  // Shadow Colors
  static const Color shadowLight = Color(0x0A001B48);
  static const Color shadowMedium = Color(0x1A001B48);
  static const Color shadowDark = Color(0x40001B48);

  // Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    primaryBlueLighter,
    primaryBlueLight,
    primaryBlue,
  ];

  static const List<Color> secondaryGradient = [
    primaryBlue,
    secondaryBlue,
    primaryBlueDark,
  ];

  static const List<Color> darkGradient = [
    primaryBlueDark,
    secondaryBlue,
    primaryBlue,
  ];

  static const List<Color> lightGradient = [
    primaryBlueLighter,
    primaryBlueLight,
    Color(0xFFB8D4E3),
  ];

  static const List<Color> waveGradient = [
    primaryBlueLighter,
    primaryBlueLight,
    primaryBlue,
    secondaryBlue,
  ];

  static const List<Color> overlayGradient = [
    accentTeal,
    accentCyan,
  ];

  static const List<Color> logoGradient = [
    backgroundSecondary,
    backgroundOverlay,
  ];

  static const List<Color> navBarGradient = [
    primaryBlueDark,
    secondaryBlue,
    primaryBlue,
  ];

  static const List<Color> cardGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF8FBFF),
  ];

  static const List<Color> buttonGradient = [
    primaryBlueLight,
    primaryBlue,
  ];

  static const List<Color> accentGradient = [
    accentSky,
    accentNavy,
  ];

  // Input Field Gradients
  static const List<Color> emailGradient = [
    primaryBlue,
    accentTeal,
  ];

  static const List<Color> phoneGradient = [
    primaryBlue,
    secondaryBlue,
  ];

  static const List<Color> passwordGradient = [
    errorRed,
    Color(0xFFDC2626),
  ];

  // Common Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.blue,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundPrimary,
      cardColor: backgroundSecondary,
      dividerColor: borderLight,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        primaryContainer: primaryBlueLight,
        secondary: secondaryBlue,
        secondaryContainer: secondaryBlue,
        surface: backgroundSecondary,
        surfaceVariant: backgroundCard,
        background: backgroundPrimary,
        error: errorRed,
        onPrimary: white,
        onPrimaryContainer: primaryBlueDark,
        onSecondary: white,
        onSecondaryContainer: primaryBlueDark,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        onBackground: textPrimary,
        onError: white,
        outline: borderMedium,
        outlineVariant: borderLight,
        shadow: shadowMedium,
        inverseSurface: primaryBlueDark,
        onInverseSurface: textOnDark,
        inversePrimary: primaryBlueLight,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          color: textSecondary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        titleSmall: TextStyle(
          color: textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.2,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          color: textTertiary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          color: textTertiary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          elevation: 2,
          shadowColor: shadowMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed),
        ),
        labelStyle: const TextStyle(color: textTertiary),
        hintStyle: const TextStyle(color: textHint),
      ),
      cardTheme: CardThemeData(
        color: backgroundSecondary,
        elevation: 2,
        shadowColor: shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundSecondary,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper methods for gradients
  static LinearGradient getPrimaryGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: primaryGradient,
    );
  }

  static LinearGradient getSecondaryGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: secondaryGradient,
    );
  }

  static LinearGradient getDarkGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: darkGradient,
    );
  }

  static LinearGradient getLightGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: lightGradient,
    );
  }

  // Helper method for box shadows
  static List<BoxShadow> getElevationShadow({
    double elevation = 4,
    Color? shadowColor,
  }) {
    return [
      BoxShadow(
        color: shadowColor ?? shadowMedium,
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
    ];
  }

  // Helper method for border radius
  static BorderRadius getBorderRadius({double radius = 12}) {
    return BorderRadius.circular(radius);
  }
}