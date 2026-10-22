import 'package:flutter/material.dart';

class AppTokens {
  // Dark Palette (Minimalist Obsidian Cockpit)
  static const Color darkBackground = Color(0xFF090B0E);
  static const Color darkSurface = Color(0xFF11141A);
  static const Color darkSurfaceElevated = Color(0xFF161B22);
  static const Color darkBorder = Color(0x18FFFFFF); // Crisp hairline border
  static const Color darkBorderHigh = Color(0x2EFFFFFF);
  static const Color darkTextPrimary = Color(0xFFECEFF4);
  static const Color darkTextSecondary = Color(0xFF8A94A6);
  static const Color darkTextMuted = Color(0xFF525C6C);
  static const Color darkAccent = Color(0xFF38BDF8); // Subtle Glacier Slate

  // Light Palette (Warm Editorial Bone / Alabaster)
  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF0F2F5);
  static const Color lightBorder = Color(0x12000000);
  static const Color lightBorderHigh = Color(0x22000000);
  static const Color lightTextPrimary = Color(0xFF121824);
  static const Color lightTextSecondary = Color(0xFF5C6575);
  static const Color lightTextMuted = Color(0xFF909AAB);
  static const Color lightAccent = Color(0xFF0284C7);

  // Semantic Status Hues (Muted, Non-Gaudy)
  static const Color statusHealthy = Color(0xFF10B981); // Calm Emerald
  static const Color statusWatch = Color(0xFFF59E0B);   // Soft Amber
  static const Color statusWarning = Color(0xFFF97316); // Warm Coral
  static const Color statusCritical = Color(0xFFEF4444); // Controlled Crimson

  // Radius Tokens (Architectural & Crisp)
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 14.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 9999.0;

  // Touch Ergonomics
  static const double minTouchTarget = 44.0;

  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OK':
      case 'HEALTHY':
        return statusHealthy;
      case 'WATCH':
      case 'WATCHLIST':
        return statusWatch;
      case 'WARNING':
        return statusWarning;
      case 'CRITICAL':
      case 'HIGH RISK':
        return statusCritical;
      default:
        return statusHealthy;
    }
  }

  static Color getScoreColor(int score) {
    if (score >= 85) return statusHealthy;
    if (score >= 70) return statusWatch;
    if (score >= 50) return statusWarning;
    return statusCritical;
  }
}
