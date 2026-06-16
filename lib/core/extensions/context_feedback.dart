import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../helpers/user_facing_error.dart';
import 'context_l10n.dart';

/// Styled success / warning / error snack bars for form and list actions.
extension ContextFeedback on BuildContext {
  /// Green floating snack bar for completed actions.
  void showSuccessFeedback(String message) {
    _showFeedbackSnackBar(
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  /// Red floating snack bar for failures.
  void showErrorFeedback(String message) {
    _showFeedbackSnackBar(
      message: message,
      backgroundColor: AppColors.expense,
      icon: Icons.error_outline_rounded,
    );
  }

  /// Amber snack bar for validation and blocked actions.
  void showWarningFeedback(String message) {
    _showFeedbackSnackBar(
      message: message,
      backgroundColor: AppColors.warning,
      icon: Icons.info_outline_rounded,
    );
  }

  /// Maps [error] to a readable message, then shows an error snack bar.
  void showOperationError(
    Object error, {
    String? message,
    bool walletContext = false,
    bool currencyContext = false,
  }) {
    final strings = l10n;
    final text = message ??
        (walletContext
            ? UserFacingError.walletMessage(strings, error)
            : currencyContext
                ? UserFacingError.currencyMessage(strings, error)
                : UserFacingError.message(strings, error));
    showErrorFeedback(text);
  }

  void _showFeedbackSnackBar({
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    final messenger = ScaffoldMessenger.of(this);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(
          seconds: backgroundColor == AppColors.expense ? 5 : 3,
        ),
      ),
    );
  }
}
