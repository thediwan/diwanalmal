import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_text_styles.dart';

/// Inline form feedback severity.
enum FormFeedbackType { success, error, warning }

/// Persistent banner shown inside forms that stay on the same screen after save.
class FormFeedbackBanner extends StatelessWidget {
  const FormFeedbackBanner({
    super.key,
    required this.message,
    required this.type,
    this.onDismiss,
  });

  final String message;
  final FormFeedbackType type;
  final VoidCallback? onDismiss;

  Color _backgroundColor() {
    return switch (type) {
      FormFeedbackType.success => AppColors.success.withValues(alpha: 0.12),
      FormFeedbackType.error => AppColors.expense.withValues(alpha: 0.12),
      FormFeedbackType.warning => AppColors.warning.withValues(alpha: 0.14),
    };
  }

  Color _borderColor() {
    return switch (type) {
      FormFeedbackType.success => AppColors.success,
      FormFeedbackType.error => AppColors.expense,
      FormFeedbackType.warning => AppColors.warning,
    };
  }

  Color _iconColor() => _borderColor();

  IconData _icon() {
    return switch (type) {
      FormFeedbackType.success => Icons.check_circle_outline_rounded,
      FormFeedbackType.error => Icons.error_outline_rounded,
      FormFeedbackType.warning => Icons.info_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _backgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor().withValues(alpha: 0.45)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon(), color: _iconColor(), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
            ),
            if (onDismiss != null) ...[
              const SizedBox(width: 8),
              InkWell(
                onTap: onDismiss,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
