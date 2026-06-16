import 'package:drift/drift.dart';

import '../../database/lazarus_database.dart';

/// Builds keyword [Expression]s for activity feed text + amount search.
abstract final class ActivityFeedSearch {
  /// SQL LIKE pattern for the raw keyword.
  static String likePattern(String keyword) => '%$keyword%';

  /// Digits and decimal separator kept for amount matching.
  static String amountKey(String keyword) {
    return keyword.replaceAll(RegExp(r'[^\d.]'), '');
  }

  /// Matches transaction title, notes, wallet, category, currency, and amounts.
  static Expression<bool> transactionKeywordMatch({
    required $TransactionsTable t,
    required $WalletsTable w,
    required $CurrenciesTable c,
    required $CategoriesTable cat,
    required String keyword,
  }) {
    final pattern = likePattern(keyword);
    final numericKey = amountKey(keyword);

    var match = t.title.like(pattern) |
        t.notes.like(pattern) |
        w.name.like(pattern) |
        c.code.like(pattern) |
        cat.name.like(pattern);

    if (numericKey.isNotEmpty) {
      final amountPattern = likePattern(numericKey);
      match = match |
          t.amount.cast<String>().like(amountPattern) |
          t.baseAmount.cast<String>().like(amountPattern);
    }

    return match;
  }

  /// Matches transfer notes, wallets, currency, and amounts.
  static Expression<bool> transferKeywordMatch({
    required $TransfersTable tr,
    required $WalletsTable fromW,
    required $WalletsTable toW,
    required $CurrenciesTable c,
    required String keyword,
  }) {
    final pattern = likePattern(keyword);
    final numericKey = amountKey(keyword);

    var match = tr.notes.like(pattern) |
        fromW.name.like(pattern) |
        toW.name.like(pattern) |
        c.code.like(pattern);

    if (numericKey.isNotEmpty) {
      final amountPattern = likePattern(numericKey);
      match = match |
          tr.amount.cast<String>().like(amountPattern) |
          tr.baseAmount.cast<String>().like(amountPattern);
    }

    return match;
  }
}
