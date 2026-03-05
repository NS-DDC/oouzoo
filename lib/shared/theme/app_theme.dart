import 'package:flutter/material.dart';

class AppTheme {
  // Pixel art palette
  static const Color starBlack = Color(0xFF0A0A1A);
  static const Color deepSpace = Color(0xFF12122A);
  static const Color nebulaPurple = Color(0xFF3D1A6E);
  static const Color starYellow = Color(0xFFFFD700);
  static const Color moonWhite = Color(0xFFE8E8F0);
  static const Color accentPink = Color(0xFFFF6B9D);
  static const Color accentCyan = Color(0xFF00E5FF);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: starBlack,
        colorScheme: const ColorScheme.dark(
          primary: starYellow,
          secondary: accentPink,
          tertiary: accentCyan,
          surface: deepSpace,
          onPrimary: starBlack,
          onSecondary: moonWhite,
        ),
        fontFamily: 'DotGothic16',
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: moonWhite, fontSize: 24),
          bodyLarge: TextStyle(color: moonWhite, fontSize: 14),
          bodyMedium: TextStyle(color: moonWhite, fontSize: 12),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: deepSpace,
          foregroundColor: moonWhite,
          elevation: 0,
        ),
      );
}
