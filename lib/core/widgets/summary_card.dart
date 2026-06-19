import 'package:flutter/material.dart';

import '../extensions/context_theme.dart';
import '../theme/app_text_styles.dart';

/// Reusable summary card for dashboard metrics.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.accentColor,
    this.icon,
  });

  final String title;
  final String value;
  final String? subtitle;

  /// Accent color for icon and value. Defaults to [ColorScheme.primary].
  final Color? accentColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final effectiveAccent =
        accentColor ?? Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: effectiveAccent, size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.headingSmall.copyWith(color: effectiveAccent),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: context.appColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
