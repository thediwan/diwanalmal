import 'package:drift/drift.dart';

import '../core/constants/seed_constants.dart';
import '../database/lazarus_database.dart';
import '../database/seed/category_seed_service.dart';
import '../database/seed/database_seed_service.dart';
import '../database/seed/system_category_service.dart';
import '../models/currency.dart' as app;
import '../models/wallet.dart' as app;
import '../core/helpers/currency_uniqueness.dart';
import 'hive_service.dart';

/// Bootstraps Lazarus SQLite and migrates legacy Hive data.
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

  /// Opens DB and migrates Hive once when needed.
  static Future<LazarusDatabaseService> initialize(HiveService hiveService) async {
    if (_instance != null) return _instance!;

    final db = await LazarusDatabase.open();
    final service = LazarusDatabaseService._(db);

    await service._migrateHiveIfNeeded(hiveService);
    await service._ensureSystemCategoriesForActiveUser();
    if (SeedConstants.enabled) {
      await service._ensureDemoCategoriesForActiveUser();
    }

    _instance = service;
    return service;
  }

  /// Closes the SQLite connection (required before restore).
  Future<void> close() async {
    await database.close();
    _instance = null;
  }

  /// Reopens after restore.
  static Future<LazarusDatabaseService> reinitialize(
    HiveService hiveService,
  ) async {
    _instance = null;
    return initialize(hiveService);
  }

  /// Seeds demo financial data after the user picks a base currency.
  Future<void> seedDemoDataAfterBaseCurrency({
    required String userId,
    required String baseCurrencyId,
    required String baseCode,
  }) async {
    if (!SeedConstants.enabled) return;

    await DatabaseSeedService(database).seedDemoDataAfterBaseCurrencySelection(
      userId: userId,
      baseCurrencyId: baseCurrencyId,
      baseCode: baseCode,
    );
    await CategorySeedService(database).ensureDefaultCategories(userId);
  }

  /// Ensures protected system categories for the active user.
  Future<void> ensureSystemCategories(String userId) {
    return SystemCategoryService(database).ensureForUser(userId);
  }

  Future<String?> getActiveUserId() => database.getActiveUserId();

  Future<void> _ensureSystemCategoriesForActiveUser() async {
    final userId = await getActiveUserId();
    if (userId == null) return;
    await ensureSystemCategories(userId);
  }

  Future<void> _ensureDemoCategoriesForActiveUser() async {
    final userId = await getActiveUserId();
    if (userId == null) return;
    await CategorySeedService(database).ensureDefaultCategories(userId);
  }

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

      final seenCodes = <String>{};
      String? baseId;
      var baseAssigned = false;
      for (final c in hiveCurrencies) {
        final code = normalizeCurrencyCode(c.code);
        if (!seenCodes.add(code)) continue;

        final isBase = c.isBase && !baseAssigned;
        if (isBase) {
          baseId = c.id;
          baseAssigned = true;
        }

        await database.into(database.currencies).insert(
              CurrenciesCompanion.insert(
                id: c.id,
                userId: userId,
                code: code,
                name: c.name,
                symbol: c.symbol,
                rateToBase: c.rateToBase,
                isBase: Value(isBase),
                createdAt: c.createdAt,
                updatedAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
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

    await ensureSystemCategories(userId);
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
