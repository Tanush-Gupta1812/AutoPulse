import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/theme/app_tokens.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    final displayTheme = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppTokens.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppTokens.darkTextPrimary,
        onPrimary: AppTokens.darkBackground,
        secondary: AppTokens.darkAccent,
        surface: AppTokens.darkSurface,
        onSurface: AppTokens.darkTextPrimary,
        outline: AppTokens.darkBorder,
        outlineVariant: AppTokens.darkBorderHigh,
        error: AppTokens.statusCritical,
      ),
      cardTheme: CardThemeData(
        color: AppTokens.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          side: const BorderSide(color: AppTokens.darkBorder, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppTokens.darkBackground,
        foregroundColor: AppTokens.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: displayTheme.titleLarge?.copyWith(
          color: AppTokens.darkTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          fontSize: 18,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppTokens.darkSurface,
        selectedItemColor: AppTokens.darkTextPrimary,
        unselectedItemColor: AppTokens.darkTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      textTheme: textTheme.copyWith(
        displayLarge: displayTheme.displayLarge?.copyWith(
          color: AppTokens.darkTextPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.04,
        ),
        headlineLarge: displayTheme.headlineLarge?.copyWith(
          color: AppTokens.darkTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.03,
        ),
        headlineMedium: displayTheme.headlineMedium?.copyWith(
          color: AppTokens.darkTextPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.02,
        ),
        headlineSmall: displayTheme.headlineSmall?.copyWith(
          color: AppTokens.darkTextPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01,
        ),
        titleLarge: displayTheme.titleLarge?.copyWith(
          color: AppTokens.darkTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AppTokens.darkTextPrimary,
          letterSpacing: -0.01,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppTokens.darkTextSecondary,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: AppTokens.darkTextMuted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.darkTextPrimary,
          foregroundColor: AppTokens.darkBackground,
          minimumSize: const Size(64, AppTokens.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          textStyle: displayTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTokens.darkTextPrimary,
          minimumSize: const Size(64, AppTokens.minTouchTarget),
          side: const BorderSide(color: AppTokens.darkBorder, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          textStyle: displayTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: -0.2,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppTokens.darkBorder,
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);
    final displayTheme = GoogleFonts.outfitTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppTokens.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppTokens.lightTextPrimary,
        onPrimary: AppTokens.lightSurface,
        secondary: AppTokens.lightAccent,
        surface: AppTokens.lightSurface,
        onSurface: AppTokens.lightTextPrimary,
        outline: AppTokens.lightBorder,
        outlineVariant: AppTokens.lightBorderHigh,
        error: AppTokens.statusCritical,
      ),
      cardTheme: CardThemeData(
        color: AppTokens.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          side: const BorderSide(color: AppTokens.lightBorder, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppTokens.lightBackground,
        foregroundColor: AppTokens.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: displayTheme.titleLarge?.copyWith(
          color: AppTokens.lightTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          fontSize: 18,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppTokens.lightSurface,
        selectedItemColor: AppTokens.lightTextPrimary,
        unselectedItemColor: AppTokens.lightTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      textTheme: textTheme.copyWith(
        displayLarge: displayTheme.displayLarge?.copyWith(
          color: AppTokens.lightTextPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.04,
        ),
        headlineLarge: displayTheme.headlineLarge?.copyWith(
          color: AppTokens.lightTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.03,
        ),
        headlineMedium: displayTheme.headlineMedium?.copyWith(
          color: AppTokens.lightTextPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.02,
        ),
        titleLarge: displayTheme.titleLarge?.copyWith(
          color: AppTokens.lightTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AppTokens.lightTextPrimary,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppTokens.lightTextSecondary,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: AppTokens.lightTextMuted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.lightTextPrimary,
          foregroundColor: AppTokens.lightSurface,
          minimumSize: const Size(64, AppTokens.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          textStyle: displayTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTokens.lightTextPrimary,
          minimumSize: const Size(64, AppTokens.minTouchTarget),
          side: const BorderSide(color: AppTokens.lightBorder, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppTokens.lightBorder,
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }
}
