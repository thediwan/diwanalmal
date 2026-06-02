import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/currency_formatter.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/currency.dart';
import '../../../providers/currency_provider.dart';

/// Lists all currencies with exchange rates to base.
class CurrenciesScreen extends StatelessWidget {
  const CurrenciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العملات')),
      body: Consumer<CurrencyProvider>(
        builder: (context, provider, _) {
          if (provider.currencies.isEmpty) {
            return const EmptyState(
              message: 'لا توجد عملات.',
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
    final base = context.read<CurrencyProvider>().baseCurrency;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: currency.isBase
              ? AppColors.primary
              : Colors.grey.shade200,
          child: Text(
            currency.symbol,
            style: TextStyle(
              color: currency.isBase ? Colors.white : Colors.black87,
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
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'رئيسية',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: currency.isBase
            ? Text('${currency.code} — سعر الصرف: 1.0')
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العملة'),
        content: Text('حذف ${currency.name} (${currency.code})؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await context.read<CurrencyProvider>().deleteCurrency(currency.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }
}
