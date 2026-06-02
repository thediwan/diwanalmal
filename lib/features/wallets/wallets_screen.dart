import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/wallet_provider.dart';

/// Lists all wallets with calculated balances.
class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المحافظ')),
      body: Consumer<WalletProvider>(
        builder: (context, provider, _) {
          if (provider.wallets.isEmpty) {
            return EmptyState(
              message: 'لا توجد محافظ.\nأضف كاش، بنك، أو محفظة إلكترونية.',
              icon: Icons.account_balance_wallet_outlined,
              actionLabel: 'إضافة محفظة',
              onAction: () => context.push('/wallets/add'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.wallets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final wallet = provider.wallets[index];

              return Card(
                child: ListTile(
                  leading: Text(
                    wallet.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(wallet.name, style: AppTextStyles.bodyLarge),
                  subtitle: Text('عملة: ${wallet.currencyCode}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        provider.formattedBalance(wallet),
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (wallet.initialBalance != provider.balanceFor(wallet))
                        Text(
                          'رصيد محسوب',
                          style: AppTextStyles.bodySmall,
                        ),
                    ],
                  ),
                  onTap: () => context.push('/wallets/${wallet.id}/edit'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/wallets/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
