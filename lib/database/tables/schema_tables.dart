import 'package:drift/drift.dart';

/// Application users (multi-user ready).
@DataClassName('AppUser')
class AppUsers extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text().withLength(min: 1, max: 255)();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get avatarPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Local login credentials.
class AuthLocal extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(AppUsers, #id)();
  TextColumn get username => text().withLength(min: 1, max: 100)();
  TextColumn get passwordHash => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// PIN / biometric preferences (no biometric data stored).
class SecuritySettings extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(AppUsers, #id)();
  BoolColumn get biometricEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get pinEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get pinHash => text().nullable()();
  IntColumn get autoLockMinutes =>
      integer().withDefault(const Constant(5))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Currencies and exchange rates to base.
@DataClassName('DbCurrency')
class Currencies extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(AppUsers, #id)();
  TextColumn get code => text().withLength(min: 1, max: 10)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get symbol => text().withLength(min: 1, max: 20)();
  RealColumn get rateToBase => real()();
  BoolColumn get isBase => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Per-user preferences including base currency.
class UserSettings extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(AppUsers, #id)();
  TextColumn get baseCurrencyId => text().references(Currencies, #id)();
  TextColumn get language => text().withDefault(const Constant('ar'))();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Treasury (خزينة) — container for multiple currency accounts.
@DataClassName('DbWallet')
class Wallets extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(AppUsers, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get icon => text().nullable()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get iconStyle => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Currency balance inside a treasury — opening balance only; current balance is computed.
@DataClassName('DbWalletCurrencyAccount')
class WalletCurrencyAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get walletId => text().references(Wallets, #id)();
  TextColumn get currencyId => text().references(Currencies, #id)();
  RealColumn get openingBalance => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Income / expense categories.
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(AppUsers, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get type => text()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Reusable contacts for debts and transaction splits.
@DataClassName('DbContact')
class Contacts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(AppUsers, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Income, expense, and debt ledger operations.
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(AppUsers, #id)();
  TextColumn get walletId => text().nullable().references(Wallets, #id)();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get debtId => text().nullable().references(Debts, #id)();
  TextColumn get parentTransactionId =>
      text().nullable().references(Transactions, #id)();
  TextColumn get type => text()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  RealColumn get amount => real()();
  TextColumn get currencyId => text().references(Currencies, #id)();
  RealColumn get exchangeRate => real()();
  RealColumn get baseAmount => real()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  IntColumn get attachmentCount =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Wallet-to-wallet transfers (not income/expense).
class Transfers extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(AppUsers, #id)();
  TextColumn get fromWalletId => text().references(Wallets, #id)();
  TextColumn get toWalletId => text().references(Wallets, #id)();
  RealColumn get amount => real()();
  TextColumn get currencyId => text().references(Currencies, #id)();
  RealColumn get exchangeRate => real()();
  RealColumn get baseAmount => real()();
  TextColumn get toCurrencyId =>
      text().nullable().references(Currencies, #id)();
  RealColumn get toAmount => real().nullable()();
  RealColumn get toExchangeRate => real().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Debts and creditors.
class Debts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(AppUsers, #id)();
  TextColumn get walletId => text().references(Wallets, #id)();
  TextColumn get contactId =>
      text().nullable().references(Contacts, #id)();
  TextColumn get personName => text().withLength(min: 1, max: 255)();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  TextColumn get currencyId => text().references(Currencies, #id)();
  RealColumn get exchangeRate => real()();
  RealColumn get baseAmount => real()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  DateTimeColumn get paidAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Split header for a shared income/expense transaction.
@DataClassName('DbTransactionSplit')
class TransactionSplits extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(AppUsers, #id)();
  TextColumn get transactionId =>
      text().references(Transactions, #id)();
  TextColumn get splitMode => text()();
  BoolColumn get includeSelfInEqualSplit =>
      boolean().withDefault(const Constant(true))();
  RealColumn get fixedAmountPerPerson => real().nullable()();
  RealColumn get userShareAmount => real()();
  RealColumn get totalAmount => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One participant line in a transaction split.
@DataClassName('DbTransactionSplitParticipant')
class TransactionSplitParticipants extends Table {
  TextColumn get id => text()();
  TextColumn get splitId =>
      text().references(TransactionSplits, #id)();
  TextColumn get contactId => text().references(Contacts, #id)();
  RealColumn get shareAmount => real()();
  RealColumn get sharePercent => real().nullable()();
  TextColumn get debtId => text().nullable().references(Debts, #id)();
  TextColumn get debtTransactionId =>
      text().nullable().references(Transactions, #id)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Partial debt repayments.
class DebtPayments extends Table {
  TextColumn get id => text()();
  TextColumn get debtId => text().references(Debts, #id)();
  RealColumn get amount => real()();
  TextColumn get currencyId => text().references(Currencies, #id)();
  RealColumn get exchangeRate => real()();
  RealColumn get baseAmount => real()();
  DateTimeColumn get paymentDate => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Monthly category budgets.
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(AppUsers, #id)();
  TextColumn get categoryId => text().references(Categories, #id)();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
  RealColumn get amount => real()();
  TextColumn get currencyId => text().references(Currencies, #id)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Financial goals.
@DataClassName('FinancialGoal')
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(AppUsers, #id)();
  TextColumn get walletId =>
      text().nullable().references(Wallets, #id)();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  RealColumn get targetAmount => real()();
  RealColumn get savedAmount => real().withDefault(const Constant(0))();
  TextColumn get currencyId => text().references(Currencies, #id)();
  TextColumn get icon => text().nullable()();
  DateTimeColumn get targetDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// File attachments (local path only).
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(AppUsers, #id)();
  TextColumn get transactionId =>
      text().nullable().references(Transactions, #id)();
  TextColumn get debtId => text().nullable().references(Debts, #id)();
  TextColumn get filePath => text()();
  TextColumn get fileName => text().withLength(min: 1, max: 255)();
  IntColumn get fileSize => integer()();
  TextColumn get mimeType => text().withLength(min: 1, max: 100)();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
