import '../../l10n/app_localizations.dart';
import '../../models/transaction_category.dart';
import '../constants/database_constants.dart';

/// Localized labels and guards for system categories.
abstract final class CategoryLocalization {
  static String name(TransactionCategory category, AppLocalizations l10n) {
    if (category.id == DatabaseConstants.systemGeneralIncomeCategoryId) {
      return l10n.categoryGeneralIncome;
    }
    if (category.id == DatabaseConstants.systemGeneralExpenseCategoryId) {
      return l10n.categoryGeneralExpense;
    }
    return category.name;
  }
}

extension TransactionCategoryLocalization on TransactionCategory {
  bool get isSystem => DatabaseConstants.isSystemCategoryId(id);

  String localizedName(AppLocalizations l10n) =>
      CategoryLocalization.name(this, l10n);
}
