import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/helpers/currency_formatter.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/currency.dart';
import '../../../providers/currency_provider.dart';
import '../../../core/extensions/context_feedback.dart';

/// Lists all currencies with exchange rates to base.
class CurrenciesScreen extends StatelessWidget {
  const CurrenciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.currenciesTitle)),
      body: Consumer<CurrencyProvider>(
        builder: (context, provider, _) {
          if (provider.currencies.isEmpty) {
            return EmptyState(
              message: l10n.currenciesEmpty,
              icon: Icons.currency_exchange,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.currencies.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final currency = provider.currencies[index];
              return _CurrencyTile(currency: currency);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/settings/currencies/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({required this.currency});

  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final base = context.read<CurrencyProvider>().baseCurrency;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: currency.isBase
              ? Theme.of(context).colorScheme.primary
              : colors.surfaceVariant,
          child: Text(
            currency.symbol,
            style: TextStyle(
              color: currency.isBase ? colors.onPrimary : colors.textPrimary,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(currency.name, style: AppTextStyles.bodyLarge),
            if (currency.isBase) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.currencyBaseBadge,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: currency.isBase
            ? Text(l10n.currencyExchangeRateBase(currency.code))
            : Text(
                '${currency.code} — 1 ${currency.code} = '
                '${CurrencyFormatter.formatWithCode(currency.rateToBase, base?.code ?? '')}',
              ),
        trailing: currency.isBase
            ? null
            : IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    context.push('/settings/currencies/${currency.id}/edit'),
              ),
        onLongPress: currency.isBase
            ? null
            : () => _confirmDelete(context, currency),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Currency currency) async {
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.currencyDeleteTitle),
        content: Text(l10n.currencyDeleteMessage(currency.name, currency.code)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<CurrencyProvider>().deleteCurrency(currency.id);
      if (context.mounted) {
        context.showSuccessFeedback(context.l10n.currencyDeleteSuccess);
      }
    } catch (e) {
      if (context.mounted) {
        context.showOperationError(e);
      }
    }
  }
}
