import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors from Stitch Design
  static const Color primaryColor = Color(0xFFFF6F61); // Coral/Salmon
  static const Color backgroundLight = Color(0xFFFFF8F0); // Cream
  static const Color backgroundDark = Color(0xFF0F0F0F); // Almost Black
  static const Color cardLight = Color(0xFFFFF8F0);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF1F1F1F);
  static const Color textDark = Color(0xFFEAEAEA);
  static const Color mutedLight = Color(0xFF6B6B6B);
  static const Color mutedDark = Color(0xFF9D9D9D);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: cardLight,
        background: backgroundLight,
        onPrimary: Colors.white,
        onSurface: textLight,
        onBackground: textLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.light().textTheme,
      ).apply(bodyColor: textLight, displayColor: textLight),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: cardDark,
        background: backgroundDark,
        onPrimary: Colors.white,
        onSurface: textDark,
        onBackground: textDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: textDark, displayColor: textDark),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

class AppColors {
  static const Color primary = AppTheme.primaryColor;
  static const Color secondary = Color(
    0xFF3713ec,
  ); // Keeping the blue as secondary/accent if needed
  static const Color background = AppTheme.backgroundLight;
  static const Color surface = AppTheme.cardLight;
  static const Color error = Color(0xFFB00020);
  static const Color textPrimary = AppTheme.textLight;
  static const Color textSecondary = AppTheme.mutedLight;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color accent = secondary;
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
}

class AppTextStyles {
  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get heading1 => headlineLarge;

  static TextStyle get heading2 => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyLarge =>
      GoogleFonts.plusJakartaSans(fontSize: 16, color: AppColors.textPrimary);

  static TextStyle get bodyMedium =>
      GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textPrimary);

  static TextStyle get bodySmall =>
      GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary);

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}
