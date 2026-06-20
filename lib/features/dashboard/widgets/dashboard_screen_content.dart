import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/app_breakpoints.dart';
import '../../../core/responsive/responsive_content.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/layouts/two_column_layout.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/wallet_provider.dart';
import '../../../services/dashboard_service.dart';
import '../data/dashboard_currency_balances.dart';
import 'dashboard_balance_hero_card.dart';
import 'dashboard_currency_carousel.dart';
import 'dashboard_expense_chart.dart';
import 'dashboard_goals_section.dart';
import 'dashboard_header.dart';
import 'dashboard_monthly_summary.dart';
import 'dashboard_quick_actions.dart';
import 'dashboard_recent_transactions.dart';
import 'dashboard_report_banner.dart';
import 'dashboard_section_divider.dart';

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

    // Primary column: balance hero + quick actions + monthly pulse +
    //                 recent transactions (high-frequency, moved above goals)
    final primarySections = <Widget>[
      const DashboardHeader(),
      const SizedBox(height: 12),
      DashboardBalanceHeroCard(
        label: l10n.dashboardTotalBalance(baseCode),
        amount: totalBalance,
        currencyCode: baseCode,
        monthlyIncome: data.monthlyIncome,
        monthlyExpense: data.monthlyExpense,
      ),
      const SizedBox(height: 20),
      const DashboardQuickActions(),
      const SizedBox(height: 4),
      DashboardCurrencyBalancesRow(
        balances: currencyBalances,
        baseCode: baseCode,
      ),
      const DashboardSectionDivider(),
      const DashboardReportBanner(),
      DashboardMonthlySummary(
        baseCode: baseCode,
        monthlyIncome: data.monthlyIncome,
        monthlyExpense: data.monthlyExpense,
        debts: data.debts,
        incomeChangePct: data.incomeChangePct,
        expenseChangePct: data.expenseChangePct,
        onDebtsTap: () => context.go('/transactions?tab=debt'),
      ),
      const DashboardSectionDivider(),
      // Recent transactions moved above goals — high-frequency action
      DashboardRecentTransactions(
        transactions: data.transactions,
      ),
    ];

    // Secondary column: goals (medium-frequency) + expense chart (exploration)
    final secondarySections = <Widget>[
      const DashboardSectionDivider(),
      DashboardGoalsSection(
        goals: data.goals,
        onAddGoal: onAddGoal,
        onGoalTap: onGoalTap,
      ),
      const DashboardSectionDivider(),
      DashboardExpenseChart(
        dailyPoints: data.dailyChart,
        weeklyPoints: data.weeklyChart,
        currencyCode: data.baseCurrencyCode,
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
