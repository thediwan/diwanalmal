import 'package:flutter/material.dart';

/// Application color palette.
abstract final class AppColors {
  static const Color primary = Color(0xFF004AC6);
  /// Dashboard / mockup primary blue (#1A56BE).
  static const Color dashboardPrimary = Color(0xFF1A56BE);
  static const Color dashboardPrimaryMuted = Color(0xFF5B8FD9);
  static const Color primaryContainer = Color(0xFF1A56BE);
  static const Color onPrimaryContainer = Color(0xFFEEEFFF);
  static const Color success = Color(0xFF16A34A);
  static const Color expense = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  /// Debts and expense category icons on dashboard.
  static const Color debtAccent = Color(0xFFEA580C);

  static const Color backgroundLight = Color(0xFFF7F9FB);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color textPrimaryLight = Color(0xFF191C1E);
  /// Secondary labels on white/light surfaces — darker for readability.
  static const Color textSecondaryLight = Color(0xFF374151);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  static const Color glassLight = Color(0xCCFFFFFF);
  static const Color glassBorder = Color(0x66FFFFFF);
}
