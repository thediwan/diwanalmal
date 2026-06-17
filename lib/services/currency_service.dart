import 'package:drift/drift.dart';

import '../core/helpers/currency_uniqueness.dart';
import '../core/helpers/uuid_helper.dart';
import '../database/lazarus_database.dart';
import '../models/currency.dart';
import 'currency_deduplication_service.dart';
import 'hive_service.dart';
import 'lazarus_database_service.dart';

/// Currency CRUD backed by Lazarus SQLite.
class CurrencyService {
  CurrencyService(this._lazarus, this._hiveService, this._deduplication);

  final LazarusDatabaseService _lazarus;
  final HiveService _hiveService;
  final CurrencyDeduplicationService _deduplication;

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

    return uniqueCurrenciesByCode(
      rows.map(LazarusDatabaseService.toAppCurrency).toList(),
    );
  }

  Future<Currency?> getById(String id) async {
    final row = await (_db.select(_db.currencies)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : LazarusDatabaseService.toAppCurrency(row);
  }

  Future<Currency?> getByCode(String code) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return null;

    final normalized = normalizeCurrencyCode(code);
    final row = await (_db.select(_db.currencies)
          ..where((c) => c.userId.equals(userId))
          ..where((c) => c.deletedAt.isNull())
          ..where((c) => c.code.equals(normalized)))
        .getSingleOrNull();

    return row == null ? null : LazarusDatabaseService.toAppCurrency(row);
  }

  Future<Currency?> getBaseCurrency() async {
    final all = await getAll();
    return all.where((c) => c.isBase).firstOrNull;
  }

  /// Creates the base currency during first-time setup.
  ///
  /// Throws [StateError] with message `base_currency_already_exists` when a base
  /// currency is already registered for the active user.
  Future<Currency> createBaseCurrency({
    required String code,
    required String name,
    required String symbol,
  }) async {
    final normalized = normalizeCurrencyCode(code);
    final userId = await _ensureUserId();
    final now = DateTime.now();
    final id = UuidHelper.generate();

    await _db.transaction(() async {
      final existingBase = await (_db.select(_db.currencies)
            ..where((c) => c.userId.equals(userId))
            ..where((c) => c.deletedAt.isNull())
            ..where((c) => c.isBase.equals(true))
            ..limit(1))
          .getSingleOrNull();

      if (existingBase != null) {
        throw StateError('base_currency_already_exists');
      }

      final duplicateCode = await (_db.select(_db.currencies)
            ..where((c) => c.userId.equals(userId))
            ..where((c) => c.deletedAt.isNull())
            ..where((c) => c.code.equals(normalized))
            ..limit(1))
          .getSingleOrNull();

      if (duplicateCode != null) {
        throw Exception('currency_already_exists');
      }

      await _db.into(_db.currencies).insert(
            CurrenciesCompanion.insert(
              id: id,
              userId: userId,
              code: normalized,
              name: name,
              symbol: symbol,
              rateToBase: 1,
              isBase: const Value(true),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await _upsertUserSettings(userId: userId, baseCurrencyId: id, now: now);
    });

    await _lazarus.seedDemoDataAfterBaseCurrency(
      userId: userId,
      baseCurrencyId: id,
      baseCode: normalized,
    );

    await _lazarus.ensureSystemCategories(userId);

    final settings = _hiveService.getSettings().copyWith(
          isSetupComplete: true,
          baseCurrencyCode: normalized,
        );
    await _hiveService.saveSettings(settings);

    return Currency(
      id: id,
      code: normalized,
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
    final normalized = normalizeCurrencyCode(code);
    if (normalized.isEmpty) {
      throw Exception('currency_code_invalid');
    }

    final existing = await getByCode(normalized);
    if (existing != null) {
      throw Exception('currency_already_exists');
    }

    final userId = await _ensureUserId();
    final now = DateTime.now();
    final id = UuidHelper.generate();

    try {
      await _db.into(_db.currencies).insert(
            CurrenciesCompanion.insert(
              id: id,
              userId: userId,
              code: normalized,
              name: name,
              symbol: symbol,
              rateToBase: rateToBase,
              isBase: const Value(false),
              createdAt: now,
              updatedAt: now,
            ),
          );
    } on Object {
      throw Exception('currency_already_exists');
    }

    return Currency(
      id: id,
      code: normalized,
      name: name,
      symbol: symbol,
      rateToBase: rateToBase,
      isBase: false,
      createdAt: now,
    );
  }

  Future<Currency> updateCurrency(Currency currency) async {
    final normalized = normalizeCurrencyCode(currency.code);
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for currency update');
    }

    final duplicate = await (_db.select(_db.currencies)
          ..where((c) => c.userId.equals(userId))
          ..where((c) => c.deletedAt.isNull())
          ..where((c) => c.code.equals(normalized))
          ..where((c) => c.id.equals(currency.id).not()))
        .getSingleOrNull();

    if (duplicate != null) {
      throw Exception('العملة موجودة مسبقاً');
    }

    final now = DateTime.now();
    await (_db.update(_db.currencies)..where((c) => c.id.equals(currency.id)))
        .write(
      CurrenciesCompanion(
        code: Value(normalized),
        name: Value(currency.name),
        symbol: Value(currency.symbol),
        rateToBase: Value(currency.rateToBase),
        updatedAt: Value(now),
      ),
    );
    return currency.copyWith(code: normalized);
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

  Future<void> ensureUniqueCurrencies() async {
    await _deduplication.deduplicateAllUsers();
    await _deduplication.enforceSingleBaseCurrencyPerUser();
    await _db.ensureCurrencyUniqueIndex();
    await _db.ensureBaseCurrencyUniqueIndex();
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

    await _lazarus.ensureSystemCategories(userId);

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
