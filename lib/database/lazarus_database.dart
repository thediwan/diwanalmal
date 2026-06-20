import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../core/helpers/app_storage_paths.dart';
import 'daos/finance_dao.dart';
import 'tables/schema_tables.dart';
import '../core/helpers/uuid_helper.dart';

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
    Contacts,
    Transactions,
    Transfers,
    Debts,
    TransactionSplits,
    TransactionSplitParticipants,
    DebtPayments,
    Budgets,
    Goals,
    MonthlyReports,
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

    final dir = await AppStoragePaths.ensureDataDirectory();
    final file = File(p.join(dir, 'lazarus.db'));
    final db = LazarusDatabase(NativeDatabase.createInBackground(file));

    // Wait until the background isolate finishes Drift migrations, then re-run
    // idempotent column repairs (covers DBs that reached v9 without wallet_id).
    await db.customSelect('SELECT 1').get();
    await db.ensureLegacySchemaRepairs();

    return db;
  }

  /// Idempotent repairs for columns added after initial installs.
  Future<void> ensureLegacySchemaRepairs() async {
    await _ensureTransferCrossCurrencyColumns();
    await _ensureTransactionDebtColumns();
    await _ensureDebtsWalletColumn();
    await _ensureGoalsWalletColumn();
    await _backfillGoalWallets();
    await _ensureSplitSharingColumns();
    await _ensureContactsPhoneColumn();
  }

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _createCurrencyUniqueIndex();
          await _createBaseCurrencyUniqueIndex();
          await _createContactsUniqueIndex();
          await customStatement('''
            CREATE UNIQUE INDEX IF NOT EXISTS idx_monthly_reports_user_period
            ON monthly_reports (user_id, year, month)
          ''');
        },
        beforeOpen: (details) async {
          await ensureLegacySchemaRepairs();
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

          if (from < 3) {
            await customStatement(
              "UPDATE currencies SET code = UPPER(TRIM(code)) WHERE deleted_at IS NULL",
            );
          }

          if (from < 4) {
            await _dedupeBaseCurrencies();
            await _createBaseCurrencyUniqueIndex();
          }

          if (from < 5) {
            await m.addColumn(goals, goals.icon);
          }

          if (from < 6) {
            await m.addColumn(transfers, transfers.toCurrencyId);
            await m.addColumn(transfers, transfers.toAmount);
            await m.addColumn(transfers, transfers.toExchangeRate);
            await customStatement('''
              UPDATE transfers
              SET to_currency_id = currency_id,
                  to_amount = amount,
                  to_exchange_rate = exchange_rate
              WHERE to_currency_id IS NULL
            ''');
          }

          if (from < 7) {
            await _ensureTransferCrossCurrencyColumns();
          }

          if (from < 8) {
            await _ensureTransactionDebtColumns();
          }

          if (from < 9) {
            await _ensureDebtsWalletColumn();
          }

          if (from < 10) {
            await _ensureDebtsWalletColumn();
            await _ensureTransactionDebtColumns();
          }

          if (from < 11) {
            await _ensureGoalsWalletColumn();
            await _backfillGoalWallets();
          }

          if (from < 12) {
            await m.createTable(contacts);
            await m.createTable(transactionSplits);
            await m.createTable(transactionSplitParticipants);
            await _ensureSplitSharingColumns();
            await _migrateDebtsToContacts();
            await _createContactsUniqueIndex();
          }

          if (from < 13) {
            await _ensureContactsPhoneColumn();
          }

          if (from < 14) {
            await m.createTable(monthlyReports);
            await customStatement('''
              CREATE UNIQUE INDEX IF NOT EXISTS idx_monthly_reports_user_period
              ON monthly_reports (user_id, year, month)
            ''');
          }
        },
      );

  /// Adds [phone] on [contacts] when missing.
  Future<void> _ensureContactsPhoneColumn() async {
    final rows = await customSelect('PRAGMA table_info(contacts)').get();
    if (rows.isEmpty) return;

    final columnNames =
        rows.map((row) => row.read<String>('name')).toSet();
    if (!columnNames.contains('phone')) {
      await customStatement(
        'ALTER TABLE contacts ADD COLUMN phone TEXT',
      );
    }
  }

  /// Adds split-sharing columns and tables when missing (legacy DB repair).
  Future<void> _ensureSplitSharingColumns() async {
    final txRows = await customSelect('PRAGMA table_info(transactions)').get();
    final txColumns =
        txRows.map((row) => row.read<String>('name')).toSet();
    if (!txColumns.contains('parent_transaction_id')) {
      await customStatement(
        'ALTER TABLE transactions ADD COLUMN parent_transaction_id TEXT REFERENCES transactions(id)',
      );
    }

    final debtRows = await customSelect('PRAGMA table_info(debts)').get();
    if (debtRows.isNotEmpty) {
      final debtColumns =
          debtRows.map((row) => row.read<String>('name')).toSet();
      if (!debtColumns.contains('contact_id')) {
        await customStatement(
          'ALTER TABLE debts ADD COLUMN contact_id TEXT REFERENCES contacts(id)',
        );
      }
    }
  }

  /// Creates contacts from existing debt person names and links debts.
  Future<void> _migrateDebtsToContacts() async {
    final debtRows = await customSelect('''
      SELECT DISTINCT user_id, TRIM(person_name) AS name
      FROM debts
      WHERE deleted_at IS NULL
        AND TRIM(person_name) != ''
    ''').get();

    final now = DateTime.now();
    for (final row in debtRows) {
      final userId = row.read<String>('user_id');
      final name = row.read<String>('name');
      final existing = await customSelect(
        '''
        SELECT id FROM contacts
        WHERE user_id = ? AND LOWER(TRIM(name)) = LOWER(?)
          AND deleted_at IS NULL
        LIMIT 1
        ''',
        variables: [Variable<String>(userId), Variable<String>(name)],
      ).getSingleOrNull();

      final contactId = existing?.read<String>('id') ?? UuidHelper.generate();
      if (existing == null) {
        await into(contacts).insert(
          ContactsCompanion.insert(
            id: contactId,
            userId: userId,
            name: name,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      await customStatement(
        '''
        UPDATE debts
        SET contact_id = ?
        WHERE user_id = ?
          AND LOWER(TRIM(person_name)) = LOWER(?)
          AND contact_id IS NULL
        ''',
        [contactId, userId, name],
      );
    }
  }

  Future<void> _createContactsUniqueIndex() async {
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_contacts_user_name_active
      ON contacts (user_id, name)
      WHERE deleted_at IS NULL
    ''');
  }

  /// Adds [debt_id] and nullable [wallet_id] on [transactions] when missing.
  Future<void> _ensureTransactionDebtColumns() async {
    final rows = await customSelect('PRAGMA table_info(transactions)').get();
    final columnNames = rows
        .map((row) => row.read<String>('name'))
        .toSet();

    if (!columnNames.contains('debt_id')) {
      await customStatement(
        'ALTER TABLE transactions ADD COLUMN debt_id TEXT REFERENCES debts(id)',
      );
    }

    var walletNotNull = false;
    for (final row in rows) {
      if (row.read<String>('name') == 'wallet_id') {
        walletNotNull = row.read<int>('notnull') == 1;
        break;
      }
    }

    if (walletNotNull) {
      await customStatement('''
        CREATE TABLE transactions_new (
          id TEXT NOT NULL PRIMARY KEY,
          user_id TEXT NOT NULL REFERENCES app_users(id),
          wallet_id TEXT REFERENCES wallets(id),
          category_id TEXT REFERENCES categories(id),
          debt_id TEXT REFERENCES debts(id),
          type TEXT NOT NULL,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          currency_id TEXT NOT NULL REFERENCES currencies(id),
          exchange_rate REAL NOT NULL,
          base_amount REAL NOT NULL,
          notes TEXT,
          transaction_date INTEGER NOT NULL,
          attachment_count INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          deleted_at INTEGER
        )
      ''');

      await customStatement('''
        INSERT INTO transactions_new (
          id, user_id, wallet_id, category_id, debt_id, type, title, amount,
          currency_id, exchange_rate, base_amount, notes, transaction_date,
          attachment_count, created_at, updated_at, deleted_at
        )
        SELECT
          id, user_id, wallet_id, category_id, debt_id, type, title, amount,
          currency_id, exchange_rate, base_amount, notes, transaction_date,
          attachment_count, created_at, updated_at, deleted_at
        FROM transactions
      ''');

      await customStatement('DROP TABLE transactions');
      await customStatement(
        'ALTER TABLE transactions_new RENAME TO transactions',
      );
    }
  }

  /// Adds [wallet_id] on [goals] when missing (legacy DB repair).
  Future<void> _ensureGoalsWalletColumn() async {
    final rows = await customSelect('PRAGMA table_info(goals)').get();
    if (rows.isEmpty) return;

    final columnNames = rows
        .map((row) => row.read<String>('name'))
        .toSet();

    if (!columnNames.contains('wallet_id')) {
      await customStatement(
        'ALTER TABLE goals ADD COLUMN wallet_id TEXT REFERENCES wallets(id)',
      );
    }
  }

  /// Creates a treasury wallet for legacy goals that lack [wallet_id].
  Future<void> _backfillGoalWallets() async {
    final orphanGoals =
        await (select(goals)..where((g) => g.walletId.isNull())).get();

    for (final goal in orphanGoals) {
      final now = DateTime.now();
      final walletId = UuidHelper.generate();

      await into(wallets).insert(
        WalletsCompanion.insert(
          id: walletId,
          userId: goal.userId,
          name: goal.title,
          icon: Value(goal.icon),
          iconStyle: Value(goal.icon),
          createdAt: goal.createdAt,
          updatedAt: now,
        ),
      );

      await into(walletCurrencyAccounts).insert(
        WalletCurrencyAccountsCompanion.insert(
          id: UuidHelper.generate(),
          walletId: walletId,
          currencyId: goal.currencyId,
          openingBalance: Value(goal.savedAmount),
          createdAt: goal.createdAt,
          updatedAt: now,
        ),
      );

      await (update(goals)..where((g) => g.id.equals(goal.id))).write(
        GoalsCompanion(
          walletId: Value(walletId),
          updatedAt: Value(now),
        ),
      );
    }
  }

  /// Adds [wallet_id] on [debts] when missing (legacy DB repair).
  Future<void> _ensureDebtsWalletColumn() async {
    final rows = await customSelect('PRAGMA table_info(debts)').get();
    if (rows.isEmpty) return;

    final columnNames = rows
        .map((row) => row.read<String>('name'))
        .toSet();

    if (!columnNames.contains('wallet_id')) {
      await customStatement(
        'ALTER TABLE debts ADD COLUMN wallet_id TEXT REFERENCES wallets(id)',
      );
    }

    await customStatement('''
      UPDATE debts
      SET wallet_id = (
        SELECT w.id
        FROM wallets w
        WHERE w.user_id = debts.user_id
          AND w.deleted_at IS NULL
        ORDER BY w.created_at ASC
        LIMIT 1
      )
      WHERE wallet_id IS NULL
    ''');
  }

  /// Adds cross-currency columns to [transfers] when missing (legacy DB repair).
  Future<void> _ensureTransferCrossCurrencyColumns() async {
    final rows = await customSelect('PRAGMA table_info(transfers)').get();
    final columnNames = rows
        .map((row) => row.read<String>('name'))
        .toSet();

    if (!columnNames.contains('to_currency_id')) {
      await customStatement(
        'ALTER TABLE transfers ADD COLUMN to_currency_id TEXT REFERENCES currencies(id)',
      );
    }
    if (!columnNames.contains('to_amount')) {
      await customStatement(
        'ALTER TABLE transfers ADD COLUMN to_amount REAL',
      );
    }
    if (!columnNames.contains('to_exchange_rate')) {
      await customStatement(
        'ALTER TABLE transfers ADD COLUMN to_exchange_rate REAL',
      );
    }

    await customStatement('''
      UPDATE transfers
      SET to_currency_id = currency_id,
          to_amount = amount,
          to_exchange_rate = exchange_rate
      WHERE to_currency_id IS NULL
    ''');
  }

  /// Active currencies must be unique per user (applied after deduplication).
  Future<void> ensureCurrencyUniqueIndex() async {
    await _createCurrencyUniqueIndex();
  }

  /// At most one base currency per active user.
  Future<void> ensureBaseCurrencyUniqueIndex() async {
    await _dedupeBaseCurrencies();
    await _createBaseCurrencyUniqueIndex();
  }

  Future<void> _createCurrencyUniqueIndex() async {
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_currencies_user_code_active
      ON currencies (user_id, code)
      WHERE deleted_at IS NULL
    ''');
  }

  Future<void> _createBaseCurrencyUniqueIndex() async {
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_currencies_user_single_base
      ON currencies (user_id)
      WHERE is_base = 1 AND deleted_at IS NULL
    ''');
  }

  /// Keeps a single base currency row per user before applying the unique index.
  Future<void> _dedupeBaseCurrencies() async {
    final users = await select(appUsers).get();
    final now = DateTime.now();

    for (final user in users) {
      final baseRows = await (select(currencies)
            ..where((c) => c.userId.equals(user.id))
            ..where((c) => c.deletedAt.isNull())
            ..where((c) => c.isBase.equals(true))
            ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
          .get();

      if (baseRows.length <= 1) continue;

      final settings = await (select(userSettings)
            ..where((s) => s.userId.equals(user.id)))
          .getSingleOrNull();

      final keeperId = settings?.baseCurrencyId != null &&
              baseRows.any((r) => r.id == settings!.baseCurrencyId)
          ? settings!.baseCurrencyId
          : baseRows.first.id;

      for (final row in baseRows) {
        if (row.id == keeperId) continue;
        await (update(currencies)..where((c) => c.id.equals(row.id))).write(
          CurrenciesCompanion(
            isBase: const Value(false),
            updatedAt: Value(now),
          ),
        );
      }
    }
  }

  /// First active user id (single-user phase).
  Future<String?> getActiveUserId() async {
    final row = await (select(appUsers)
          ..where((u) => u.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row?.id;
  }
}
