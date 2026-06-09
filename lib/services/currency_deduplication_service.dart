import 'package:drift/drift.dart';

import '../core/helpers/currency_uniqueness.dart';
import '../database/lazarus_database.dart';
import 'lazarus_database_service.dart';

/// Merges duplicate currency rows and repoints dependent records.
class CurrencyDeduplicationService {
  CurrencyDeduplicationService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  LazarusDatabase get _db => _lazarus.database;

  /// Normalizes codes and merges duplicate active currencies per user.
  Future<void> deduplicateAllUsers() async {
    final users = await (_db.select(_db.appUsers)
          ..where((u) => u.deletedAt.isNull()))
        .get();

    for (final user in users) {
      await deduplicateForUser(user.id);
      await enforceSingleBaseCurrencyForUser(user.id);
    }
  }

  /// Ensures at most one active base currency per user.
  Future<void> enforceSingleBaseCurrencyPerUser() async {
    final users = await (_db.select(_db.appUsers)
          ..where((u) => u.deletedAt.isNull()))
        .get();

    for (final user in users) {
      await enforceSingleBaseCurrencyForUser(user.id);
    }
  }

  Future<void> enforceSingleBaseCurrencyForUser(String userId) async {
    final baseRows = await (_db.select(_db.currencies)
          ..where((c) => c.userId.equals(userId))
          ..where((c) => c.deletedAt.isNull())
          ..where((c) => c.isBase.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
        .get();

    if (baseRows.length <= 1) return;

    final settings = await (_db.select(_db.userSettings)
          ..where((s) => s.userId.equals(userId)))
        .getSingleOrNull();

    final preferredId = settings?.baseCurrencyId;
    final keeper = preferredId != null &&
            baseRows.any((row) => row.id == preferredId)
        ? baseRows.firstWhere((row) => row.id == preferredId)
        : baseRows.first;

    final now = DateTime.now();
    for (final row in baseRows) {
      if (row.id == keeper.id) continue;
      await (_db.update(_db.currencies)..where((c) => c.id.equals(row.id))).write(
        CurrenciesCompanion(
          isBase: const Value(false),
          updatedAt: Value(now),
        ),
      );
    }
  }

  /// Keeps one row per uppercase code for [userId].
  Future<void> deduplicateForUser(String userId) async {
    final rows = await (_db.select(_db.currencies)
          ..where((c) => c.userId.equals(userId))
          ..where((c) => c.deletedAt.isNull())
          ..orderBy([
            (c) => OrderingTerm.desc(c.isBase),
            (c) => OrderingTerm.asc(c.createdAt),
          ]))
        .get();

    if (rows.length <= 1) {
      await _normalizeCodes(userId);
      return;
    }

    final groups = <String, List<DbCurrency>>{};
    for (final row in rows) {
      final key = normalizeCurrencyCode(row.code);
      groups.putIfAbsent(key, () => []).add(row);
    }

    final now = DateTime.now();

    await _db.transaction(() async {
      for (final entry in groups.entries) {
        final normalizedCode = entry.key;
        final group = entry.value;
        if (group.length <= 1) {
          final only = group.first;
          if (only.code != normalizedCode) {
            await (_db.update(_db.currencies)..where((c) => c.id.equals(only.id)))
                .write(
              CurrenciesCompanion(
                code: Value(normalizedCode),
                updatedAt: Value(now),
              ),
            );
          }
          continue;
        }

        final keeper = group.first;
        final duplicates = group.skip(1);

        if (keeper.code != normalizedCode) {
          await (_db.update(_db.currencies)..where((c) => c.id.equals(keeper.id)))
              .write(
            CurrenciesCompanion(
              code: Value(normalizedCode),
              updatedAt: Value(now),
            ),
          );
        }

        for (final duplicate in duplicates) {
          await _repointCurrencyReferences(
            fromCurrencyId: duplicate.id,
            toCurrencyId: keeper.id,
            now: now,
          );

          await (_db.update(_db.currencies)
                ..where((c) => c.id.equals(duplicate.id)))
              .write(
            CurrenciesCompanion(
              deletedAt: Value(now),
              updatedAt: Value(now),
            ),
          );
        }
      }
    });
  }

  Future<void> _normalizeCodes(String userId) async {
    final rows = await (_db.select(_db.currencies)
          ..where((c) => c.userId.equals(userId))
          ..where((c) => c.deletedAt.isNull()))
        .get();

    final now = DateTime.now();
    for (final row in rows) {
      final normalized = normalizeCurrencyCode(row.code);
      if (row.code != normalized) {
        await (_db.update(_db.currencies)..where((c) => c.id.equals(row.id)))
            .write(
          CurrenciesCompanion(
            code: Value(normalized),
            updatedAt: Value(now),
          ),
        );
      }
    }
  }

  Future<void> _repointCurrencyReferences({
    required String fromCurrencyId,
    required String toCurrencyId,
    required DateTime now,
  }) async {
    final duplicateAccounts = await (_db.select(_db.walletCurrencyAccounts)
          ..where((a) => a.currencyId.equals(fromCurrencyId))
          ..where((a) => a.deletedAt.isNull()))
        .get();

    for (final account in duplicateAccounts) {
      final keeperAccount = await (_db.select(_db.walletCurrencyAccounts)
            ..where((a) => a.walletId.equals(account.walletId))
            ..where((a) => a.currencyId.equals(toCurrencyId))
            ..where((a) => a.deletedAt.isNull()))
          .getSingleOrNull();

      if (keeperAccount != null) {
        await (_db.update(_db.walletCurrencyAccounts)
              ..where((a) => a.id.equals(keeperAccount.id)))
            .write(
          WalletCurrencyAccountsCompanion(
            openingBalance: Value(
              keeperAccount.openingBalance + account.openingBalance,
            ),
            updatedAt: Value(now),
          ),
        );

        await (_db.update(_db.walletCurrencyAccounts)
              ..where((a) => a.id.equals(account.id)))
            .write(
          WalletCurrencyAccountsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
          ),
        );
      } else {
        await (_db.update(_db.walletCurrencyAccounts)
              ..where((a) => a.id.equals(account.id)))
            .write(
          WalletCurrencyAccountsCompanion(
            currencyId: Value(toCurrencyId),
            updatedAt: Value(now),
          ),
        );
      }
    }

    await (_db.update(_db.transactions)
          ..where((t) => t.currencyId.equals(fromCurrencyId)))
        .write(
      TransactionsCompanion(
        currencyId: Value(toCurrencyId),
        updatedAt: Value(now),
      ),
    );

    await (_db.update(_db.transfers)
          ..where((t) => t.currencyId.equals(fromCurrencyId)))
        .write(
      TransfersCompanion(
        currencyId: Value(toCurrencyId),
        updatedAt: Value(now),
      ),
    );

    await (_db.update(_db.debts)..where((d) => d.currencyId.equals(fromCurrencyId)))
        .write(
      DebtsCompanion(
        currencyId: Value(toCurrencyId),
        updatedAt: Value(now),
      ),
    );

    await (_db.update(_db.debtPayments)
          ..where((p) => p.currencyId.equals(fromCurrencyId)))
        .write(
      DebtPaymentsCompanion(
        currencyId: Value(toCurrencyId),
      ),
    );

    await (_db.update(_db.budgets)
          ..where((b) => b.currencyId.equals(fromCurrencyId)))
        .write(
      BudgetsCompanion(
        currencyId: Value(toCurrencyId),
        updatedAt: Value(now),
      ),
    );

    await (_db.update(_db.goals)..where((g) => g.currencyId.equals(fromCurrencyId)))
        .write(
      GoalsCompanion(
        currencyId: Value(toCurrencyId),
        updatedAt: Value(now),
      ),
    );
  }
}
