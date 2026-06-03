import '../core/helpers/currency_formatter.dart';
import '../models/currency.dart';
import '../models/wallet.dart';
import 'currency_service.dart';
import 'lazarus_database_service.dart';

/// Computes wallet balances from opening balance + transactions + transfers.
class WalletBalanceService {
  WalletBalanceService(this._lazarus, this._currencyService);

  final LazarusDatabaseService _lazarus;
  final CurrencyService _currencyService;

  /// Current balance in the wallet's currency (from Lazarus operations).
  Future<double> getBalanceInWalletCurrency(Wallet wallet) async {
    return _lazarus.database.financeDao.computeWalletBalance(wallet.id);
  }

  /// Balance converted to base currency.
  Future<double> getBalanceInBaseCurrency(Wallet wallet) async {
    final balance = await getBalanceInWalletCurrency(wallet);
    final currency = await _currencyService.getByCode(wallet.currencyCode);
    if (currency == null) return balance;

    return CurrencyFormatter.toBaseAmount(balance, currency.rateToBase);
  }

  /// Total balance in base currency (base-currency wallets only — matches mockup total).
  Future<double> getTotalBalanceInBase() async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return 0;

    final wallets = await _lazarus.database.financeDao.getActiveWallets(userId);
    var total = 0.0;
    for (final item in wallets) {
      final currency = await _currencyService.getByCode(item.currencyCode);
      if (currency == null || !currency.isBase) continue;

      final balance =
          await _lazarus.database.financeDao.computeWalletBalance(item.wallet.id);
      total += CurrencyFormatter.toBaseAmount(
        balance,
        item.currencyRateToBase,
      );
    }
    return total;
  }

  /// Formatted balance string for wallet cards.
  Future<String> formatWalletBalance(Wallet wallet, Currency? currency) async {
    final balance = await getBalanceInWalletCurrency(wallet);
    return formatWalletBalanceSync(wallet, balance);
  }

  /// Synchronous formatter when balance is already loaded.
  String formatWalletBalanceSync(Wallet wallet, double balance) {
    return CurrencyFormatter.formatWithCode(balance, wallet.currencyCode);
  }
}
