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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
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
