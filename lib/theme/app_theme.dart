import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFE65100); // Warm POS Orange
  static const Color primaryDark = Color(0xFFBF360C);
  static const Color primaryLight = Color(0xFFFFCCBC);
  static const Color secondary = Color(0xFF263238); // Dark Slate
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color bgLight = Color(0xFFF4F6F9);
  
  static const Color success = Color(0xFF2E7D32);
  static const Color danger = Color.fromARGB(255, 28, 124, 176);
  static const Color warning = Color.fromARGB(255, 38, 135, 135);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 146, 14, 128),
      primary: const Color.fromARGB(255, 80, 16, 163),
      secondary: secondary,
      surface: surfaceLight,
    ),
    scaffoldBackgroundColor: bgLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: secondary,
      elevation: 0.5,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 135, 45, 144),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 13, 90, 131),
      brightness: Brightness.dark,
      primary: const Color.fromARGB(255, 33, 42, 146),
      secondary: const Color.fromARGB(255, 185, 18, 140),
      surface: const Color(0xFF242424),
    ),
    scaffoldBackgroundColor: const Color(0xFF181818),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF242424),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF242424),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 64, 40, 143),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}
