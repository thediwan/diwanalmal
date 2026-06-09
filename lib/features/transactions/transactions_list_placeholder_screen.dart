import 'package:flutter/material.dart';

import '../../core/extensions/context_l10n.dart';
import '../../core/theme/app_text_styles.dart';

/// Placeholder until transactions list module is implemented.
class TransactionsListPlaceholderScreen extends StatelessWidget {
  const TransactionsListPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navTransactions)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.comingSoon,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
