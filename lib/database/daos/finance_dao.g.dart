// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_dao.dart';

// ignore_for_file: type=lint
mixin _$FinanceDaoMixin on DatabaseAccessor<LazarusDatabase> {
  $AppUsersTable get appUsers => attachedDatabase.appUsers;
  $WalletsTable get wallets => attachedDatabase.wallets;
  $CategoriesTable get categories => attachedDatabase.categories;
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $DebtsTable get debts => attachedDatabase.debts;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $TransfersTable get transfers => attachedDatabase.transfers;
  $DebtPaymentsTable get debtPayments => attachedDatabase.debtPayments;
  $GoalsTable get goals => attachedDatabase.goals;
  $WalletCurrencyAccountsTable get walletCurrencyAccounts =>
      attachedDatabase.walletCurrencyAccounts;
  FinanceDaoManager get managers => FinanceDaoManager(this);
}

class FinanceDaoManager {
  final _$FinanceDaoMixin _db;
  FinanceDaoManager(this._db);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db.attachedDatabase, _db.appUsers);
  $$WalletsTableTableManager get wallets =>
      $$WalletsTableTableManager(_db.attachedDatabase, _db.wallets);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db.attachedDatabase, _db.currencies);
  $$DebtsTableTableManager get debts =>
      $$DebtsTableTableManager(_db.attachedDatabase, _db.debts);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
  $$TransfersTableTableManager get transfers =>
      $$TransfersTableTableManager(_db.attachedDatabase, _db.transfers);
  $$DebtPaymentsTableTableManager get debtPayments =>
      $$DebtPaymentsTableTableManager(_db.attachedDatabase, _db.debtPayments);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db.attachedDatabase, _db.goals);
  $$WalletCurrencyAccountsTableTableManager get walletCurrencyAccounts =>
      $$WalletCurrencyAccountsTableTableManager(
          _db.attachedDatabase, _db.walletCurrencyAccounts);
}
