import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'category_icon_styles.dart';
import '../../features/transactions/models/transaction_list_item.dart';

/// Resolved icon and accent color for a transaction row.
class TransactionIconStyle {
  const TransactionIconStyle({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;
}

/// Shared icon and amount styling for dashboard and transactions list.
abstract final class TransactionIconStyles {
  static TransactionIconStyle forCategory({
    required String? iconKey,
    required String? colorHex,
    required bool isIncome,
  }) {
    return TransactionIconStyle(
      icon: CategoryIconStyles.iconFor(iconKey),
      color: CategoryIconStyles.colorFor(
        colorHex,
        fallback: isIncome ? AppColors.success : AppColors.debtAccent,
      ),
    );
  }

  static TransactionIconStyle forDebt({required bool isDebtor}) {
    return TransactionIconStyle(
      icon: isDebtor ? Icons.person_outline : Icons.person_off_outlined,
      color: isDebtor ? AppColors.success : AppColors.debtAccent,
    );
  }

  static TransactionIconStyle forTransfer({Color? primary}) {
    return TransactionIconStyle(
      icon: Icons.swap_horiz_rounded,
      color: primary ?? AppColors.primary,
    );
  }

  static TransactionIconStyle forGoalDeposit() {
    return const TransactionIconStyle(
      icon: Icons.savings_outlined,
      color: AppColors.success,
    );
  }

  static TransactionIconStyle forGoalWithdraw() {
    return const TransactionIconStyle(
      icon: Icons.savings_outlined,
      color: AppColors.expense,
    );
  }

  static TransactionIconStyle forKind(TransactionListKind kind) {
    return switch (kind) {
      TransactionListKind.transfer => forTransfer(),
      TransactionListKind.goalDeposit => forGoalDeposit(),
      TransactionListKind.goalWithdraw => forGoalWithdraw(),
      TransactionListKind.debtor => forDebt(isDebtor: true),
      TransactionListKind.creditor => forDebt(isDebtor: false),
      TransactionListKind.income => forCategory(
          iconKey: null,
          colorHex: null,
          isIncome: true,
        ),
      TransactionListKind.expense => forCategory(
          iconKey: null,
          colorHex: null,
          isIncome: false,
        ),
    };
  }

  static Color amountColorForKind(TransactionListKind kind, {Color? primary}) {
    return switch (kind) {
      TransactionListKind.transfer => primary ?? AppColors.primary,
      TransactionListKind.goalDeposit => AppColors.success,
      TransactionListKind.goalWithdraw => AppColors.expense,
      TransactionListKind.debtor => AppColors.success,
      TransactionListKind.creditor => AppColors.debtAccent,
      TransactionListKind.income => AppColors.success,
      TransactionListKind.expense => AppColors.expense,
    };
  }
}
