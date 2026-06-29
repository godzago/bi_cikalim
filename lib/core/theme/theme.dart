import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BiCikalimTheme {
  static const Color primary = Color(0xFFFF5722);
  static const Color primaryDark = Color(0xFFE64A19);
  static const Color accent = Color(0xFFFF7043);

  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: GoogleFonts.poppins().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textLight,
        selectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.poppins(
          textStyle: baseTextTheme.headlineLarge?.copyWith(
            color: textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        headlineMedium: GoogleFonts.poppins(
          textStyle: baseTextTheme.headlineMedium?.copyWith(
            color: textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleLarge: GoogleFonts.poppins(
          textStyle: baseTextTheme.titleLarge?.copyWith(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600, // SemiBold
          ),
        ),
        titleMedium: GoogleFonts.poppins(
          textStyle: baseTextTheme.titleMedium?.copyWith(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600, // SemiBold
          ),
        ),
        bodyLarge: GoogleFonts.poppins(
          textStyle: baseTextTheme.bodyLarge?.copyWith(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.normal, // Regular
          ),
        ),
        bodyMedium: GoogleFonts.poppins(
          textStyle: baseTextTheme.bodyMedium?.copyWith(
            color: textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.normal, // Regular
          ),
        ),
        bodySmall: GoogleFonts.poppins(
          textStyle: baseTextTheme.bodySmall?.copyWith(
            color: textLight,
            fontSize: 12,
            fontWeight: FontWeight.normal, // Regular
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600, // SemiBold
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.poppins(
          color: textLight,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
