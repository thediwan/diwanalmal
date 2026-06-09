import '../core/helpers/currency_formatter.dart';
import '../models/currency.dart';
import '../models/treasury.dart';
import '../models/wallet.dart';
import 'lazarus_database_service.dart';

/// Computes treasury balances from opening balance + transactions + transfers.
class WalletBalanceService {
  WalletBalanceService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  /// Legacy: first account balance for a flattened wallet row.
  Future<double> getBalanceInWalletCurrency(Wallet wallet) async {
    return _lazarus.database.financeDao.computeWalletBalance(wallet.id);
  }

  /// Net total in base currency across all treasury accounts.
  Future<double> getTotalBalanceInBase() async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return 0;

    final treasuries = await _lazarus.database.financeDao.getActiveTreasuries(userId);
    var total = 0.0;

    for (final treasury in treasuries) {
      for (final account in treasury.accounts) {
        final balance = await _lazarus.database.financeDao.computeAccountBalance(
          walletId: treasury.wallet.id,
          currencyId: account.account.currencyId,
        );
        total += CurrencyFormatter.toBaseAmount(
          balance,
          account.currencyRateToBase,
        );
      }
    }
    return total;
  }

  /// Sum of positive treasury totals in base currency.
  Future<double> getTotalPositiveBalanceInBase(List<Treasury> treasuries) async {
    var total = 0.0;
    for (final treasury in treasuries) {
      if (treasury.totalInBase > 0) total += treasury.totalInBase;
    }
    return total;
  }

  /// Net income minus expense in base currency for the current calendar month.
  Future<double> getMonthlyNetChangeInBase() async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return 0;

    final now = DateTime.now();
    final dao = _lazarus.database.financeDao;
    final income = await dao.sumTransactionsBaseAmount(
      userId: userId,
      type: 'income',
      year: now.year,
      month: now.month,
    );
    final expense = await dao.sumTransactionsBaseAmount(
      userId: userId,
      type: 'expense',
      year: now.year,
      month: now.month,
    );
    return income - expense;
  }

  Future<String> formatWalletBalance(Wallet wallet, Currency? currency) async {
    final balance = await getBalanceInWalletCurrency(wallet);
    return formatWalletBalanceSync(wallet, balance);
  }

  String formatWalletBalanceSync(Wallet wallet, double balance) {
    return CurrencyFormatter.formatWithCode(balance, wallet.currencyCode);
  }
}
