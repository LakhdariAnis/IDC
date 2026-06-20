import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors (from idc_design_system.html)
  static const Color background = Color(0xFF0D0E1A);
  static const Color card = Color(0xFF161728);
  static const Color cardActiveGlow = Color(0xFF1C1E33);
  static const Color borderSubtle = Color(0x0FFFFFFF); // rgba(255,255,255,0.06) is approx 0x0FFFFFFF or 0x10FFFFFF
  static const Color crimson = Color(0xFFE0185A);
  static const Color green = Color(0xFF39FF14);
  static const Color violetBorder = Color(0x666C3FDB); // rgba(108,63,219,0.4)
  static const Color violetGlow = Color(0xFF6C3FDB);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8A8FAD);
  static const Color textDim = Color(0xFF5A5D78);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      background: background,
      surface: card,
      primary: crimson,
      secondary: green,
      onBackground: textPrimary,
      onSurface: textPrimary,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        fontFamily: 'Inter',
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textMuted,
        fontFamily: 'Inter',
      ),
    ),
  );
}
