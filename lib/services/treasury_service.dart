import 'package:drift/drift.dart';

import '../core/helpers/currency_formatter.dart';
import '../core/helpers/uuid_helper.dart';
import '../database/lazarus_database.dart';
import '../models/opening_balance_input.dart';
import '../models/treasury.dart';
import 'lazarus_database_service.dart';

/// Treasury (خزينة) CRUD and balance loading.
class TreasuryService {
  TreasuryService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  LazarusDatabase get _db => _lazarus.database;

  Future<List<Treasury>> getAll() async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return [];

    final rows = await _db.financeDao.getActiveTreasuries(userId);
    final treasuries = <Treasury>[];

    for (final row in rows) {
      final accounts = <TreasuryAccountBalance>[];

      for (final account in row.accounts) {
        final balance = await _db.financeDao.computeAccountBalance(
          walletId: row.wallet.id,
          currencyId: account.account.currencyId,
        );
        accounts.add(
          TreasuryAccountBalance(
            accountId: account.account.id,
            currencyId: account.account.currencyId,
            currencyCode: account.currencyCode,
            balance: balance,
            balanceInBase: CurrencyFormatter.toBaseAmount(
              balance,
              account.currencyRateToBase,
            ),
            rateToBase: account.currencyRateToBase,
          ),
        );
      }

      treasuries.add(
        Treasury(
          id: row.wallet.id,
          name: row.wallet.name,
          icon: row.wallet.icon ?? '💰',
          subtitle: row.wallet.subtitle,
          iconStyle: row.wallet.iconStyle,
          createdAt: row.wallet.createdAt,
          accounts: accounts,
        ),
      );
    }

    return treasuries;
  }

  Future<Treasury?> getById(String id) async {
    final all = await getAll();
    return all.where((t) => t.id == id).firstOrNull;
  }

  /// Creates a treasury with one or more currency accounts.
  Future<Treasury> createWithAccounts({
    required String name,
    required String icon,
    required List<OpeningBalanceInput> openingBalances,
    String? subtitle,
    String? iconStyle,
  }) async {
    if (openingBalances.isEmpty) {
      throw ArgumentError('At least one opening balance is required');
    }

    final codes = openingBalances.map((e) => e.currencyCode.toUpperCase()).toList();
    if (codes.length != codes.toSet().length) {
      throw Exception('duplicate_currency');
    }

    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for treasury creation');
    }

    final now = DateTime.now();
    final treasuryId = UuidHelper.generate();

    await _db.transaction(() async {
      await _db.into(_db.wallets).insert(
            WalletsCompanion.insert(
              id: treasuryId,
              userId: userId,
              name: name,
              icon: Value(icon),
              subtitle: Value(subtitle),
              iconStyle: Value(iconStyle),
              createdAt: now,
              updatedAt: now,
            ),
          );

      for (final entry in openingBalances) {
        final currency = await (_db.select(_db.currencies)
              ..where((c) => c.userId.equals(userId))
              ..where((c) => c.code.equals(entry.currencyCode.toUpperCase())))
            .getSingleOrNull();

        if (currency == null) {
          throw Exception('currency_not_found');
        }

        await _db.into(_db.walletCurrencyAccounts).insert(
              WalletCurrencyAccountsCompanion.insert(
                id: UuidHelper.generate(),
                walletId: treasuryId,
                currencyId: currency.id,
                openingBalance: Value(entry.initialBalance),
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
    });

    return (await getById(treasuryId))!;
  }

  /// Updates treasury metadata and syncs currency accounts / balances.
  Future<Treasury> updateWithAccounts({
    required String id,
    required String name,
    required String icon,
    required List<OpeningBalanceInput> openingBalances,
    String? subtitle,
    String? iconStyle,
  }) async {
    if (openingBalances.isEmpty) {
      throw ArgumentError('At least one opening balance is required');
    }

    final codes =
        openingBalances.map((e) => e.currencyCode.toUpperCase()).toList();
    if (codes.length != codes.toSet().length) {
      throw Exception('duplicate_currency');
    }

    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for treasury update');
    }

    final now = DateTime.now();
    final existingAccounts = await (_db.select(_db.walletCurrencyAccounts)
          ..where((a) => a.walletId.equals(id))
          ..where((a) => a.deletedAt.isNull()))
        .get();

    final keptAccountIds = <String>{};

    await _db.transaction(() async {
      await (_db.update(_db.wallets)..where((w) => w.id.equals(id))).write(
            WalletsCompanion(
              name: Value(name),
              icon: Value(icon),
              subtitle: Value(subtitle),
              iconStyle: Value(iconStyle),
              updatedAt: Value(now),
            ),
          );

      for (final entry in openingBalances) {
        final currency = await (_db.select(_db.currencies)
              ..where((c) => c.userId.equals(userId))
              ..where((c) => c.code.equals(entry.currencyCode.toUpperCase())))
            .getSingleOrNull();

        if (currency == null) {
          throw Exception('currency_not_found');
        }

        DbWalletCurrencyAccount? account;

        if (entry.accountId != null) {
          account = existingAccounts
              .where((a) => a.id == entry.accountId)
              .firstOrNull;
        }

        account ??= existingAccounts
            .where((a) => a.currencyId == currency.id)
            .firstOrNull;

        if (account != null) {
          keptAccountIds.add(account.id);
          final currentBalance = await _db.financeDao.computeAccountBalance(
            walletId: id,
            currencyId: account.currencyId,
          );
          final operationsNet = currentBalance - account.openingBalance;
          final newOpeningBalance = entry.initialBalance - operationsNet;

          await (_db.update(_db.walletCurrencyAccounts)
                ..where((a) => a.id.equals(account!.id)))
              .write(
            WalletCurrencyAccountsCompanion(
              openingBalance: Value(newOpeningBalance),
              updatedAt: Value(now),
            ),
          );
        } else {
          final accountId = UuidHelper.generate();
          keptAccountIds.add(accountId);
          await _db.into(_db.walletCurrencyAccounts).insert(
                WalletCurrencyAccountsCompanion.insert(
                  id: accountId,
                  walletId: id,
                  currencyId: currency.id,
                  openingBalance: Value(entry.initialBalance),
                  createdAt: now,
                  updatedAt: now,
                ),
              );
        }
      }

      for (final account in existingAccounts) {
        if (keptAccountIds.contains(account.id)) continue;

        final hasActivity = await _accountHasActivity(
          walletId: id,
          currencyId: account.currencyId,
        );
        if (hasActivity) {
          throw Exception('account_has_transactions');
        }

        await (_db.update(_db.walletCurrencyAccounts)
              ..where((a) => a.id.equals(account.id)))
            .write(WalletCurrencyAccountsCompanion(deletedAt: Value(now)));
      }
    });

    return (await getById(id))!;
  }

  Future<bool> _accountHasActivity({
    required String walletId,
    required String currencyId,
  }) async {
    final tx = await (_db.select(_db.transactions)
          ..where((t) => t.walletId.equals(walletId))
          ..where((t) => t.currencyId.equals(currencyId))
          ..where((t) => t.deletedAt.isNull())
          ..limit(1))
        .get();
    if (tx.isNotEmpty) return true;

    final transferOut = await (_db.select(_db.transfers)
          ..where((t) => t.fromWalletId.equals(walletId))
          ..where((t) => t.currencyId.equals(currencyId))
          ..where((t) => t.deletedAt.isNull())
          ..limit(1))
        .get();
    if (transferOut.isNotEmpty) return true;

    final transferIn = await (_db.select(_db.transfers)
          ..where((t) => t.toWalletId.equals(walletId))
          ..where((t) => t.currencyId.equals(currencyId))
          ..where((t) => t.deletedAt.isNull())
          ..limit(1))
        .get();
    return transferIn.isNotEmpty;
  }

  /// Creates a treasury with a single currency account (legacy).
  Future<Treasury> create({
    required String name,
    required String currencyCode,
    required double initialBalance,
    required String icon,
    String? subtitle,
    String? iconStyle,
  }) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      throw StateError('No active user for treasury creation');
    }

    final currency = await (_db.select(_db.currencies)
          ..where((c) => c.userId.equals(userId))
          ..where((c) => c.code.equals(currencyCode.toUpperCase())))
        .getSingleOrNull();

    if (currency == null) {
      throw Exception('العملة غير موجودة');
    }

    final now = DateTime.now();
    final treasuryId = UuidHelper.generate();
    final accountId = UuidHelper.generate();

    await _db.transaction(() async {
      await _db.into(_db.wallets).insert(
            WalletsCompanion.insert(
              id: treasuryId,
              userId: userId,
              name: name,
              icon: Value(icon),
              subtitle: Value(subtitle),
              iconStyle: Value(iconStyle),
              createdAt: now,
              updatedAt: now,
            ),
          );

      await _db.into(_db.walletCurrencyAccounts).insert(
            WalletCurrencyAccountsCompanion.insert(
              id: accountId,
              walletId: treasuryId,
              currencyId: currency.id,
              openingBalance: Value(initialBalance),
              createdAt: now,
              updatedAt: now,
            ),
          );
    });

    return (await getById(treasuryId))!;
  }

  Future<void> delete(String id) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.walletCurrencyAccounts)
            ..where((a) => a.walletId.equals(id)))
          .write(WalletCurrencyAccountsCompanion(deletedAt: Value(now)));

      await (_db.update(_db.wallets)..where((w) => w.id.equals(id))).write(
            WalletsCompanion(deletedAt: Value(now)),
          );
    });
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
