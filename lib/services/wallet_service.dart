import 'package:drift/drift.dart';

import '../core/helpers/uuid_helper.dart';
import '../database/lazarus_database.dart';
import '../models/wallet.dart';
import 'lazarus_database_service.dart';

/// Wallet CRUD backed by Lazarus SQLite.
class WalletService {
  WalletService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  LazarusDatabase get _db => _lazarus.database;

  Future<List<Wallet>> getAll() async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return [];

    final rows = await _db.financeDao.getActiveWallets(userId);
    return rows
        .map(
          (r) => LazarusDatabaseService.toAppWallet(
            row: r.wallet,
            currencyCode: r.currencyCode,
          ),
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<Wallet?> getById(String id) async {
    final row = await (_db.select(_db.wallets)
          ..where((w) => w.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;

    final currency = await (_db.select(_db.currencies)
          ..where((c) => c.id.equals(row.currencyId)))
        .getSingleOrNull();
    if (currency == null) return null;

    return LazarusDatabaseService.toAppWallet(
      row: row,
      currencyCode: currency.code,
    );
  }

  Future<Wallet> create({
    required String name,
    required String currencyCode,
    required double initialBalance,
    required String icon,
  }) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for wallet creation');
    }

    final currency = await (_db.select(_db.currencies)
          ..where((c) => c.userId.equals(userId))
          ..where((c) => c.code.equals(currencyCode.toUpperCase())))
        .getSingleOrNull();

    if (currency == null) {
      throw Exception('العملة غير موجودة');
    }

    final now = DateTime.now();
    final id = UuidHelper.generate();

    await _db.into(_db.wallets).insert(
          WalletsCompanion.insert(
            id: id,
            userId: userId,
            currencyId: currency.id,
            name: name,
            icon: Value(icon),
            openingBalance: Value(initialBalance),
            createdAt: now,
            updatedAt: now,
          ),
        );

    return Wallet(
      id: id,
      name: name,
      currencyCode: currency.code,
      initialBalance: initialBalance,
      icon: icon,
      createdAt: now,
    );
  }

  Future<Wallet> update(Wallet wallet) async {
    final now = DateTime.now();
    await (_db.update(_db.wallets)..where((w) => w.id.equals(wallet.id))).write(
      WalletsCompanion(
        name: Value(wallet.name),
        icon: Value(wallet.icon),
        openingBalance: Value(wallet.initialBalance),
        updatedAt: Value(now),
      ),
    );
    return wallet;
  }

  Future<void> delete(String id) async {
    await (_db.update(_db.wallets)..where((w) => w.id.equals(id))).write(
      WalletsCompanion(deletedAt: Value(DateTime.now())),
    );
  }
}
