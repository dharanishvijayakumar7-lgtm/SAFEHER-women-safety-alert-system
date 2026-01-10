import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFF4081); // Pink Accent
  static const Color secondaryColor = Color(0xFF7C4DFF); // Deep Purple Accent
  static const Color backgroundColor = Color(0xFFFCE4EC); // Light Pink Background
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      background: backgroundColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      prefixIconColor: primaryColor,
      labelStyle: TextStyle(color: Colors.grey[700]),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.black26,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primaryColor,
        letterSpacing: 1.2,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    ),
  );
}