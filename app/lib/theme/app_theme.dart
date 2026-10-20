import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/theme/app_tokens.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    final outfitTheme = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppTokens.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppTokens.darkAccent,
        onPrimary: Color(0xFF00363D),
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
        centerTitle: false,
        titleTextStyle: outfitTheme.titleLarge?.copyWith(
          color: AppTokens.darkTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppTokens.darkSurface,
        selectedItemColor: AppTokens.darkAccent,
        unselectedItemColor: AppTokens.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: outfitTheme.displayLarge?.copyWith(
          color: AppTokens.darkTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
        ),
        headlineLarge: outfitTheme.headlineLarge?.copyWith(
          color: AppTokens.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: outfitTheme.headlineMedium?.copyWith(
          color: AppTokens.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: outfitTheme.headlineSmall?.copyWith(
          color: AppTokens.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: outfitTheme.titleLarge?.copyWith(
          color: AppTokens.darkTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AppTokens.darkTextPrimary,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppTokens.darkTextSecondary,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: AppTokens.darkTextSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.darkAccent,
          foregroundColor: const Color(0xFF00363D),
          minimumSize: const Size.fromHeight(AppTokens.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          textStyle: outfitTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTokens.darkTextPrimary,
          minimumSize: const Size.fromHeight(AppTokens.minTouchTarget),
          side: const BorderSide(color: AppTokens.darkBorderHigh, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          textStyle: outfitTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);
    final outfitTheme = GoogleFonts.outfitTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppTokens.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppTokens.lightAccent,
        onPrimary: Colors.white,
        surface: AppTokens.lightSurface,
        onSurface: AppTokens.lightTextPrimary,
        outline: AppTokens.lightBorder,
        outlineVariant: AppTokens.lightBorderHigh,
        error: AppTokens.statusCritical,
      ),
      cardTheme: CardThemeData(
        color: AppTokens.lightSurface,
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          side: const BorderSide(color: AppTokens.lightBorder, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppTokens.lightSurface,
        foregroundColor: AppTokens.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: outfitTheme.titleLarge?.copyWith(
          color: AppTokens.lightTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppTokens.lightSurface,
        selectedItemColor: AppTokens.lightAccent,
        unselectedItemColor: AppTokens.lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: outfitTheme.displayLarge?.copyWith(
          color: AppTokens.lightTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
        ),
        headlineLarge: outfitTheme.headlineLarge?.copyWith(
          color: AppTokens.lightTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: outfitTheme.headlineMedium?.copyWith(
          color: AppTokens.lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: outfitTheme.headlineSmall?.copyWith(
          color: AppTokens.lightTextPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: outfitTheme.titleLarge?.copyWith(
          color: AppTokens.lightTextPrimary,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AppTokens.lightTextPrimary,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppTokens.lightTextSecondary,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: AppTokens.lightTextSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.lightAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppTokens.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          textStyle: outfitTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTokens.lightTextPrimary,
          minimumSize: const Size.fromHeight(AppTokens.minTouchTarget),
          side: const BorderSide(color: AppTokens.lightBorderHigh, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          ),
          textStyle: outfitTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
