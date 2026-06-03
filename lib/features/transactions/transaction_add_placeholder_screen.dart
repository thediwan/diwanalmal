import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_l10n.dart';
import '../../core/theme/app_text_styles.dart';

/// Placeholder until add-transaction flow is implemented.
class TransactionAddPlaceholderScreen extends StatelessWidget {
  const TransactionAddPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionAddTitle),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.transactionAddComingSoon,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),
        ),
      ),
    );
  }
}
