import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/report_entities.dart';

/// Renders stored insight keys into localized UI strings.
abstract final class ReportInsightLocalization {
  static String text(AppLocalizations l10n, ReportInsight insight) {
    final p = insight.params;
    return switch (insight.key) {
      'reportInsightLargestCategory' => l10n.reportInsightLargestCategory(
          p['category'] ?? '',
          p['percent'] ?? '',
        ),
      'reportInsightCategoryIncrease' => l10n.reportInsightCategoryIncrease(
          p['category'] ?? '',
          p['percent'] ?? '',
        ),
      'reportInsightCategoryDecrease' => l10n.reportInsightCategoryDecrease(
          p['category'] ?? '',
          p['percent'] ?? '',
        ),
      'reportInsightSavingsRate' =>
        l10n.reportInsightSavingsRate(p['rate'] ?? ''),
      'reportInsightIncomeUp' =>
        l10n.reportInsightIncomeUp(p['percent'] ?? ''),
      'reportInsightIncomeDown' =>
        l10n.reportInsightIncomeDown(p['percent'] ?? ''),
      'reportInsightIncomeFlat' => l10n.reportInsightIncomeFlat,
      'reportInsightBudgetOnTrack' => l10n.reportInsightBudgetOnTrack,
      'reportInsightBudgetOver' => l10n.reportInsightBudgetOver(
          p['category'] ?? '',
          p['percent'] ?? '',
        ),
      'reportInsightSurplusToGoal' => l10n.reportInsightSurplusToGoal(
          p['goal'] ?? '',
          p['months'] ?? '',
        ),
      _ => insight.key,
    };
  }
}
