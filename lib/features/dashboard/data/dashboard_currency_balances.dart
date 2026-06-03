import '../../../core/helpers/currency_formatter.dart';
import '../../../models/currency.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/wallet_provider.dart';

/// Per-currency wallet totals shown on the dashboard.
class DashboardCurrencyBalance {
  const DashboardCurrencyBalance({
    required this.currency,
    required this.balanceInCurrency,
    required this.balanceInBase,
  });

  final Currency currency;
  final double balanceInCurrency;
  final double balanceInBase;
}

/// Aggregates wallet balances grouped by currency code.
List<DashboardCurrencyBalance> buildDashboardCurrencyBalances({
  required WalletProvider walletProvider,
  required CurrencyProvider currencyProvider,
}) {
  final totalsByCode = <String, double>{};

  for (final wallet in walletProvider.wallets) {
    final balance = walletProvider.balanceFor(wallet);
    totalsByCode[wallet.currencyCode] =
        (totalsByCode[wallet.currencyCode] ?? 0) + balance;
  }

  if (totalsByCode.isEmpty) return [];

  final entries = <DashboardCurrencyBalance>[];

  for (final entry in totalsByCode.entries) {
    final currency = currencyProvider.currencies
        .where((c) => c.code == entry.key)
        .firstOrNull;
    if (currency == null) continue;

    final balanceInBase = CurrencyFormatter.toBaseAmount(
      entry.value,
      currency.rateToBase,
    );

    entries.add(
      DashboardCurrencyBalance(
        currency: currency,
        balanceInCurrency: entry.value,
        balanceInBase: balanceInBase,
      ),
    );
  }

  const displayOrder = ['TRY', 'SYP', 'EUR', 'GBP', 'SAR'];

  entries.sort((a, b) {
    final ai = displayOrder.indexOf(a.currency.code);
    final bi = displayOrder.indexOf(b.currency.code);
    if (ai != -1 || bi != -1) {
      return (ai == -1 ? 999 : ai).compareTo(bi == -1 ? 999 : bi);
    }
    return a.currency.code.compareTo(b.currency.code);
  });

  return entries.where((e) => !e.currency.isBase).toList();
}
