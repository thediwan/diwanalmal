import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/helpers/currency_formatter.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/summary_card.dart';
import '../../providers/currency_provider.dart';
import '../../providers/wallet_provider.dart';

/// Main dashboard — Phase 1 shows balance summary and recent wallets.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
      ),
      body: Consumer2<WalletProvider, CurrencyProvider>(
        builder: (context, walletProvider, currencyProvider, _) {
          final baseCurrency = currencyProvider.baseCurrency;
          final baseCode = baseCurrency?.code ?? '---';
          final totalBalance = walletProvider.totalBalanceInBase;

          return RefreshIndicator(
            onRefresh: () async {
              walletProvider.loadWallets();
              currencyProvider.loadCurrencies();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SummaryCard(
                  title: 'الرصيد الحالي',
                  value: CurrencyFormatter.formatWithCode(totalBalance, baseCode),
                  accentColor: AppColors.primary,
                  icon: Icons.account_balance_wallet,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'دخل الشهر',
                        value: CurrencyFormatter.formatWithCode(0, baseCode),
                        accentColor: AppColors.success,
                        icon: Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        title: 'مصروف الشهر',
                        value: CurrencyFormatter.formatWithCode(0, baseCode),
                        accentColor: AppColors.expense,
                        icon: Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('المحافظ', style: AppTextStyles.headingSmall),
                    TextButton(
                      onPressed: () => context.go('/wallets'),
                      child: const Text('عرض الكل'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (walletProvider.wallets.isEmpty)
                  EmptyState(
                    message: 'لا توجد محافظ بعد.\nأضف محفظتك الأولى.',
                    icon: Icons.account_balance_wallet_outlined,
                    actionLabel: 'إضافة محفظة',
                    onAction: () => context.push('/wallets/add'),
                  )
                else
                  ...walletProvider.wallets.take(5).map((wallet) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Text(
                          wallet.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(wallet.name),
                        subtitle: Text(wallet.currencyCode),
                        trailing: Text(
                          walletProvider.formattedBalance(wallet),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المرحلة 1', style: AppTextStyles.label),
                        const SizedBox(height: 4),
                        Text(
                          'تم إعداد العملات والمحافظ. المصروفات والإيرادات في المرحلة 2.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/wallets/add'),
        icon: const Icon(Icons.add),
        label: const Text('محفظة'),
      ),
    );
  }
}
