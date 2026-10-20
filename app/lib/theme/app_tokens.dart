import 'package:flutter/material.dart';

class AppTokens {
  // Dark Palette (Cockpit In-Car Theme)
  static const Color darkBackground = Color(0xFF0B0F17);
  static const Color darkSurface = Color(0xFF141A23);
  static const Color darkSurfaceElevated = Color(0xFF1A2230);
  static const Color darkBorder = Color(0xFF1E293B);
  static const Color darkBorderHigh = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkAccent = Color(0xFF00E5FF); // Electric Cyan Pulse

  // Light Palette (Daylight Glare-Free In-Car Theme)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderHigh = Color(0xFFCBD5E1);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightAccent = Color(0xFF00838F); // Deep Aegean Cyan

  // Semantic Status Hues (WCAG AA)
  static const Color statusHealthy = Color(0xFF10B981); // Emerald
  static const Color statusWatch = Color(0xFFF59E0B);   // Amber
  static const Color statusWarning = Color(0xFFF97316); // Warm Orange
  static const Color statusCritical = Color(0xFFEF4444); // Crimson

  // Radius Tokens
  static const double radiusSm = 6.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;

  // Touch Ergonomics (Min 48px target for in-car mounts)
  static const double minTouchTarget = 48.0;

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
