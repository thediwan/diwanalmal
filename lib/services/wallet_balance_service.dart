import '../core/helpers/currency_formatter.dart';
import '../models/currency.dart';
import '../models/wallet.dart';
import 'currency_service.dart';
import 'hive_service.dart';

/// Calculates wallet balances from initial balance and future transactions.
///
/// Phase 1: balance = initialBalance only.
/// Later phases will add income, expenses, and transfers.
class WalletBalanceService {
  WalletBalanceService(this._hiveService, this._currencyService);

  final HiveService _hiveService;
  final CurrencyService _currencyService;

  /// Current balance in the wallet's own currency.
  double getBalanceInWalletCurrency(Wallet wallet) {
    // Phase 1: no transactions yet — balance equals initial balance.
    // Phase 2+: add income - expenses + transfers in - transfers out.
    return wallet.initialBalance;
  }

  /// Current balance converted to base currency.
  double getBalanceInBaseCurrency(Wallet wallet) {
    final balance = getBalanceInWalletCurrency(wallet);
    final currency = _currencyService.getByCode(wallet.currencyCode);
    if (currency == null) return balance;

    return CurrencyFormatter.toBaseAmount(balance, currency.rateToBase);
  }

  /// Total balance across all wallets in base currency.
  double getTotalBalanceInBase() {
    final wallets = _hiveService.walletsBox.values;
    return wallets.fold<double>(
      0,
      (sum, wallet) => sum + getBalanceInBaseCurrency(wallet),
    );
  }

  /// Formatted balance string for display on wallet cards.
  String formatWalletBalance(Wallet wallet, Currency? currency) {
    final balance = getBalanceInWalletCurrency(wallet);
    final code = wallet.currencyCode;
    return CurrencyFormatter.formatWithCode(balance, code);
  }
}
