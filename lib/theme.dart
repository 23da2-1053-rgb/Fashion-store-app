import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF7B1010);      // Deep maroon
  static const Color background = Color(0xFFF5F0EB);   // Warm cream
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color border = Color(0xFFE0D8D0);
  static const Color inputBg = Color(0xFFF0EBE5);
  static const Color badgeGold = Color(0xFF8B7355);
  static const Color teal = Color(0xFF1A7A7A);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          background: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.cormorantTextTheme().copyWith(
          displayLarge: GoogleFonts.cormorant(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          titleLarge: GoogleFonts.cormorant(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
          bodyMedium: GoogleFonts.jost(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textDark),
          titleTextStyle: GoogleFonts.jost(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 1.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: GoogleFonts.jost(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
}
