import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_theme.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/wallet_provider.dart';
import '../../../services/dashboard_service.dart';
import 'dashboard_screen_content.dart';

/// Layout wrapper for the dashboard — handles FAB visibility by width.
class DashboardScreenView extends StatelessWidget {
  const DashboardScreenView({
    super.key,
    required this.l10n,
    required this.data,
    required this.onRefresh,
    required this.onReloadAfterNavigation,
  });

  final AppLocalizations l10n;
  final DashboardSnapshot data;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onReloadAfterNavigation;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      builder: (context, sizeClass) {
        final showFab = sizeClass == WindowSizeClass.compact;

        return Scaffold(
          floatingActionButton: showFab
              ? FloatingActionButton(
                  onPressed: () async {
                    await context.push('/transactions/add');
                    await onReloadAfterNavigation();
                  },
                  elevation: 6,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: context.appColors.onPrimary,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, size: 32),
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.startFloat,
          body: Consumer2<WalletProvider, CurrencyProvider>(
            builder: (context, walletProvider, currencyProvider, _) {
              return DashboardScreenContent(
                l10n: l10n,
                data: data,
                walletProvider: walletProvider,
                currencyProvider: currencyProvider,
                onRefresh: onRefresh,
                onAddGoal: () async {
                  await context.push('/goals/add');
                  await onReloadAfterNavigation();
                },
                onGoalTap: (goalId) async {
                  await context.push('/goals/$goalId');
                  await onReloadAfterNavigation();
                },
              );
            },
          ),
        );
      },
    );
  }
}
