import 'package:drift/drift.dart';

import '../core/helpers/uuid_helper.dart';
import '../database/lazarus_database.dart';
import '../models/currency.dart';
import 'hive_service.dart';
import 'lazarus_database_service.dart';

/// Currency CRUD backed by Lazarus SQLite.
class CurrencyService {
  CurrencyService(this._lazarus, this._hiveService);

  final LazarusDatabaseService _lazarus;
  final HiveService _hiveService;

  LazarusDatabase get _db => _lazarus.database;

  Future<List<Currency>> getAll() async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return [];

    final rows = await (_db.select(_db.currencies)
          ..where((c) => c.userId.equals(userId))
          ..where((c) => c.deletedAt.isNull())
          ..orderBy([
            (c) => OrderingTerm.desc(c.isBase),
            (c) => OrderingTerm.asc(c.code),
          ]))
        .get();

    return rows.map(LazarusDatabaseService.toAppCurrency).toList();
  }

  Future<Currency?> getById(String id) async {
    final row = await (_db.select(_db.currencies)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : LazarusDatabaseService.toAppCurrency(row);
  }

  Future<Currency?> getByCode(String code) async {
    final all = await getAll();
    return all.where((c) => c.code == code).firstOrNull;
  }

  Future<Currency?> getBaseCurrency() async {
    final all = await getAll();
    return all.where((c) => c.isBase).firstOrNull;
  }

  /// Creates the base currency during first-time setup.
  Future<Currency> createBaseCurrency({
    required String code,
    required String name,
    required String symbol,
  }) async {
    final userId = await _ensureUserId();
    final now = DateTime.now();
    final id = UuidHelper.generate();

    await _db.into(_db.currencies).insert(
          CurrenciesCompanion.insert(
            id: id,
            userId: userId,
            code: code.toUpperCase(),
            name: name,
            symbol: symbol,
            rateToBase: 1,
            isBase: const Value(true),
            createdAt: now,
            updatedAt: now,
          ),
        );

    await _upsertUserSettings(userId: userId, baseCurrencyId: id, now: now);

    final settings = _hiveService.getSettings().copyWith(
          isSetupComplete: true,
          baseCurrencyCode: code.toUpperCase(),
        );
    await _hiveService.saveSettings(settings);

    return Currency(
      id: id,
      code: code.toUpperCase(),
      name: name,
      symbol: symbol,
      rateToBase: 1,
      isBase: true,
      createdAt: now,
    );
  }

  Future<Currency> addCurrency({
    required String code,
    required String name,
    required String symbol,
    required double rateToBase,
  }) async {
    final existing = await getByCode(code);
    if (existing != null) {
      throw Exception('العملة موجودة مسبقاً');
    }

    final userId = await _ensureUserId();
    final now = DateTime.now();
    final id = UuidHelper.generate();

    await _db.into(_db.currencies).insert(
          CurrenciesCompanion.insert(
            id: id,
            userId: userId,
            code: code.toUpperCase(),
            name: name,
            symbol: symbol,
            rateToBase: rateToBase,
            createdAt: now,
            updatedAt: now,
          ),
        );

    return Currency(
      id: id,
      code: code.toUpperCase(),
      name: name,
      symbol: symbol,
      rateToBase: rateToBase,
      isBase: false,
      createdAt: now,
    );
  }

  Future<Currency> updateCurrency(Currency currency) async {
    final now = DateTime.now();
    await (_db.update(_db.currencies)..where((c) => c.id.equals(currency.id)))
        .write(
      CurrenciesCompanion(
        name: Value(currency.name),
        symbol: Value(currency.symbol),
        rateToBase: Value(currency.rateToBase),
        updatedAt: Value(now),
      ),
    );
    return currency;
  }

  Future<void> deleteCurrency(String id) async {
    final currency = await getById(id);
    if (currency == null) return;

    if (currency.isBase) {
      throw Exception('لا يمكن حذف العملة الرئيسية');
    }

    final accounts = await (_db.select(_db.walletCurrencyAccounts)
          ..where((a) => a.currencyId.equals(id))
          ..where((a) => a.deletedAt.isNull()))
        .get();

    if (accounts.isNotEmpty) {
      throw Exception('العملة مستخدمة في محفظة');
    }

    await (_db.update(_db.currencies)..where((c) => c.id.equals(id))).write(
      CurrenciesCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Future<String> _ensureUserId() async {
    final existing = await _lazarus.getActiveUserId();
    if (existing != null) return existing;

    final settings = _hiveService.getSettings();
    final now = DateTime.now();
    final userId = UuidHelper.generate();

    await _db.into(_db.appUsers).insert(
          AppUsersCompanion.insert(
            id: userId,
            fullName:
                settings.username.isNotEmpty ? settings.username : 'مستخدم',
            createdAt: now,
            updatedAt: now,
          ),
        );

    return userId;
  }

  Future<void> _upsertUserSettings({
    required String userId,
    required String baseCurrencyId,
    required DateTime now,
  }) async {
    final existing = await (_db.select(_db.userSettings)
          ..where((s) => s.userId.equals(userId)))
        .getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.userSettings).insert(
            UserSettingsCompanion.insert(
              id: UuidHelper.generate(),
              userId: userId,
              baseCurrencyId: baseCurrencyId,
              createdAt: now,
              updatedAt: now,
            ),
          );
    } else {
      await (_db.update(_db.userSettings)
            ..where((s) => s.id.equals(existing.id)))
          .write(
        UserSettingsCompanion(
          baseCurrencyId: Value(baseCurrencyId),
          updatedAt: Value(now),
        ),
      );
    }
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
