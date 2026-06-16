import 'package:intl/intl.dart';

import '../core/constants/database_constants.dart';
import '../core/constants/transaction_policy.dart';
import '../core/constants/transaction_icon_styles.dart';
import '../core/helpers/currency_formatter.dart';
import '../database/daos/finance_dao.dart';
import '../features/transactions/models/transaction_list_item.dart';
import '../l10n/app_localizations.dart';
import 'lazarus_database_service.dart';

/// Loads, merges, and maps paginated transactions and transfers for the list UI.
class TransactionListService {
  TransactionListService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  static const int pageSize = 50;

  /// Fetches one merged page ordered by date descending.
  Future<TransactionListPage> fetchPage({
    required ActivityFeedFilter filter,
    required int page,
    required String baseCurrencyCode,
    required AppLocalizations l10n,
    required String localeName,
    required int deleteWindowHours,
    required int editWindowDays,
  }) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      return const TransactionListPage(items: [], hasMore: false);
    }

    final skip = page * pageSize;
    final dao = _lazarus.database.financeDao;
    final includeTransactions = filter.tab != ActivityFeedTab.transfer;
    final includeTransfers =
        filter.tab == ActivityFeedTab.transfer ||
        (filter.tab == ActivityFeedTab.all &&
            filter.advancedTypeFilter != ActivityFeedTab.expense &&
            filter.advancedTypeFilter != ActivityFeedTab.income &&
            filter.advancedTypeFilter != ActivityFeedTab.debt);
    final mergeStreams = includeTransactions && includeTransfers;

    final merged = <TransactionListItem>[];

    if (includeTransactions) {
      final rows = await dao.getFilteredTransactions(
        userId: userId,
        filter: filter,
        limit: mergeStreams ? skip + pageSize + 1 : pageSize + 1,
        offset: mergeStreams ? 0 : skip,
      );
      merged.addAll(
        rows.map(
          (row) => _mapTransaction(
            row: row,
            baseCurrencyCode: baseCurrencyCode,
            l10n: l10n,
            localeName: localeName,
            deleteWindowHours: deleteWindowHours,
            editWindowDays: editWindowDays,
          ),
        ),
      );
    }

    if (includeTransfers) {
      final rows = await dao.getFilteredTransfers(
        userId: userId,
        filter: filter,
        limit: mergeStreams ? skip + pageSize + 1 : pageSize + 1,
        offset: mergeStreams ? 0 : skip,
      );
      merged.addAll(
        rows.map(
          (row) => _mapTransfer(
            row: row,
            baseCurrencyCode: baseCurrencyCode,
            l10n: l10n,
            localeName: localeName,
            deleteWindowHours: deleteWindowHours,
            editWindowDays: editWindowDays,
          ),
        ),
      );
    }

    merged.sort((a, b) {
      final byDate = b.transactionDate.compareTo(a.transactionDate);
      if (byDate != 0) return byDate;
      return b.createdAt.compareTo(a.createdAt);
    });

    final List<TransactionListItem> pageItems;
    final bool hasMore;

    if (mergeStreams) {
      final slice = merged.skip(skip).take(pageSize + 1).toList();
      hasMore = slice.length > pageSize;
      pageItems = slice.take(pageSize).toList();
    } else {
      hasMore = merged.length > pageSize;
      pageItems = merged.take(pageSize).toList();
    }

    return TransactionListPage(
      items: pageItems,
      hasMore: hasMore,
    );
  }

  /// Groups flat items by calendar day with localized headers.
  List<TransactionListDateGroup> groupByDate({
    required List<TransactionListItem> items,
    required AppLocalizations l10n,
    required String localeName,
  }) {
    if (items.isEmpty) return const [];

    final groups = <DateTime, List<TransactionListItem>>{};
    for (final item in items) {
      final day = DateTime(
        item.transactionDate.year,
        item.transactionDate.month,
        item.transactionDate.day,
      );
      groups.putIfAbsent(day, () => []).add(item);
    }

    final sortedDays = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return sortedDays
        .map(
          (day) => TransactionListDateGroup(
            header: _formatDayHeader(day, l10n, localeName),
            items: groups[day]!,
          ),
        )
        .toList();
  }

  TransactionListItem _mapTransaction({
    required TransactionWithWalletMeta row,
    required String baseCurrencyCode,
    required AppLocalizations l10n,
    required String localeName,
    required int deleteWindowHours,
    required int editWindowDays,
  }) {
    final tx = row.transaction;
    final createdAt = tx.createdAt;

    if (tx.type == DatabaseConstants.txDebtor ||
        tx.type == DatabaseConstants.txCreditor) {
      final isDebtor = tx.type == DatabaseConstants.txDebtor;
      final sign = isDebtor ? '+' : '-';
      final showSecondary =
          row.currencyCode.toUpperCase() != baseCurrencyCode.toUpperCase();
      final subtitle = _formatDebtSubtitle(
        date: tx.transactionDate,
        dueDate: row.dueDate,
        isPaid: row.debtIsPaid ?? false,
        isDebtor: isDebtor,
        localeName: localeName,
        l10n: l10n,
      );

      final iconStyle = TransactionIconStyles.forDebt(isDebtor: isDebtor);

      return TransactionListItem(
        id: tx.id,
        kind: isDebtor
            ? TransactionListKind.debtor
            : TransactionListKind.creditor,
        title: tx.title,
        subtitle: subtitle,
        primaryAmount:
            '${CurrencyFormatter.formatCodeFirst(tx.baseAmount, baseCurrencyCode)}$sign',
        secondaryAmount: showSecondary
            ? CurrencyFormatter.formatCodeFirst(tx.amount, row.currencyCode)
            : null,
        transactionDate: tx.transactionDate,
        createdAt: createdAt,
        notes: tx.notes,
        icon: iconStyle.icon,
        iconColor: iconStyle.color,
        isIncome: isDebtor,
        isTransfer: false,
        isDebt: true,
        canEdit: TransactionPolicy.canEdit(
          createdAt: createdAt,
          editWindowDays: editWindowDays,
        ),
        canDelete: TransactionPolicy.canDelete(
          createdAt: createdAt,
          deleteWindowHours: deleteWindowHours,
        ),
      );
    }

    final isIncome = tx.type == DatabaseConstants.txIncome;
    final sign = isIncome ? '+' : '-';
    final showSecondary =
        row.currencyCode.toUpperCase() != baseCurrencyCode.toUpperCase();
    final categoryStyle = TransactionIconStyles.forCategory(
      iconKey: row.categoryIconKey,
      colorHex: row.categoryColorHex,
      isIncome: isIncome,
    );

    return TransactionListItem(
      id: tx.id,
      kind: isIncome
          ? TransactionListKind.income
          : TransactionListKind.expense,
      title: tx.title,
      subtitle: _formatSubtitle(
        date: tx.transactionDate,
        walletName: row.walletName,
        localeName: localeName,
        unknownWalletLabel: l10n.transactionsListUnknownWallet,
      ),
      primaryAmount:
          '${CurrencyFormatter.formatCodeFirst(tx.baseAmount, baseCurrencyCode)}$sign',
      secondaryAmount: showSecondary
          ? CurrencyFormatter.formatCodeFirst(tx.amount, row.currencyCode)
          : null,
      transactionDate: tx.transactionDate,
      createdAt: createdAt,
      notes: tx.notes,
      icon: categoryStyle.icon,
      iconColor: categoryStyle.color,
      isIncome: isIncome,
      isTransfer: false,
      canEdit: TransactionPolicy.canEdit(
        createdAt: createdAt,
        editWindowDays: editWindowDays,
      ),
      canDelete: TransactionPolicy.canDelete(
        createdAt: createdAt,
        deleteWindowHours: deleteWindowHours,
      ),
    );
  }

  TransactionListItem _mapTransfer({
    required TransferWithMeta row,
    required String baseCurrencyCode,
    required AppLocalizations l10n,
    required String localeName,
    required int deleteWindowHours,
    required int editWindowDays,
  }) {
    final tr = row.transfer;
    final showSecondary =
        row.currencyCode.toUpperCase() != baseCurrencyCode.toUpperCase();
    final title = tr.notes?.trim().isNotEmpty == true
        ? tr.notes!.trim()
        : l10n.transactionsListTransferCurrencyTitle(
            row.currencyCode,
            row.toCurrencyCode,
          );
    final createdAt = tr.createdAt;
    final targetAmount = tr.toAmount ?? tr.amount;

    final transferStyle = TransactionIconStyles.forTransfer();

    return TransactionListItem(
      id: tr.id,
      kind: TransactionListKind.transfer,
      title: title,
      subtitle: _formatSubtitle(
        date: tr.transactionDate,
        walletName: row.fromWalletName,
        localeName: localeName,
        unknownWalletLabel: l10n.transactionsListUnknownWallet,
      ),
      primaryAmount: CurrencyFormatter.formatCodeFirst(
        tr.amount,
        row.currencyCode,
      ),
      secondaryAmount: row.toCurrencyCode.toUpperCase() !=
              row.currencyCode.toUpperCase()
          ? CurrencyFormatter.formatCodeFirst(targetAmount, row.toCurrencyCode)
          : showSecondary
              ? CurrencyFormatter.formatCodeFirst(tr.baseAmount, baseCurrencyCode)
              : null,
      transactionDate: tr.transactionDate,
      createdAt: createdAt,
      notes: tr.notes,
      icon: transferStyle.icon,
      iconColor: transferStyle.color,
      isIncome: false,
      isTransfer: true,
      canEdit: TransactionPolicy.canEdit(
        createdAt: createdAt,
        editWindowDays: editWindowDays,
      ),
      canDelete: TransactionPolicy.canDelete(
        createdAt: createdAt,
        deleteWindowHours: deleteWindowHours,
      ),
    );
  }

  String _formatDebtSubtitle({
    required DateTime date,
    required DateTime? dueDate,
    required bool isPaid,
    required bool isDebtor,
    required String localeName,
    required AppLocalizations l10n,
  }) {
    final time = DateFormat.jm(localeName).format(date);
    final kindLabel =
        isDebtor ? l10n.transactionsListDebtReceivable : l10n.transactionsListDebtPayable;
    if (isPaid) {
      return '$time • $kindLabel • ${l10n.transactionsListDebtPaid}';
    }
    if (dueDate != null) {
      return '$time • $kindLabel • ${l10n.transactionsListDueDate(DateFormat.MMMd(localeName).format(dueDate))}';
    }
    return '$time • $kindLabel';
  }

  String _formatSubtitle({
    required DateTime date,
    required String walletName,
    required String localeName,
    required String unknownWalletLabel,
  }) {
    final time = DateFormat.jm(localeName).format(date);
    final wallet = walletName.trim().isEmpty ? unknownWalletLabel : walletName;
    return '$time • $wallet';
  }

  String _formatDayHeader(
    DateTime day,
    AppLocalizations l10n,
    String localeName,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateLabel = DateFormat.MMMd(localeName).format(day);

    if (day == today) {
      return l10n.transactionsListDateToday(dateLabel);
    }
    if (day == today.subtract(const Duration(days: 1))) {
      return l10n.transactionsListDateYesterday(dateLabel);
    }
    return DateFormat.yMMMd(localeName).format(day);
  }
}
