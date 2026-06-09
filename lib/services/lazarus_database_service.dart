import 'package:drift/drift.dart';

import '../database/lazarus_database.dart';
import '../database/seed/database_seed_service.dart';
import '../models/currency.dart' as app;
import '../models/wallet.dart' as app;
import 'hive_service.dart';

/// Bootstraps Lazarus SQLite, migrates legacy Hive data, and seeds demo rows.
class LazarusDatabaseService {
  LazarusDatabaseService._(this.database);

  final LazarusDatabase database;

  static LazarusDatabaseService? _instance;

  static LazarusDatabaseService get instance {
    final inst = _instance;
    if (inst == null) {
      throw StateError('LazarusDatabaseService not initialized');
    }
    return inst;
  }

  /// Opens DB, migrates Hive once, seeds when empty.
  static Future<LazarusDatabaseService> initialize(HiveService hiveService) async {
    if (_instance != null) return _instance!;

    final db = await LazarusDatabase.open();
    final service = LazarusDatabaseService._(db);

    await service._migrateHiveIfNeeded(hiveService);
    final seed = DatabaseSeedService(db);
    await seed.seedIfEmpty();
    await seed.ensureDashboardMockupData();

    _instance = service;
    return service;
  }

  Future<String?> getActiveUserId() => database.getActiveUserId();

  Future<void> _migrateHiveIfNeeded(HiveService hiveService) async {
    if (await database.getActiveUserId() != null) return;

    final settings = hiveService.getSettings();
    final hiveCurrencies = hiveService.currenciesBox.values.toList();
    final hiveWallets = hiveService.walletsBox.values.toList();

    if (!settings.hasAccount && hiveCurrencies.isEmpty) return;

    final now = DateTime.now();
    final userId = 'hive-migrated-user';

    await database.transaction(() async {
      await database.into(database.appUsers).insert(
            AppUsersCompanion.insert(
              id: userId,
              fullName: settings.username.isNotEmpty
                  ? settings.username
                  : 'مستخدم محلي',
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );

      String? baseId;
      for (final c in hiveCurrencies) {
        await database.into(database.currencies).insert(
              CurrenciesCompanion.insert(
                id: c.id,
                userId: userId,
                code: c.code,
                name: c.name,
                symbol: c.symbol,
                rateToBase: c.rateToBase,
                isBase: Value(c.isBase),
                createdAt: c.createdAt,
                updatedAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
        if (c.isBase) baseId = c.id;
      }

      if (baseId != null) {
        await database.into(database.userSettings).insert(
              UserSettingsCompanion.insert(
                id: 'settings-$userId',
                userId: userId,
                baseCurrencyId: baseId,
                createdAt: now,
                updatedAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }

      for (final w in hiveWallets) {
        final currency = hiveCurrencies
            .where((c) => c.code == w.currencyCode)
            .firstOrNull;
        if (currency == null) continue;

        await database.into(database.wallets).insert(
              WalletsCompanion.insert(
                id: w.id,
                userId: userId,
                name: w.name,
                icon: Value(w.icon),
                createdAt: w.createdAt,
                updatedAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );

        await database.into(database.walletCurrencyAccounts).insert(
              WalletCurrencyAccountsCompanion.insert(
                id: '${w.id}-acc',
                walletId: w.id,
                currencyId: currency.id,
                openingBalance: Value(w.initialBalance),
                createdAt: w.createdAt,
                updatedAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }

  /// Maps Drift currency row to app [Currency] model.
  static app.Currency toAppCurrency(DbCurrency row) {
    return app.Currency(
      id: row.id,
      code: row.code,
      name: row.name,
      symbol: row.symbol,
      rateToBase: row.rateToBase,
      isBase: row.isBase,
      createdAt: row.createdAt,
    );
  }

  /// Maps treasury + currency code to legacy [Wallet] model.
  static app.Wallet toAppWallet({
    required DbWallet row,
    required String currencyCode,
    double balance = 0,
  }) {
    return app.Wallet(
      id: row.id,
      name: row.name,
      currencyCode: currencyCode,
      initialBalance: balance,
      icon: row.icon ?? '💰',
      createdAt: row.createdAt,
      notes: row.notes,
    );
  }
}
