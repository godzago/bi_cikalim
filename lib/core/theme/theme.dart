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
  static const Color textLight = Color(0xFF8A8A8A);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);

  static const double radiusSmall = 10;
  static const double radiusMedium = 12;
  static const double radiusLarge = 18;

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme,
    );

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
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        toolbarHeight: 48,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textLight,
        selectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w400,
          fontSize: 11,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        labelPadding: const EdgeInsets.symmetric(horizontal: 3),
        labelStyle: GoogleFonts.poppins(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        shape: const StadiumBorder(),
        side: BorderSide(color: primary.withValues(alpha: .1)),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: BorderSide(color: primary.withValues(alpha: .07)),
        ),
      ),
      textTheme: baseTextTheme.copyWith(
        headlineLarge: GoogleFonts.poppins(
          textStyle: baseTextTheme.headlineLarge?.copyWith(
            color: textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        headlineMedium: GoogleFonts.poppins(
          textStyle: baseTextTheme.headlineMedium?.copyWith(
            color: textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        titleLarge: GoogleFonts.poppins(
          textStyle: baseTextTheme.titleLarge?.copyWith(
            color: textPrimary,
            fontSize: 18,
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
            fontSize: 14,
            fontWeight: FontWeight.normal, // Regular
          ),
        ),
        bodyMedium: GoogleFonts.poppins(
          textStyle: baseTextTheme.bodyMedium?.copyWith(
            color: textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.normal, // Regular
          ),
        ),
        bodySmall: GoogleFonts.poppins(
          textStyle: baseTextTheme.bodySmall?.copyWith(
            color: textLight,
            fontSize: 11.5,
            fontWeight: FontWeight.normal, // Regular
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600, // SemiBold
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withValues(alpha: .08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withValues(alpha: .08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.poppins(
          color: textLight,
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(44, 44),
          side: BorderSide(color: primary.withValues(alpha: .35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        insetPadding: const EdgeInsets.all(14),
      ),
    );
  }
}
