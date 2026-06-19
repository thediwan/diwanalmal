import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/responsive/responsive_content.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/layouts/two_column_layout.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/wallet_provider.dart';
import '../../../services/dashboard_service.dart';
import '../data/dashboard_currency_balances.dart';
import 'dashboard_currency_carousel.dart';
import 'dashboard_expense_chart.dart';
import 'dashboard_goals_section.dart';
import 'dashboard_header.dart';
import 'dashboard_monthly_summary.dart';
import 'dashboard_recent_transactions.dart';
import 'dashboard_section_divider.dart';
import 'dashboard_total_balance.dart';

/// Shared dashboard sections — layout-agnostic content widgets.
class DashboardScreenContent extends StatelessWidget {
  const DashboardScreenContent({
    super.key,
    required this.l10n,
    required this.data,
    required this.walletProvider,
    required this.currencyProvider,
    required this.onRefresh,
    required this.onAddGoal,
    required this.onGoalTap,
  });

  final AppLocalizations l10n;
  final DashboardSnapshot data;
  final WalletProvider walletProvider;
  final CurrencyProvider currencyProvider;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onAddGoal;
  final Future<void> Function(String goalId) onGoalTap;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      builder: (context, sizeClass) {
        final wide = isExpandedOrWider(sizeClass);

        return ResponsiveContent(
          maxWidth: wide ? AppBreakpoints.contentMaxLarge : null,
          child: _buildScrollable(context, singleColumn: !wide),
        );
      },
    );
  }

  Widget _buildScrollable(BuildContext context, {required bool singleColumn}) {
    final baseCode = currencyProvider.baseCurrency?.code ?? 'USD';
    final totalBalance = walletProvider.totalBalanceInBase;
    final currencyBalances = buildDashboardCurrencyBalances(
      walletProvider: walletProvider,
      currencyProvider: currencyProvider,
    );

    final primarySections = <Widget>[
      const DashboardHeader(),
      const SizedBox(height: 8),
      DashboardTotalBalance(
        label: l10n.dashboardTotalBalance(baseCode),
        amount: totalBalance,
        currencyCode: baseCode,
      ),
      const SizedBox(height: 20),
      DashboardCurrencyBalancesRow(
        balances: currencyBalances,
        baseCode: baseCode,
      ),
      const DashboardSectionDivider(),
      DashboardMonthlySummary(
        baseCode: baseCode,
        monthlyIncome: data.monthlyIncome,
        monthlyExpense: data.monthlyExpense,
        debts: data.debts,
        onDebtsTap: () => context.go('/transactions?tab=debt'),
      ),
      const DashboardSectionDivider(),
      DashboardGoalsSection(
        goals: data.goals,
        onAddGoal: onAddGoal,
        onGoalTap: onGoalTap,
      ),
    ];

    final secondarySections = <Widget>[
      const DashboardSectionDivider(),
      DashboardExpenseChart(
        dailyPoints: data.dailyChart,
        weeklyPoints: data.weeklyChart,
        currencyCode: data.baseCurrencyCode,
      ),
      const DashboardSectionDivider(),
      DashboardRecentTransactions(
        transactions: data.transactions,
      ),
    ];

    final body = singleColumn
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [...primarySections, ...secondarySections],
          )
        : TwoColumnLayout(
            primary: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: primarySections,
            ),
            secondary: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: secondarySections,
            ),
          );

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: body),
        ],
      ),
    );
  }
}
