import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/currency_provider.dart';
import '../../providers/settings_provider.dart';

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

      await settingsProvider.markSetupComplete(preset['code']!);

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
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
                          ? AppColors.primary.withOpacity(0.08)
                          : null,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? AppColors.primary
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
                            ? const Icon(Icons.check_circle, color: AppColors.primary)
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
