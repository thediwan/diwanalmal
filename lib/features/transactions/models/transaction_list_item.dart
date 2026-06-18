import 'package:flutter/material.dart';

/// Row kind in the unified transactions list.
enum TransactionListKind {
  expense,
  income,
  transfer,
  goalDeposit,
  goalWithdraw,
  debtor,
  creditor,
}

/// View model for one row in the transactions list.
class TransactionListItem {
  const TransactionListItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.primaryAmount,
    this.secondaryAmount,
    required this.transactionDate,
    required this.createdAt,
    this.notes,
    required this.icon,
    required this.iconColor,
    bool? isIncome,
    bool? isTransfer,
    bool? isDebt,
    bool? canEdit,
    bool? canDelete,
  })  : _isIncome = isIncome,
        _isTransfer = isTransfer,
        _isDebt = isDebt,
        _canEdit = canEdit,
        _canDelete = canDelete;

  final String id;
  final TransactionListKind kind;
  final String title;
  final String subtitle;
  final String primaryAmount;
  final String? secondaryAmount;
  final DateTime transactionDate;
  final DateTime createdAt;
  final String? notes;
  final IconData icon;
  final Color iconColor;

  final bool? _isIncome;
  final bool? _isTransfer;
  final bool? _isDebt;
  final bool? _canEdit;
  final bool? _canDelete;

  bool get isIncome => _isIncome ?? false;
  bool get isTransfer => _isTransfer ?? false;
  bool get isDebt => _isDebt ?? false;
  bool get canEdit => _canEdit ?? false;
  bool get canDelete => _canDelete ?? false;
}

/// One page of merged activity feed results.
class TransactionListPage {
  const TransactionListPage({
    required this.items,
    required this.hasMore,
  });

  final List<TransactionListItem> items;
  final bool hasMore;
}

/// Date bucket for grouped list rendering.
class TransactionListDateGroup {
  const TransactionListDateGroup({
    required this.header,
    required this.items,
  });

  final String header;
  final List<TransactionListItem> items;
}
