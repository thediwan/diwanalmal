import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/dashboard_refresh_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/dashboard_service.dart';
import '../../services/lazarus_database_service.dart';
import 'data/dashboard_currency_balances.dart';
import 'widgets/dashboard_currency_carousel.dart';
import 'widgets/dashboard_expense_chart.dart';
import 'widgets/dashboard_goals_section.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_monthly_summary.dart';
import 'widgets/dashboard_recent_transactions.dart';
import 'widgets/dashboard_section_divider.dart';
import 'widgets/dashboard_total_balance.dart';

/// Main dashboard — layout and colors match client mockup.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardSnapshot? _snapshot;
  String? _error;
  bool _loading = true;
  DashboardRefreshProvider? _dashboardRefresh;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _dashboardRefresh = context.read<DashboardRefreshProvider>();
      _dashboardRefresh!.addListener(_onRefreshRequested);
      _loadDashboard();
    });
  }

  @override
  void dispose() {
    _dashboardRefresh?.removeListener(_onRefreshRequested);
    super.dispose();
  }

  void _onRefreshRequested() {
    _loadDashboard(silent: true);
  }

  Future<void> _loadDashboard({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final walletProvider = context.read<WalletProvider>();
      final currencyProvider = context.read<CurrencyProvider>();
      final l10n = context.l10n;
      final locale = Localizations.localeOf(context).languageCode;

      await walletProvider.loadWallets();
      await currencyProvider.loadCurrencies();

      final snapshot = await DashboardService(LazarusDatabaseService.instance)
          .loadSnapshot(l10n, localeName: locale);

      if (!mounted) return;
      setState(() {
        _snapshot = snapshot;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/transactions/add');
          if (mounted) await _loadDashboard(silent: true);
        },
        elevation: 6,
        backgroundColor: AppColors.dashboardPrimary,
        foregroundColor: context.appColors.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.expense),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadDashboard,
                child: Text(l10n.dashboardRetry),
              ),
            ],
          ),
        ),
      );
    }

    final data = _snapshot ?? DashboardSnapshot.empty();

    return Consumer2<WalletProvider, CurrencyProvider>(
      builder: (context, walletProvider, currencyProvider, _) {
        final baseCode = currencyProvider.baseCurrency?.code ?? 'USD';
        final totalBalance = walletProvider.totalBalanceInBase;
        final currencyBalances = buildDashboardCurrencyBalances(
          walletProvider: walletProvider,
          currencyProvider: currencyProvider,
        );

        return RefreshIndicator(
          onRefresh: _loadDashboard,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const DashboardHeader(),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DashboardTotalBalance(
                        label: l10n.dashboardTotalBalance(baseCode),
                        amount: totalBalance,
                        currencyCode: baseCode,
                      ),
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
                    ),
                    const DashboardSectionDivider(),
                    DashboardGoalsSection(
                      goals: data.goals,
                      onAddGoal: () async {
                        await context.push('/goals/add');
                        if (mounted) await _loadDashboard();
                      },
                      onGoalTap: (goalId) async {
                        await context.push('/goals/$goalId');
                        if (mounted) await _loadDashboard();
                      },
                    ),
                    const DashboardSectionDivider(),
                    DashboardExpenseChart(
                      dailyPoints: data.dailyChart,
                      weeklyPoints: data.weeklyChart,
                    ),
                    const DashboardSectionDivider(),
                    DashboardRecentTransactions(
                      transactions: data.transactions,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
