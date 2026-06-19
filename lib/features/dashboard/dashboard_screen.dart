import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/extensions/context_l10n.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/dashboard_refresh_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/dashboard_service.dart';
import '../../providers/settings_provider.dart';
import '../../services/lazarus_database_service.dart';
import 'widgets/dashboard_screen_view.dart';

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

      final settings = context.read<SettingsProvider>();
      final snapshot = await DashboardService(LazarusDatabaseService.instance)
          .loadSnapshot(
        l10n,
        localeName: locale,
        deleteWindowHours: settings.transactionDeleteWindowHours,
        editWindowDays: settings.transactionEditWindowDays,
      );

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

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
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
        ),
      );
    }

    return DashboardScreenView(
      l10n: l10n,
      data: _snapshot ?? DashboardSnapshot.empty(),
      onRefresh: _loadDashboard,
      onReloadAfterNavigation: () => _loadDashboard(silent: true),
    );
  }
}
