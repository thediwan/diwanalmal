import 'package:flutter/material.dart';

/// Phase 1 mock financial goal for dashboard UI.
class DashboardGoal {
  const DashboardGoal({
    required this.id,
    required this.title,
    required this.progressPercent,
    required this.icon,
  });

  final String id;
  final String title;
  final int progressPercent;
  final IconData icon;
}

/// Phase 1 mock transaction row for dashboard UI.
class DashboardTransaction {
  const DashboardTransaction({
    required this.title,
    required this.subtitle,
    required this.primaryAmount,
    this.secondaryAmount,
    required this.isIncome,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final String primaryAmount;
  final String? secondaryAmount;
  final bool isIncome;
  final IconData icon;
  final Color iconColor;
}

/// Chart point for expense analysis (normalized 0–1).
class DashboardChartPoint {
  const DashboardChartPoint({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;
}
