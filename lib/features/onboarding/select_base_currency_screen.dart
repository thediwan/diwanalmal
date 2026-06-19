import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/currency_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../core/extensions/context_feedback.dart';

/// First-run screen to pick the base currency.
class SelectBaseCurrencyScreen extends StatefulWidget {
  const SelectBaseCurrencyScreen({super.key});

  @override
  State<SelectBaseCurrencyScreen> createState() =>
      _SelectBaseCurrencyScreenState();
}

class _SelectBaseCurrencyScreenState extends State<SelectBaseCurrencyScreen> {
  String? _selectedCode;
  bool _isSaving = false;

  Future<void> _confirmSelection() async {
    if (_selectedCode == null) return;

    final preset = AppConstants.presetCurrencies.firstWhere(
      (c) => c['code'] == _selectedCode,
    );

    setState(() => _isSaving = true);

    try {
      final currencyProvider = context.read<CurrencyProvider>();
      final settingsProvider = context.read<SettingsProvider>();

      await currencyProvider.createBaseCurrency(
        code: preset['code']!,
        name: preset['name']!,
        symbol: preset['symbol']!,
      );

      if (!mounted) return;
      await context.read<WalletProvider>().loadWallets();
      await settingsProvider.markSetupComplete(preset['code']!);

      if (mounted) {
        context.showSuccessFeedback(context.l10n.onboardingBaseCurrencySuccess);
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        context.showOperationError(e, currencyContext: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text(
                'مرحباً بك في ${AppConstants.appName}',
                style: AppTextStyles.headingLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'اختر العملة الرئيسية للتطبيق. ستُستخدم لعرض إجمالي أرصدتك.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  itemCount: AppConstants.presetCurrencies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final currency = AppConstants.presetCurrencies[index];
                    final code = currency['code']!;
                    final isSelected = _selectedCode == code;

                    return Card(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                          : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade200,
                          child: Text(
                            currency['symbol']!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        title: Text(
                          currency['name']!,
                          style: AppTextStyles.bodyLarge,
                        ),
                        subtitle: Text(code),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                            : null,
                        onTap: () => setState(() => _selectedCode = code),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _selectedCode == null || _isSaving
                    ? null
                    : _confirmSelection,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('متابعة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
