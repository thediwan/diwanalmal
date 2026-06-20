import 'package:drift/drift.dart';

import '../lazarus_database.dart';
import '../tables/schema_tables.dart';
import '../../core/constants/database_constants.dart';
import '../../core/constants/report_constants.dart';
import '../../core/helpers/activity_feed_search.dart';
import '../../core/helpers/uuid_helper.dart';

part 'finance_dao.g.dart';

/// Aggregations and lists for dashboard and reports.
@DriftAccessor(tables: [
  Transactions,
  Transfers,
  Debts,
  DebtPayments,
  Goals,
  Wallets,
  WalletCurrencyAccounts,
  Currencies,
  Categories,
  Contacts,
  TransactionSplits,
  TransactionSplitParticipants,
  Budgets,
  MonthlyReports,
])
class FinanceDao extends DatabaseAccessor<LazarusDatabase>
    with _$FinanceDaoMixin {
  FinanceDao(super.db);

  /// Active treasuries with their currency account rows.
  Future<List<TreasuryWithAccounts>> getActiveTreasuries(String userId) async {
    final walletRows = await (select(db.wallets)
          ..where((w) => w.userId.equals(userId))
          ..where((w) => w.deletedAt.isNull())
          ..where((w) => w.isArchived.equals(false))
          ..orderBy([(w) => OrderingTerm.asc(w.name)]))
        .get();

    final result = <TreasuryWithAccounts>[];

    for (final wallet in walletRows) {
      final accounts = await _getAccountsForWallet(wallet.id);
      result.add(TreasuryWithAccounts(wallet: wallet, accounts: accounts));
    }

    return result;
  }

  Future<List<WalletAccountWithCurrency>> _getAccountsForWallet(
    String walletId,
  ) async {
    final a = db.walletCurrencyAccounts;
    final c = db.currencies;
    final query = select(a).join([
      innerJoin(c, c.id.equalsExp(a.currencyId)),
    ])
      ..where(a.walletId.equals(walletId))
      ..where(a.deletedAt.isNull());

    final rows = await query.get();
    return rows
        .map(
          (row) => WalletAccountWithCurrency(
            account: row.readTable(a),
            currencyCode: row.readTable(c).code,
            currencyRateToBase: row.readTable(c).rateToBase,
          ),
        )
        .toList();
  }

  /// Sum of base_amount for income/expense in calendar month.
  Future<double> sumTransactionsBaseAmount({
    required String userId,
    required String type,
    required int year,
    required int month,
  }) async {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    final expr = db.transactions.baseAmount.sum();
    final query = selectOnly(db.transactions)
      ..addColumns([expr])
      ..where(db.transactions.userId.equals(userId))
      ..where(db.transactions.type.equals(type))
      ..where(db.transactions.deletedAt.isNull())
      ..where(db.transactions.transactionDate.isBiggerOrEqualValue(start))
      ..where(db.transactions.transactionDate.isSmallerThanValue(end));

    final row = await query.getSingleOrNull();
    return row?.read(expr) ?? 0;
  }

  /// Wallet balance delta for a transaction type (+ inflow, − outflow, 0 ignored).
  static double transactionWalletBalanceDelta({
    required String type,
    required double amountInWalletCurrency,
  }) {
    switch (type) {
      case DatabaseConstants.txIncome:
      case DatabaseConstants.txCreditor:
        return amountInWalletCurrency;
      case DatabaseConstants.txExpense:
      case DatabaseConstants.txDebtor:
        return -amountInWalletCurrency;
      default:
        return 0;
    }
  }

  /// Outstanding debt in base currency minus partial payments.
  Future<double> sumOutstandingDebtsBase({
    required String userId,
    required String debtType,
  }) async {
    final debtRows = await (select(db.debts)
          ..where((d) => d.userId.equals(userId))
          ..where((d) => d.type.equals(debtType))
          ..where((d) => d.isPaid.equals(false))
          ..where((d) => d.deletedAt.isNull()))
        .get();

    var total = 0.0;
    for (final debt in debtRows) {
      final paidExpr = db.debtPayments.baseAmount.sum();
      final paidRow = await (selectOnly(db.debtPayments)
            ..addColumns([paidExpr])
            ..where(db.debtPayments.debtId.equals(debt.id)))
          .getSingleOrNull();
      final paid = paidRow?.read(paidExpr) ?? 0;
      total += debt.baseAmount - paid;
    }
    return total;
  }

  /// Financial goals for dashboard.
  Future<List<FinancialGoal>> getGoals(String userId) {
    return (select(db.goals)..where((g) => g.userId.equals(userId))).get();
  }

  /// Persists a new financial goal.
  Future<void> insertGoal(GoalsCompanion goal) {
    return into(db.goals).insert(goal);
  }

  /// Loads one goal for the active user.
  Future<FinancialGoal?> getGoalById({
    required String userId,
    required String goalId,
  }) {
    return (select(db.goals)
          ..where((g) => g.userId.equals(userId))
          ..where((g) => g.id.equals(goalId)))
        .getSingleOrNull();
  }

  /// Updates an existing goal row.
  Future<bool> updateGoal(FinancialGoal goal) {
    return update(db.goals).replace(goal);
  }

  /// Removes a goal permanently.
  Future<int> deleteGoal({
    required String userId,
    required String goalId,
  }) {
    return (delete(db.goals)
          ..where((g) => g.userId.equals(userId))
          ..where((g) => g.id.equals(goalId)))
        .go();
  }

  /// Loads the goal linked to a treasury wallet, if any.
  Future<FinancialGoal?> getGoalByWalletId({
    required String userId,
    required String walletId,
  }) {
    return (select(db.goals)
          ..where((g) => g.userId.equals(userId))
          ..where((g) => g.walletId.equals(walletId)))
        .getSingleOrNull();
  }

  /// Wallet ids that back financial goals (for UI badges).
  Future<Set<String>> getGoalWalletIds(String userId) async {
    final rows = await (select(db.goals)
          ..where((g) => g.userId.equals(userId))
          ..where((g) => g.walletId.isNotNull()))
        .get();
    return rows.map((g) => g.walletId!).toSet();
  }

  /// Maps goal wallet id → goal title for transfer list labeling.
  Future<Map<String, String>> getGoalWalletTitles(String userId) async {
    final rows = await (select(db.goals)
          ..where((g) => g.userId.equals(userId))
          ..where((g) => g.walletId.isNotNull()))
        .get();
    return {for (final goal in rows) goal.walletId!: goal.title};
  }

  /// Syncs [goals.saved_amount] from the linked wallet balance.
  Future<double> syncGoalSavedAmount(FinancialGoal goal) async {
    final walletId = goal.walletId;
    if (walletId == null) return goal.savedAmount;

    final balance = await computeAccountBalance(
      walletId: walletId,
      currencyId: goal.currencyId,
    );
    final now = DateTime.now();
    await (update(db.goals)..where((g) => g.id.equals(goal.id))).write(
      GoalsCompanion(
        savedAmount: Value(balance),
        updatedAt: Value(now),
      ),
    );
    return balance;
  }

  /// Syncs saved amounts for every goal of the user.
  Future<void> syncAllGoalSavedAmounts(String userId) async {
    final goals = await getGoals(userId);
    for (final goal in goals) {
      if (goal.walletId != null) {
        await syncGoalSavedAmount(goal);
      }
    }
  }

  /// Transfers received by [walletId] in [currencyId] during a calendar month.
  Future<double> sumTransfersToWalletInMonth({
    required String walletId,
    required String currencyId,
    required int year,
    required int month,
  }) async {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    final currency = await (select(db.currencies)
          ..where((c) => c.id.equals(currencyId)))
        .getSingleOrNull();
    if (currency == null) return 0;

    final incoming = await (select(db.transfers)
          ..where((t) => t.toWalletId.equals(walletId))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.transactionDate.isBiggerOrEqualValue(start))
          ..where((t) => t.transactionDate.isSmallerThanValue(end)))
        .get();

    var total = 0.0;
    for (final tr in incoming) {
      final creditCurrencyId = tr.toCurrencyId ?? tr.currencyId;
      if (creditCurrencyId != currencyId) continue;
      final creditAmount = tr.toAmount ?? tr.amount;
      final creditRate = tr.toExchangeRate ?? tr.exchangeRate;
      total += _amountInWalletCurrency(
        amount: creditAmount,
        txCurrencyId: creditCurrencyId,
        txRate: creditRate,
        walletCurrency: currency,
      );
    }
    return total;
  }

  /// Transfers sent from [walletId] in [currencyId] during a calendar month.
  Future<double> sumTransfersFromWalletInMonth({
    required String walletId,
    required String currencyId,
    required int year,
    required int month,
  }) async {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    final currency = await (select(db.currencies)
          ..where((c) => c.id.equals(currencyId)))
        .getSingleOrNull();
    if (currency == null) return 0;

    final outgoing = await (select(db.transfers)
          ..where((t) => t.fromWalletId.equals(walletId))
          ..where((t) => t.currencyId.equals(currencyId))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.transactionDate.isBiggerOrEqualValue(start))
          ..where((t) => t.transactionDate.isSmallerThanValue(end)))
        .get();

    var total = 0.0;
    for (final tr in outgoing) {
      total += _amountInWalletCurrency(
        amount: tr.amount,
        txCurrencyId: tr.currencyId,
        txRate: tr.exchangeRate,
        walletCurrency: currency,
      );
    }
    return total;
  }

  /// Recent transfers involving a goal wallet (newest first).
  Future<List<TransferWithMeta>> getTransfersForWallet({
    required String userId,
    required String walletId,
    int limit = 50,
  }) {
    return getFilteredTransfers(
      userId: userId,
      filter: ActivityFeedFilter(walletId: walletId),
      limit: limit,
    );
  }

  /// Refreshes saved_amount for goals linked to any of [walletIds].
  Future<void> syncGoalsForWalletIds(List<String> walletIds) async {
    if (walletIds.isEmpty) return;

    final uniqueIds = walletIds.toSet();
    for (final walletId in uniqueIds) {
      final goal = await (select(db.goals)
            ..where((g) => g.walletId.equals(walletId)))
          .getSingleOrNull();
      if (goal != null) {
        await syncGoalSavedAmount(goal);
      }
    }
  }

  /// Monthly income total in base currency for a calendar month.
  ///
  /// Includes creditor (payable) origination as cash inflow.
  Future<double> sumMonthlyIncomeBase({
    required String userId,
    required int year,
    required int month,
  }) async {
    final income = await sumTransactionsBaseAmount(
      userId: userId,
      type: DatabaseConstants.txIncome,
      year: year,
      month: month,
    );
    final creditor = await sumTransactionsBaseAmount(
      userId: userId,
      type: DatabaseConstants.txCreditor,
      year: year,
      month: month,
    );
    return income + creditor;
  }

  /// Monthly expense total in base currency for a calendar month.
  ///
  /// Includes debtor (receivable) origination as cash outflow.
  Future<double> sumMonthlyExpenseBase({
    required String userId,
    required int year,
    required int month,
  }) async {
    final expense = await sumTransactionsBaseAmount(
      userId: userId,
      type: DatabaseConstants.txExpense,
      year: year,
      month: month,
    );
    final debtor = await sumTransactionsBaseAmount(
      userId: userId,
      type: DatabaseConstants.txDebtor,
      year: year,
      month: month,
    );
    return expense + debtor;
  }

  /// Average salary income (base) from salary-category transactions.
  Future<double> averageSalaryIncomeBase(String userId) async {
    final t = db.transactions;
    final c = db.categories;
    final query = select(t).join([
      innerJoin(c, c.id.equalsExp(t.categoryId)),
    ])
      ..where(t.userId.equals(userId))
      ..where(t.type.equals('income'))
      ..where(t.deletedAt.isNull())
      ..where(c.name.equals('راتب'));

    final rows = await query.get();
    if (rows.isEmpty) return 0;

    final total = rows.fold<double>(
      0,
      (sum, row) => sum + row.readTable(t).baseAmount,
    );
    return total / rows.length;
  }

  /// Whether the user has any non-deleted transactions.
  Future<bool> hasAnyTransactions(String userId) async {
    final countExpr = db.transactions.id.count();
    final row = await (selectOnly(db.transactions)
          ..addColumns([countExpr])
          ..where(db.transactions.userId.equals(userId))
          ..where(db.transactions.deletedAt.isNull()))
        .getSingleOrNull();
    return (row?.read(countExpr) ?? 0) > 0;
  }

  /// Active categories filtered by income/expense type.
  Future<List<Category>> getCategoriesByType({
    required String userId,
    required String type,
  }) {
    return (select(db.categories)
          ..where((c) => c.userId.equals(userId))
          ..where((c) => c.type.equals(type))
          ..where((c) => c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  /// Persists a new income or expense transaction.
  Future<void> insertTransaction(TransactionsCompanion transaction) {
    return into(db.transactions).insert(transaction);
  }

  /// Persists a new debt master record.
  Future<void> insertDebt(DebtsCompanion debt) {
    return into(db.debts).insert(debt);
  }

  /// Updates an existing debt master record.
  Future<bool> updateDebtRecord(DebtsCompanion companion) async {
    final count = await (update(db.debts)
          ..where((d) => d.id.equals(companion.id.value)))
        .write(companion);
    return count > 0;
  }

  /// Loads a debt row by id.
  Future<Debt?> getDebtById(String debtId) {
    return (select(db.debts)
          ..where((d) => d.id.equals(debtId))
          ..where((d) => d.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Sum of payment amounts in the debt's currency (not base).
  Future<double> sumDebtPaymentsAmount(String debtId) async {
    final expr = db.debtPayments.amount.sum();
    final row = await (selectOnly(db.debtPayments)
          ..addColumns([expr])
          ..where(db.debtPayments.debtId.equals(debtId)))
        .getSingleOrNull();
    return row?.read(expr) ?? 0;
  }

  /// Payment history for one debt, newest first.
  Future<List<DebtPayment>> getDebtPayments(String debtId) {
    return (select(db.debtPayments)
          ..where((p) => p.debtId.equals(debtId))
          ..orderBy([(p) => OrderingTerm.desc(p.paymentDate)]))
        .get();
  }

  /// Persists a partial or full debt settlement payment.
  Future<void> insertDebtPayment(DebtPaymentsCompanion payment) {
    return into(db.debtPayments).insert(payment);
  }

  /// Full debt context for the ledger transaction row.
  Future<DebtLedgerDetail?> getDebtDetailByLedgerTransactionId(
    String transactionId,
  ) async {
    final row = await getTransactionById(transactionId);
    if (row == null) return null;

    final debtId = row.transaction.debtId;
    if (debtId == null) return null;

    final debt = await getDebtById(debtId);
    if (debt == null) return null;

    final wallet = await (select(db.wallets)
          ..where((w) => w.id.equals(debt.walletId)))
        .getSingleOrNull();

    final paidAmount = await sumDebtPaymentsAmount(debtId);
    final payments = await getDebtPayments(debtId);

    return DebtLedgerDetail(
      ledgerTransaction: row.transaction,
      debt: debt,
      currencyCode: row.currencyCode,
      walletName: wallet?.name ?? row.walletName,
      paidAmount: paidAmount,
      payments: payments,
    );
  }

  /// Persists a wallet currency transfer.
  Future<void> insertTransfer(TransfersCompanion transfer) {
    return into(db.transfers).insert(transfer);
  }

  /// Single transaction with wallet and category metadata.
  Future<TransactionWithWalletMeta?> getTransactionById(String id) {
    final t = db.transactions;
    final c = db.currencies;
    final cat = db.categories;
    final w = db.wallets;
    final d = db.debts;
    final query = select(t).join([
      innerJoin(c, c.id.equalsExp(t.currencyId)),
      leftOuterJoin(cat, cat.id.equalsExp(t.categoryId)),
      leftOuterJoin(w, w.id.equalsExp(t.walletId)),
      leftOuterJoin(d, d.id.equalsExp(t.debtId)),
    ])
      ..where(t.id.equals(id))
      ..where(t.deletedAt.isNull());

    return query.getSingleOrNull().then(
          (row) => row == null
              ? null
              : TransactionWithWalletMeta(
                  transaction: row.readTable(t),
                  currencyCode: row.readTable(c).code,
                  categoryIconKey: row.readTableOrNull(cat)?.icon,
                  categoryColorHex: row.readTableOrNull(cat)?.color,
                  walletName: row.readTableOrNull(w)?.name ?? '',
                  dueDate: row.readTableOrNull(d)?.dueDate,
                  debtIsPaid: row.readTableOrNull(d)?.isPaid,
                ),
        );
  }

  /// Category display name by id.
  Future<String?> getCategoryName(String id) {
    return (select(db.categories)..where((c) => c.id.equals(id)))
        .getSingleOrNull()
        .then((row) => row?.name);
  }

  /// Loads one active category row.
  Future<Category?> getCategoryById(String id) {
    return (select(db.categories)
          ..where((c) => c.id.equals(id))
          ..where((c) => c.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Counts non-deleted transactions linked to a category.
  Future<int> countTransactionsForCategory(String categoryId) async {
    final countExpr = db.transactions.id.count();
    final row = await (selectOnly(db.transactions)
          ..addColumns([countExpr])
          ..where(db.transactions.categoryId.equals(categoryId))
          ..where(db.transactions.deletedAt.isNull()))
        .getSingleOrNull();
    return row?.read(countExpr) ?? 0;
  }

  /// Inserts a category row.
  Future<void> insertCategory(CategoriesCompanion row) {
    return into(db.categories).insert(row);
  }

  /// Updates an existing category row.
  Future<bool> updateCategory(CategoriesCompanion row) async {
    final count = await (update(db.categories)
          ..where((c) => c.id.equals(row.id.value)))
        .write(row);
    return count > 0;
  }

  /// Soft-deletes a category.
  Future<bool> softDeleteCategory(String id, DateTime deletedAt) async {
    final count = await (update(db.categories)..where((c) => c.id.equals(id)))
        .write(
      CategoriesCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
      ),
    );
    return count > 0;
  }

  /// Single transfer with wallet and currency metadata.
  Future<TransferWithMeta?> getTransferById(String id) {
    final tr = db.transfers;
    final fromC = db.currencies.createAlias('from_currency');
    final toC = db.currencies.createAlias('to_currency');
    final fromW = db.wallets.createAlias('from_wallet');
    final toW = db.wallets.createAlias('to_wallet');
    final query = select(tr).join([
      innerJoin(fromC, fromC.id.equalsExp(tr.currencyId)),
      leftOuterJoin(toC, toC.id.equalsExp(tr.toCurrencyId)),
      innerJoin(fromW, fromW.id.equalsExp(tr.fromWalletId)),
      innerJoin(toW, toW.id.equalsExp(tr.toWalletId)),
    ])
      ..where(tr.id.equals(id))
      ..where(tr.deletedAt.isNull());

    return query.getSingleOrNull().then(
          (row) => row == null
              ? null
              : TransferWithMeta(
                  transfer: row.readTable(tr),
                  currencyCode: row.readTable(fromC).code,
                  toCurrencyCode: row.readTableOrNull(toC)?.code ??
                      row.readTable(fromC).code,
                  fromWalletName: row.readTable(fromW).name,
                  toWalletName: row.readTable(toW).name,
                ),
        );
  }

  /// Soft-deletes a transaction.
  Future<bool> softDeleteTransaction(String id) async {
    final now = DateTime.now();
    final count = await (update(db.transactions)..where((t) => t.id.equals(id)))
        .write(TransactionsCompanion(
      deletedAt: Value(now),
      updatedAt: Value(now),
    ));
    return count > 0;
  }

  /// Soft-deletes a transfer.
  Future<bool> softDeleteTransfer(String id) async {
    final now = DateTime.now();
    final count = await (update(db.transfers)..where((t) => t.id.equals(id)))
        .write(TransfersCompanion(
      deletedAt: Value(now),
      updatedAt: Value(now),
    ));
    return count > 0;
  }

  /// Updates an existing transaction.
  Future<bool> updateTransactionRecord(TransactionsCompanion companion) async {
    final count = await (update(db.transactions)
          ..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
    return count > 0;
  }

  /// Updates an existing transfer.
  Future<bool> updateTransferRecord(TransfersCompanion companion) async {
    final count = await (update(db.transfers)
          ..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
    return count > 0;
  }

  /// Recent transactions newest first (includes category icon metadata).
  Future<List<TransactionWithMeta>> getRecentTransactions(
    String userId, {
    int limit = 10,
  }) {
    final t = db.transactions;
    final c = db.currencies;
    final cat = db.categories;
    final query = select(t).join([
      innerJoin(c, c.id.equalsExp(t.currencyId)),
      leftOuterJoin(cat, cat.id.equalsExp(t.categoryId)),
    ])
      ..where(t.userId.equals(userId))
      ..where(t.deletedAt.isNull())
      ..orderBy([
        OrderingTerm.desc(t.transactionDate),
        OrderingTerm.desc(t.createdAt),
      ])
      ..limit(limit);

    return query.get().then(
          (rows) => rows
              .map(
                (row) => TransactionWithMeta(
                  transaction: row.readTable(t),
                  currencyCode: row.readTable(c).code,
                  categoryIconKey: row.readTableOrNull(cat)?.icon,
                  categoryColorHex: row.readTableOrNull(cat)?.color,
                ),
              )
              .toList(),
        );
  }

  /// Filtered income/expense rows for the transactions list (newest first).
  Future<List<TransactionWithWalletMeta>> getFilteredTransactions({
    required String userId,
    required ActivityFeedFilter filter,
    required int limit,
    int offset = 0,
  }) {
    final t = db.transactions;
    final c = db.currencies;
    final cat = db.categories;
    final w = db.wallets;
    final d = db.debts;
    final range = filter.resolvedDateRange;
    final keyword = filter.keyword?.trim();

    final query = select(t).join([
      innerJoin(c, c.id.equalsExp(t.currencyId)),
      leftOuterJoin(cat, cat.id.equalsExp(t.categoryId)),
      leftOuterJoin(w, w.id.equalsExp(t.walletId)),
      leftOuterJoin(d, d.id.equalsExp(t.debtId)),
    ])
      ..where(t.userId.equals(userId))
      ..where(t.deletedAt.isNull());

    if (filter.tab == ActivityFeedTab.expense) {
      query.where(t.type.equals('expense'));
    } else if (filter.tab == ActivityFeedTab.income) {
      query.where(t.type.equals('income'));
    } else if (filter.tab == ActivityFeedTab.debt) {
      query.where(
        t.type.equals('debtor') | t.type.equals('creditor'),
      );
    } else if (filter.tab == ActivityFeedTab.all &&
        filter.advancedTypeFilter == ActivityFeedTab.expense) {
      query.where(t.type.equals('expense'));
    } else if (filter.tab == ActivityFeedTab.all &&
        filter.advancedTypeFilter == ActivityFeedTab.income) {
      query.where(t.type.equals('income'));
    } else if (filter.tab == ActivityFeedTab.all &&
        filter.advancedTypeFilter == ActivityFeedTab.debt) {
      query.where(
        t.type.equals('debtor') | t.type.equals('creditor'),
      );
    }

    // Hide split-generated debt ledger rows from the "all" tab to avoid clutter.
    if (filter.tab == ActivityFeedTab.all &&
        filter.advancedTypeFilter == null) {
      query.where(t.parentTransactionId.isNull());
    }

    if (filter.walletId != null && filter.walletId!.isNotEmpty) {
      query.where(t.walletId.equals(filter.walletId!));
    }

    if (filter.categoryId != null && filter.categoryId!.isNotEmpty) {
      query.where(t.categoryId.equals(filter.categoryId!));
    }

    if (range != null) {
      query
        ..where(t.transactionDate.isBiggerOrEqualValue(range.start))
        ..where(t.transactionDate.isSmallerThanValue(range.end));
    }

    if (keyword != null && keyword.isNotEmpty) {
      query.where(
        ActivityFeedSearch.transactionKeywordMatch(
          t: t,
          w: w,
          c: c,
          cat: cat,
          keyword: keyword,
        ),
      );
    }

    query
      ..orderBy([
        OrderingTerm.desc(t.transactionDate),
        OrderingTerm.desc(t.createdAt),
      ])
      ..limit(limit, offset: offset);

    return query.get().then((rows) async {
      final splitTxIds = await _transactionIdsWithActiveSplit(
        rows.map((row) => row.readTable(t).id).toList(),
      );
      return rows
          .map(
            (row) => TransactionWithWalletMeta(
              transaction: row.readTable(t),
              currencyCode: row.readTable(c).code,
              categoryIconKey: row.readTableOrNull(cat)?.icon,
              categoryColorHex: row.readTableOrNull(cat)?.color,
              walletName: row.readTableOrNull(w)?.name ?? '',
              dueDate: row.readTableOrNull(d)?.dueDate,
              debtIsPaid: row.readTableOrNull(d)?.isPaid,
              isShared: splitTxIds.contains(row.readTable(t).id),
            ),
          )
          .toList();
    });
  }

  Future<Set<String>> _transactionIdsWithActiveSplit(
    List<String> transactionIds,
  ) async {
    if (transactionIds.isEmpty) return {};

    final splits = await (select(db.transactionSplits)
          ..where((s) => s.transactionId.isIn(transactionIds))
          ..where((s) => s.deletedAt.isNull()))
        .get();

    return splits.map((s) => s.transactionId).toSet();
  }

  /// Active contacts for the user, sorted by name.
  Future<List<DbContact>> getActiveContacts(String userId) {
    return (select(db.contacts)
          ..where((c) => c.userId.equals(userId))
          ..where((c) => c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm.asc(c.name)]))
        .get();
  }

  /// Case-insensitive contact lookup by trimmed name.
  Future<DbContact?> findContactByName({
    required String userId,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    final rows = await (select(db.contacts)
          ..where((c) => c.userId.equals(userId))
          ..where((c) => c.deletedAt.isNull()))
        .get();

    for (final contact in rows) {
      if (contact.name.trim().toLowerCase() == trimmed.toLowerCase()) {
        return contact;
      }
    }
    return null;
  }

  /// Persists a new contact row.
  Future<void> insertContact(ContactsCompanion contact) {
    return into(db.contacts).insert(contact);
  }

  /// Updates an existing contact row.
  Future<bool> updateContactRecord(ContactsCompanion companion) async {
    final count = await (update(db.contacts)
          ..where((c) => c.id.equals(companion.id.value)))
        .write(companion);
    return count > 0;
  }

  /// Loads a contact by id.
  Future<DbContact?> getContactById(String contactId) {
    return (select(db.contacts)
          ..where((c) => c.id.equals(contactId))
          ..where((c) => c.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Persists a transaction split header.
  Future<void> insertTransactionSplit(TransactionSplitsCompanion split) {
    return into(db.transactionSplits).insert(split);
  }

  /// Persists one split participant line.
  Future<void> insertTransactionSplitParticipant(
    TransactionSplitParticipantsCompanion participant,
  ) {
    return into(db.transactionSplitParticipants).insert(participant);
  }

  /// Active split header for a parent transaction.
  Future<DbTransactionSplit?> getSplitByTransactionId(
    String transactionId,
  ) {
    return (select(db.transactionSplits)
          ..where((s) => s.transactionId.equals(transactionId))
          ..where((s) => s.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Participant lines with contact names for a split.
  Future<List<SplitParticipantDetail>> getSplitParticipants(
    String splitId,
  ) async {
    final p = db.transactionSplitParticipants;
    final c = db.contacts;
    final rows = await (select(p).join([
      innerJoin(c, c.id.equalsExp(p.contactId)),
    ])
          ..where(p.splitId.equals(splitId))
          ..orderBy([OrderingTerm.asc(p.sortOrder)]))
        .get();

    return rows
        .map(
          (row) => SplitParticipantDetail(
            participant: row.readTable(p),
            contactName: row.readTable(c).name,
          ),
        )
        .toList();
  }

  /// Full split detail for a parent transaction id.
  Future<TransactionSplitDetail?> getSplitDetailByTransactionId(
    String transactionId,
  ) async {
    final split = await getSplitByTransactionId(transactionId);
    if (split == null) return null;

    final participants = await getSplitParticipants(split.id);
    return TransactionSplitDetail(
      split: split,
      participants: participants,
    );
  }

  /// Soft-deletes a split header and its participant rows (debts handled separately).
  Future<void> softDeleteSplitByTransactionId(String transactionId) async {
    final now = DateTime.now();
    await (update(db.transactionSplits)
          ..where((s) => s.transactionId.equals(transactionId)))
        .write(TransactionSplitsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ));
  }

  /// Child debt ledger transactions linked to a parent split transaction.
  Future<List<Transaction>> getSplitChildTransactions(
    String parentTransactionId,
  ) {
    return (select(db.transactions)
          ..where((t) => t.parentTransactionId.equals(parentTransactionId))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Updates participant debt/debtTransaction references after creation.
  Future<void> updateSplitParticipantLinks({
    required String participantId,
    String? debtId,
    String? debtTransactionId,
  }) {
    return (update(db.transactionSplitParticipants)
          ..where((p) => p.id.equals(participantId)))
        .write(TransactionSplitParticipantsCompanion(
          debtId: debtId == null ? const Value.absent() : Value(debtId),
          debtTransactionId: debtTransactionId == null
              ? const Value.absent()
              : Value(debtTransactionId),
        ));
  }

  /// Filtered wallet transfers for the transactions list (newest first).
  Future<List<TransferWithMeta>> getFilteredTransfers({
    required String userId,
    required ActivityFeedFilter filter,
    required int limit,
    int offset = 0,
  }) {
    final tr = db.transfers;
    final c = db.currencies;
    final toC = db.currencies.createAlias('to_currency');
    final fromW = db.wallets.createAlias('from_wallet');
    final toW = db.wallets.createAlias('to_wallet');
    final range = filter.resolvedDateRange;
    final keyword = filter.keyword?.trim();

    final query = select(tr).join([
      innerJoin(c, c.id.equalsExp(tr.currencyId)),
      leftOuterJoin(toC, toC.id.equalsExp(tr.toCurrencyId)),
      leftOuterJoin(fromW, fromW.id.equalsExp(tr.fromWalletId)),
      leftOuterJoin(toW, toW.id.equalsExp(tr.toWalletId)),
    ])
      ..where(tr.userId.equals(userId))
      ..where(tr.deletedAt.isNull());

    if (filter.walletId != null && filter.walletId!.isNotEmpty) {
      query.where(
        tr.fromWalletId.equals(filter.walletId!) |
            tr.toWalletId.equals(filter.walletId!),
      );
    }

    if (range != null) {
      query
        ..where(tr.transactionDate.isBiggerOrEqualValue(range.start))
        ..where(tr.transactionDate.isSmallerThanValue(range.end));
    }

    if (keyword != null && keyword.isNotEmpty) {
      query.where(
        ActivityFeedSearch.transferKeywordMatch(
          tr: tr,
          fromW: fromW,
          toW: toW,
          c: c,
          keyword: keyword,
        ),
      );
    }

    query
      ..orderBy([
        OrderingTerm.desc(tr.transactionDate),
        OrderingTerm.desc(tr.createdAt),
      ])
      ..limit(limit, offset: offset);

    return query.get().then(
          (rows) => rows
              .map(
                (row) => TransferWithMeta(
                  transfer: row.readTable(tr),
                  currencyCode: row.readTable(c).code,
                  toCurrencyCode:
                      row.readTableOrNull(toC)?.code ?? row.readTable(c).code,
                  fromWalletName: row.readTableOrNull(fromW)?.name ?? '',
                  toWalletName: row.readTableOrNull(toW)?.name ?? '',
                ),
              )
              .toList(),
        );
  }

  /// Daily expense totals (base) for chart — last [days] days.
  Future<List<ChartDayTotal>> getDailyExpenseTotals(
    String userId, {
    int days = 30,
  }) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final rows = await (select(db.transactions)
          ..where((t) => t.userId.equals(userId))
          ..where((t) => t.type.equals('expense'))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.transactionDate.isBiggerOrEqualValue(since)))
        .get();

    final byDay = <DateTime, double>{};
    for (final row in rows) {
      final day = DateTime(
        row.transactionDate.year,
        row.transactionDate.month,
        row.transactionDate.day,
      );
      byDay[day] = (byDay[day] ?? 0) + row.baseAmount;
    }

    final sorted = byDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sorted
        .map((e) => ChartDayTotal(date: e.key, totalBase: e.value))
        .toList();
  }

  /// Opening balance + operations for one treasury currency account.
  Future<double> computeAccountBalance({
    required String walletId,
    required String currencyId,
  }) async {
    final account = await (select(db.walletCurrencyAccounts)
          ..where((a) => a.walletId.equals(walletId))
          ..where((a) => a.currencyId.equals(currencyId))
          ..where((a) => a.deletedAt.isNull()))
        .getSingleOrNull();

    final currency = await (select(db.currencies)
          ..where((c) => c.id.equals(currencyId)))
        .getSingleOrNull();
    if (currency == null) return account?.openingBalance ?? 0;

    var balance = account?.openingBalance ?? 0;

    final txs = await (select(db.transactions)
          ..where((t) => t.walletId.equals(walletId))
          ..where((t) => t.currencyId.equals(currencyId))
          ..where((t) => t.deletedAt.isNull()))
        .get();

    for (final tx in txs) {
      final inWallet = _amountInWalletCurrency(
        amount: tx.amount,
        txCurrencyId: tx.currencyId,
        txRate: tx.exchangeRate,
        walletCurrency: currency,
      );
      balance += FinanceDao.transactionWalletBalanceDelta(
        type: tx.type,
        amountInWalletCurrency: inWallet,
      );
    }

    final transfersOut = await (select(db.transfers)
          ..where((t) => t.fromWalletId.equals(walletId))
          ..where((t) => t.currencyId.equals(currencyId))
          ..where((t) => t.deletedAt.isNull()))
        .get();
    for (final tr in transfersOut) {
      balance -= _amountInWalletCurrency(
        amount: tr.amount,
        txCurrencyId: tr.currencyId,
        txRate: tr.exchangeRate,
        walletCurrency: currency,
      );
    }

    final transfersIn = await (select(db.transfers)
          ..where((t) => t.toWalletId.equals(walletId))
          ..where((t) => t.deletedAt.isNull()))
        .get();
    for (final tr in transfersIn) {
      final creditCurrencyId = tr.toCurrencyId ?? tr.currencyId;
      if (creditCurrencyId != currencyId) continue;
      final creditAmount = tr.toAmount ?? tr.amount;
      final creditRate = tr.toExchangeRate ?? tr.exchangeRate;
      balance += _amountInWalletCurrency(
        amount: creditAmount,
        txCurrencyId: creditCurrencyId,
        txRate: creditRate,
        walletCurrency: currency,
      );
    }

    return balance;
  }

  /// Backward-compatible alias keyed by wallet id only (first account).
  Future<double> computeWalletBalance(String walletId) async {
    final account = await (select(db.walletCurrencyAccounts)
          ..where((a) => a.walletId.equals(walletId))
          ..where((a) => a.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    if (account == null) return 0;
    return computeAccountBalance(
      walletId: walletId,
      currencyId: account.currencyId,
    );
  }

  double _amountInWalletCurrency({
    required double amount,
    required String txCurrencyId,
    required double txRate,
    required DbCurrency walletCurrency,
  }) {
    if (txCurrencyId == walletCurrency.id) return amount;
    final base = amount * txRate;
    if (walletCurrency.rateToBase == 0) return 0;
    return base / walletCurrency.rateToBase;
  }

  DateTime _monthStart(int year, int month) => DateTime(year, month);

  DateTime _monthEnd(int year, int month) => DateTime(year, month + 1);

  /// Expense totals grouped by category for a calendar month.
  Future<List<CategoryAmountBreakdown>> sumExpensesByCategory({
    required String userId,
    required int year,
    required int month,
  }) async {
    return _sumTransactionsByCategory(
      userId: userId,
      type: DatabaseConstants.txExpense,
      year: year,
      month: month,
    );
  }

  /// Income totals grouped by category for a calendar month.
  Future<List<CategoryAmountBreakdown>> sumIncomeByCategory({
    required String userId,
    required int year,
    required int month,
  }) async {
    return _sumTransactionsByCategory(
      userId: userId,
      type: DatabaseConstants.txIncome,
      year: year,
      month: month,
    );
  }

  Future<List<CategoryAmountBreakdown>> _sumTransactionsByCategory({
    required String userId,
    required String type,
    required int year,
    required int month,
  }) async {
    final start = _monthStart(year, month);
    final end = _monthEnd(year, month);
    final t = db.transactions;
    final c = db.categories;

    final rows = await (select(t)
          ..where((row) => row.userId.equals(userId))
          ..where((row) => row.type.equals(type))
          ..where((row) => row.deletedAt.isNull())
          ..where((row) => row.transactionDate.isBiggerOrEqualValue(start))
          ..where((row) => row.transactionDate.isSmallerThanValue(end)))
        .join([
      leftOuterJoin(c, c.id.equalsExp(t.categoryId)),
    ]).get();

    final totalsByCategory = <String, _CategoryAccumulator>{};
    for (final row in rows) {
      final tx = row.readTable(t);
      final cat = row.readTableOrNull(c);
      final categoryId = tx.categoryId ?? 'unknown';
      final acc = totalsByCategory.putIfAbsent(
        categoryId,
        () => _CategoryAccumulator(
          categoryId: categoryId,
          categoryName: cat?.name ?? categoryId,
          iconKey: cat?.icon,
          colorHex: cat?.color,
        ),
      );
      acc.totalBase += tx.baseAmount;
    }

    final totalAll =
        totalsByCategory.values.fold<double>(0, (sum, a) => sum + a.totalBase);

    final result = totalsByCategory.values
        .map(
          (acc) => CategoryAmountBreakdown(
            categoryId: acc.categoryId,
            categoryName: acc.categoryName,
            iconKey: acc.iconKey,
            colorHex: acc.colorHex,
            totalBase: acc.totalBase,
            percentOfTotal:
                totalAll <= 0 ? 0 : (acc.totalBase / totalAll) * 100,
          ),
        )
        .toList()
      ..sort((a, b) => b.totalBase.compareTo(a.totalBase));

    return result;
  }

  /// Goal deposits (transfers into goal wallets) in base currency for a month.
  Future<double> sumGoalDepositsBase({
    required String userId,
    required int year,
    required int month,
  }) async {
    final goalWalletIds = await getGoalWalletIds(userId);
    if (goalWalletIds.isEmpty) return 0;

    final start = _monthStart(year, month);
    final end = _monthEnd(year, month);

    final rows = await (select(db.transfers)
          ..where((tr) => tr.userId.equals(userId))
          ..where((tr) => tr.deletedAt.isNull())
          ..where((tr) => tr.toWalletId.isIn(goalWalletIds.toList()))
          ..where((tr) => tr.transactionDate.isBiggerOrEqualValue(start))
          ..where((tr) => tr.transactionDate.isSmallerThanValue(end)))
        .get();

    return rows.fold<double>(0, (sum, tr) => sum + tr.baseAmount);
  }

  /// Income, expense, and goal savings per month for trend charts.
  Future<List<MonthlyTrendPoint>> getMonthlyTrend({
    required String userId,
    required int monthsBack,
  }) async {
    final now = DateTime.now();
    final points = <MonthlyTrendPoint>[];

    for (var i = monthsBack - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i);
      final year = date.year;
      final month = date.month;
      final income = await sumMonthlyIncomeBase(
        userId: userId,
        year: year,
        month: month,
      );
      final expense = await sumMonthlyExpenseBase(
        userId: userId,
        year: year,
        month: month,
      );
      final savings = await sumGoalDepositsBase(
        userId: userId,
        year: year,
        month: month,
      );
      points.add(
        MonthlyTrendPoint(
          year: year,
          month: month,
          income: income,
          expense: expense,
          goalSavings: savings,
          surplus: income - expense,
        ),
      );
    }

    return points;
  }

  /// Budget rows with actual expense spend for the same month.
  Future<List<BudgetWithActual>> getBudgetsWithActuals({
    required String userId,
    required int year,
    required int month,
  }) async {
    final budgets = await getBudgetsForMonth(
      userId: userId,
      year: year,
      month: month,
    );
    if (budgets.isEmpty) return [];

    final expenseByCategory = await sumExpensesByCategory(
      userId: userId,
      year: year,
      month: month,
    );
    final actualMap = {
      for (final row in expenseByCategory) row.categoryId: row.totalBase,
    };

    final c = db.categories;
    final cur = db.currencies;
    final result = <BudgetWithActual>[];

    for (final budget in budgets) {
      final category = await (select(c)
            ..where((cat) => cat.id.equals(budget.categoryId)))
          .getSingleOrNull();
      final currency = await (select(cur)
            ..where((row) => row.id.equals(budget.currencyId)))
          .getSingleOrNull();
      final actual = actualMap[budget.categoryId] ?? 0;
      result.add(
        BudgetWithActual(
          budget: budget,
          categoryName: category?.name ?? budget.categoryId,
          categoryIconKey: category?.icon,
          categoryColorHex: category?.color,
          currencyCode: currency?.code ?? '',
          actualBase: actual,
          percentUsed: budget.amount <= 0 ? 0 : (actual / budget.amount) * 100,
          remaining: budget.amount - actual,
        ),
      );
    }

    return result..sort((a, b) => b.percentUsed.compareTo(a.percentUsed));
  }

  /// All budget rows for a user in a calendar month.
  Future<List<Budget>> getBudgetsForMonth({
    required String userId,
    required int year,
    required int month,
  }) {
    return (select(db.budgets)
          ..where((b) => b.userId.equals(userId))
          ..where((b) => b.year.equals(year))
          ..where((b) => b.month.equals(month))
          ..orderBy([(b) => OrderingTerm.asc(b.createdAt)]))
        .get();
  }

  /// Loads one budget by id for the active user.
  Future<Budget?> getBudgetById({
    required String userId,
    required String budgetId,
  }) {
    return (select(db.budgets)
          ..where((b) => b.userId.equals(userId))
          ..where((b) => b.id.equals(budgetId)))
        .getSingleOrNull();
  }

  /// Finds budget for category in a given month.
  Future<Budget?> getBudgetForCategoryMonth({
    required String userId,
    required String categoryId,
    required int year,
    required int month,
  }) {
    return (select(db.budgets)
          ..where((b) => b.userId.equals(userId))
          ..where((b) => b.categoryId.equals(categoryId))
          ..where((b) => b.year.equals(year))
          ..where((b) => b.month.equals(month)))
        .getSingleOrNull();
  }

  /// Inserts or replaces a budget row.
  Future<void> upsertBudget(BudgetsCompanion budget) {
    return into(db.budgets).insertOnConflictUpdate(budget);
  }

  /// Deletes a budget row.
  Future<int> deleteBudget({
    required String userId,
    required String budgetId,
  }) {
    return (delete(db.budgets)
          ..where((b) => b.userId.equals(userId))
          ..where((b) => b.id.equals(budgetId)))
        .go();
  }

  /// Copies all budgets from the previous calendar month.
  Future<int> copyBudgetsFromPreviousMonth({
    required String userId,
    required int year,
    required int month,
  }) async {
    final previous = DateTime(year, month - 1);
    final source = await getBudgetsForMonth(
      userId: userId,
      year: previous.year,
      month: previous.month,
    );
    if (source.isEmpty) return 0;

    final now = DateTime.now();
    var copied = 0;
    for (final row in source) {
      final existing = await getBudgetForCategoryMonth(
        userId: userId,
        categoryId: row.categoryId,
        year: year,
        month: month,
      );
      if (existing != null) continue;

      await upsertBudget(
        BudgetsCompanion.insert(
          id: UuidHelper.generate(),
          userId: userId,
          categoryId: row.categoryId,
          month: month,
          year: year,
          amount: row.amount,
          currencyId: row.currencyId,
          createdAt: now,
          updatedAt: now,
        ),
      );
      copied++;
    }
    return copied;
  }

  /// Monthly report for a specific calendar month.
  Future<MonthlyReportRow?> getMonthlyReport({
    required String userId,
    required int year,
    required int month,
  }) {
    return (select(db.monthlyReports)
          ..where((r) => r.userId.equals(userId))
          ..where((r) => r.year.equals(year))
          ..where((r) => r.month.equals(month)))
        .getSingleOrNull();
  }

  /// Most recent finalized report before [year]/[month].
  Future<MonthlyReportRow?> getPreviousFinalizedReport({
    required String userId,
    required int year,
    required int month,
  }) async {
    final target = DateTime(year, month);
    final rows = await (select(db.monthlyReports)
          ..where((r) => r.userId.equals(userId))
          ..where((r) => r.status.equals(ReportConstants.statusFinalized))
          ..orderBy([(r) => OrderingTerm.desc(r.year), (r) => OrderingTerm.desc(r.month)]))
        .get();

    for (final row in rows) {
      final rowDate = DateTime(row.year, row.month);
      if (rowDate.isBefore(target)) return row;
    }
    return null;
  }

  /// Carryover amount from the immediately previous finalized report.
  Future<double> getPreviousCarryoverIn({
    required String userId,
    required int year,
    required int month,
  }) async {
    final previous = await getPreviousFinalizedReport(
      userId: userId,
      year: year,
      month: month,
    );
    return previous?.carriedForwardAmount ?? 0;
  }

  /// All monthly reports for a user, newest first.
  Future<List<MonthlyReportRow>> listMonthlyReports(String userId) {
    return (select(db.monthlyReports)
          ..where((r) => r.userId.equals(userId))
          ..orderBy([
            (r) => OrderingTerm.desc(r.year),
            (r) => OrderingTerm.desc(r.month),
          ]))
        .get();
  }

  /// Inserts or updates a monthly report snapshot.
  Future<void> upsertMonthlyReport(MonthlyReportsCompanion report) {
    return into(db.monthlyReports).insertOnConflictUpdate(report);
  }

  /// Updates disposition fields on an existing report.
  Future<bool> updateMonthlyReportRow(MonthlyReportRow report) {
    return update(db.monthlyReports).replace(report);
  }
}

class _CategoryAccumulator {
  _CategoryAccumulator({
    required this.categoryId,
    required this.categoryName,
    this.iconKey,
    this.colorHex,
  });

  final String categoryId;
  final String categoryName;
  final String? iconKey;
  final String? colorHex;
  double totalBase = 0;
}

class CategoryAmountBreakdown {
  const CategoryAmountBreakdown({
    required this.categoryId,
    required this.categoryName,
    this.iconKey,
    this.colorHex,
    required this.totalBase,
    required this.percentOfTotal,
  });

  final String categoryId;
  final String categoryName;
  final String? iconKey;
  final String? colorHex;
  final double totalBase;
  final double percentOfTotal;
}

class MonthlyTrendPoint {
  const MonthlyTrendPoint({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
    required this.goalSavings,
    required this.surplus,
  });

  final int year;
  final int month;
  final double income;
  final double expense;
  final double goalSavings;
  final double surplus;
}

class BudgetWithActual {
  const BudgetWithActual({
    required this.budget,
    required this.categoryName,
    this.categoryIconKey,
    this.categoryColorHex,
    required this.currencyCode,
    required this.actualBase,
    required this.percentUsed,
    required this.remaining,
  });

  final Budget budget;
  final String categoryName;
  final String? categoryIconKey;
  final String? categoryColorHex;
  final String currencyCode;
  final double actualBase;
  final double percentUsed;
  final double remaining;
}

class TreasuryWithAccounts {
  const TreasuryWithAccounts({
    required this.wallet,
    required this.accounts,
  });

  final DbWallet wallet;
  final List<WalletAccountWithCurrency> accounts;
}

class WalletAccountWithCurrency {
  const WalletAccountWithCurrency({
    required this.account,
    required this.currencyCode,
    required this.currencyRateToBase,
  });

  final DbWalletCurrencyAccount account;
  final String currencyCode;
  final double currencyRateToBase;
}

/// Tab filter for the unified transactions list feed.
enum ActivityFeedTab { all, expense, income, transfer, debt }

/// Date range resolved from chip and/or custom filter sheet values.
class ActivityFeedDateRange {
  const ActivityFeedDateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

/// Query parameters for paginated activity feed.
class ActivityFeedFilter {
  const ActivityFeedFilter({
    this.tab = ActivityFeedTab.all,
    this.walletId,
    this.categoryId,
    this.advancedTypeFilter,
    this.dateFrom,
    this.dateTo,
    this.thisMonthOnly = false,
    this.keyword,
  });

  final ActivityFeedTab tab;
  final String? walletId;
  final String? categoryId;
  /// Optional type from the filter sheet (applies when [tab] is [ActivityFeedTab.all]).
  final ActivityFeedTab? advancedTypeFilter;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final bool thisMonthOnly;
  final String? keyword;

  /// Effective calendar range: custom sheet dates override the month chip.
  ActivityFeedDateRange? get resolvedDateRange {
    if (dateFrom != null || dateTo != null) {
      final start = dateFrom != null
          ? DateTime(dateFrom!.year, dateFrom!.month, dateFrom!.day)
          : DateTime(1970);
      final endExclusive = dateTo != null
          ? DateTime(dateTo!.year, dateTo!.month, dateTo!.day + 1)
          : DateTime(2100);
      return ActivityFeedDateRange(start: start, end: endExclusive);
    }

    if (!thisMonthOnly) return null;

    final now = DateTime.now();
    return ActivityFeedDateRange(
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month + 1),
    );
  }

  ActivityFeedFilter copyWith({
    ActivityFeedTab? tab,
    String? walletId,
    bool clearWalletId = false,
    String? categoryId,
    bool clearCategoryId = false,
    ActivityFeedTab? advancedTypeFilter,
    bool clearAdvancedTypeFilter = false,
    DateTime? dateFrom,
    bool clearDateFrom = false,
    DateTime? dateTo,
    bool clearDateTo = false,
    bool? thisMonthOnly,
    String? keyword,
    bool clearKeyword = false,
  }) {
    return ActivityFeedFilter(
      tab: tab ?? this.tab,
      walletId: clearWalletId ? null : (walletId ?? this.walletId),
      categoryId:
          clearCategoryId ? null : (categoryId ?? this.categoryId),
      advancedTypeFilter: clearAdvancedTypeFilter
          ? null
          : (advancedTypeFilter ?? this.advancedTypeFilter),
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
      thisMonthOnly: thisMonthOnly ?? this.thisMonthOnly,
      keyword: clearKeyword ? null : (keyword ?? this.keyword),
    );
  }
}

class TransactionWithMeta {
  const TransactionWithMeta({
    required this.transaction,
    required this.currencyCode,
    this.categoryIconKey,
    this.categoryColorHex,
  });

  final Transaction transaction;
  final String currencyCode;
  final String? categoryIconKey;
  final String? categoryColorHex;
}

class TransactionWithWalletMeta extends TransactionWithMeta {
  const TransactionWithWalletMeta({
    required super.transaction,
    required super.currencyCode,
    super.categoryIconKey,
    super.categoryColorHex,
    required this.walletName,
    this.dueDate,
    this.debtIsPaid,
    this.isShared = false,
  });

  final String walletName;
  final DateTime? dueDate;
  final bool? debtIsPaid;
  final bool isShared;
}

class TransferWithMeta {
  const TransferWithMeta({
    required this.transfer,
    required this.currencyCode,
    required this.toCurrencyCode,
    required this.fromWalletName,
    required this.toWalletName,
  });

  final Transfer transfer;
  final String currencyCode;
  final String toCurrencyCode;
  final String fromWalletName;
  final String toWalletName;
}

class ChartDayTotal {
  const ChartDayTotal({required this.date, required this.totalBase});

  final DateTime date;
  final double totalBase;
}

/// Debt ledger row with payment progress for detail / settlement UI.
class DebtLedgerDetail {
  const DebtLedgerDetail({
    required this.ledgerTransaction,
    required this.debt,
    required this.currencyCode,
    required this.walletName,
    required this.paidAmount,
    required this.payments,
  });

  final Transaction ledgerTransaction;
  final Debt debt;
  final String currencyCode;
  final String walletName;
  final double paidAmount;
  final List<DebtPayment> payments;

  double get remaining {
    final left = debt.amount - paidAmount;
    return left < 0 ? 0 : left;
  }

  bool get isFullyPaid => debt.isPaid || remaining <= 0.000001;
}

/// One participant row in a transaction split with display name.
class SplitParticipantDetail {
  const SplitParticipantDetail({
    required this.participant,
    required this.contactName,
  });

  final DbTransactionSplitParticipant participant;
  final String contactName;
}

/// Split header with participant lines.
class TransactionSplitDetail {
  const TransactionSplitDetail({
    required this.split,
    required this.participants,
  });

  final DbTransactionSplit split;
  final List<SplitParticipantDetail> participants;
}
