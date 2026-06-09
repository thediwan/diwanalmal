import 'package:drift/drift.dart';

import '../database/lazarus_database.dart';
import '../models/wallet.dart';
import 'lazarus_database_service.dart';

/// Legacy wallet helpers for dashboard flattening and edit form.
class WalletService {
  WalletService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  LazarusDatabase get _db => _lazarus.database;

  /// One legacy [Wallet] row per currency account (dashboard compatibility).
  Future<List<Wallet>> getAllFlattened() async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return [];

    final rows = await _db.financeDao.getActiveTreasuries(userId);
    final wallets = <Wallet>[];

    for (final row in rows) {
      for (final account in row.accounts) {
        final balance = await _db.financeDao.computeAccountBalance(
          walletId: row.wallet.id,
          currencyId: account.account.currencyId,
        );
        wallets.add(
          Wallet(
            id: row.wallet.id,
            name: row.wallet.name,
            currencyCode: account.currencyCode,
            initialBalance: balance,
            icon: row.wallet.icon ?? '💰',
            iconStyle: row.wallet.iconStyle,
            createdAt: row.wallet.createdAt,
          ),
        );
      }
    }

    wallets.sort((a, b) => a.name.compareTo(b.name));
    return wallets;
  }

  Future<Wallet?> getById(String id) async {
    final flattened = await getAllFlattened();
    return flattened.where((w) => w.id == id).firstOrNull;
  }

  Future<Wallet> update(Wallet wallet) async {
    final now = DateTime.now();
    await (_db.update(_db.wallets)..where((w) => w.id.equals(wallet.id))).write(
      WalletsCompanion(
        name: Value(wallet.name),
        icon: Value(wallet.icon),
        iconStyle: Value(wallet.iconStyle),
        updatedAt: Value(now),
      ),
    );
    return wallet;
  }
}
