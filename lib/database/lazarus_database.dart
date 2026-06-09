import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'daos/finance_dao.dart';
import 'tables/schema_tables.dart';

part 'lazarus_database.g.dart';

/// Offline-first SQLite database (Lazarus local store).
@DriftDatabase(
  tables: [
    AppUsers,
    AuthLocal,
    SecuritySettings,
    Currencies,
    UserSettings,
    Wallets,
    WalletCurrencyAccounts,
    Categories,
    Transactions,
    Transfers,
    Debts,
    DebtPayments,
    Budgets,
    Goals,
    Attachments,
  ],
  daos: [FinanceDao],
)
class LazarusDatabase extends _$LazarusDatabase {
  LazarusDatabase(super.executor);

  /// Opens `lazarus.db` in app documents directory.
  static Future<LazarusDatabase> open() async {
    if (Platform.isAndroid) {
      final cacheDir = await getTemporaryDirectory();
      sqlite.sqlite3.tempDirectory = cacheDir.path;
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'lazarus.db'));
    return LazarusDatabase(NativeDatabase.createInBackground(file));
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(walletCurrencyAccounts);

            await customStatement('''
              INSERT INTO wallet_currency_accounts (
                id, wallet_id, currency_id, opening_balance, created_at, updated_at
              )
              SELECT
                id || '-acc',
                id,
                currency_id,
                opening_balance,
                created_at,
                updated_at
              FROM wallets
            ''');

            await customStatement('''
              CREATE TABLE wallets_new (
                id TEXT NOT NULL PRIMARY KEY,
                user_id TEXT NOT NULL REFERENCES app_users(id),
                name TEXT NOT NULL,
                icon TEXT,
                subtitle TEXT,
                icon_style TEXT,
                notes TEXT,
                is_archived INTEGER NOT NULL DEFAULT 0 CHECK (is_archived IN (0, 1)),
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL,
                deleted_at INTEGER
              )
            ''');

            await customStatement('''
              INSERT INTO wallets_new (
                id, user_id, name, icon, subtitle, icon_style, notes,
                is_archived, created_at, updated_at, deleted_at
              )
              SELECT
                id, user_id, name, icon, NULL, NULL, notes,
                is_archived, created_at, updated_at, deleted_at
              FROM wallets
            ''');

            await customStatement('DROP TABLE wallets');
            await customStatement(
              'ALTER TABLE wallets_new RENAME TO wallets',
            );
          }
        },
      );

  /// First active user id (single-user phase).
  Future<String?> getActiveUserId() async {
    final row = await (select(appUsers)
          ..where((u) => u.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row?.id;
  }
}
