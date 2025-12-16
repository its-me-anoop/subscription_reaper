import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color kColorBackground = Color(0xFF0A0A0A); // Darker background
  static const Color kColorNeonRed = Color(0xFFFF2A1F); // More vibrant red
  static const Color kColorNeonGreen = Color(0xFF00FF41); // Matrix green
  static const Color kColorWhite = Colors.white;
  static const Color kColorGrey = Color(0xFF555555);
  static const Color kColorLightGrey = Color(0xFFE0E0E0);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kColorBackground,
      primaryColor: kColorNeonRed,
      colorScheme: const ColorScheme.dark(
        primary: kColorNeonRed,
        secondary: kColorNeonGreen,
        surface: kColorBackground,
        error: kColorNeonRed,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.robotoMono(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: kColorWhite,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: kColorWhite,
        ),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: kColorWhite),
        bodyMedium: GoogleFonts.robotoMono(
          fontSize: 14,
          color: kColorLightGrey,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: kColorBackground,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kColorNeonGreen,
        foregroundColor: kColorBackground,
      ),
    );
  }
}
