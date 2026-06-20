import '../entities/report_entities.dart';

/// Pluggable financial insight rule (AI-ready extension point).
abstract class InsightRule {
  List<ReportInsight> evaluate(
    MonthlyReportSnapshot current,
    MonthlyReportSnapshot? previous,
  );
}

/// Runs all registered insight rules.
class InsightRuleEngine {
  InsightRuleEngine(this._rules);

  final List<InsightRule> _rules;

  List<ReportInsight> generate(
    MonthlyReportSnapshot current,
    MonthlyReportSnapshot? previous,
  ) {
    final insights = <ReportInsight>[];
    for (final rule in _rules) {
      insights.addAll(rule.evaluate(current, previous));
    }
    return insights;
  }
}

class LargestSpendingCategoryRule implements InsightRule {
  @override
  List<ReportInsight> evaluate(
    MonthlyReportSnapshot current,
    MonthlyReportSnapshot? previous,
  ) {
    if (current.expenseBreakdown.isEmpty) return [];
    final top = current.expenseBreakdown.first;
    return [
      ReportInsight(
        key: 'reportInsightLargestCategory',
        params: {
          'category': top.categoryName,
          'percent': top.percentOfTotal.toStringAsFixed(0),
        },
      ),
    ];
  }
}

class CategoryMomChangeRule implements InsightRule {
  CategoryMomChangeRule({this.thresholdPercent = 10});

  final double thresholdPercent;

  @override
  List<ReportInsight> evaluate(
    MonthlyReportSnapshot current,
    MonthlyReportSnapshot? previous,
  ) {
    if (previous == null) return [];
    final insights = <ReportInsight>[];
    final prevMap = {
      for (final row in previous.expenseBreakdown) row.categoryId: row.totalBase,
    };

    for (final row in current.expenseBreakdown) {
      final prev = prevMap[row.categoryId] ?? 0;
      if (prev <= 0) continue;
      final change = ((row.totalBase - prev) / prev) * 100;
      if (change.abs() < thresholdPercent) continue;
      insights.add(
        ReportInsight(
          key: change > 0
              ? 'reportInsightCategoryIncrease'
              : 'reportInsightCategoryDecrease',
          params: {
            'category': row.categoryName,
            'percent': change.abs().toStringAsFixed(0),
          },
          severity: change > 0 ? ReportInsightSeverity.warning : ReportInsightSeverity.success,
        ),
      );
    }
    return insights;
  }
}

class SavingsRateRule implements InsightRule {
  @override
  List<ReportInsight> evaluate(
    MonthlyReportSnapshot current,
    MonthlyReportSnapshot? previous,
  ) {
    if (current.totalIncome <= 0) return [];
    return [
      ReportInsight(
        key: 'reportInsightSavingsRate',
        params: {
          'rate': current.savingsRate.toStringAsFixed(0),
        },
        severity: current.savingsRate >= 20
            ? ReportInsightSeverity.success
            : ReportInsightSeverity.info,
      ),
    ];
  }
}

class IncomeTrendRule implements InsightRule {
  @override
  List<ReportInsight> evaluate(
    MonthlyReportSnapshot current,
    MonthlyReportSnapshot? previous,
  ) {
    final change = current.incomeChangePct;
    if (change == null) return [];
    if (change.abs() < 1) {
      return [
        const ReportInsight(key: 'reportInsightIncomeFlat'),
      ];
    }
    return [
      ReportInsight(
        key: change > 0 ? 'reportInsightIncomeUp' : 'reportInsightIncomeDown',
        params: {'percent': change.abs().toStringAsFixed(0)},
        severity: change > 0 ? ReportInsightSeverity.success : ReportInsightSeverity.warning,
      ),
    ];
  }
}

class BudgetPerformanceRule implements InsightRule {
  @override
  List<ReportInsight> evaluate(
    MonthlyReportSnapshot current,
    MonthlyReportSnapshot? previous,
  ) {
    if (current.budgetPerformance.isEmpty) return [];
    final over = current.budgetPerformance.where((b) => b.percentUsed > 100);
    if (over.isEmpty) {
      return [
        const ReportInsight(
          key: 'reportInsightBudgetOnTrack',
          severity: ReportInsightSeverity.success,
        ),
      ];
    }
    final worst = over.first;
    return [
      ReportInsight(
        key: 'reportInsightBudgetOver',
        params: {
          'category': worst.categoryName,
          'percent': worst.percentUsed.toStringAsFixed(0),
        },
        severity: ReportInsightSeverity.warning,
      ),
    ];
  }
}

class SurplusGoalRecommendationRule implements InsightRule {
  @override
  List<ReportInsight> evaluate(
    MonthlyReportSnapshot current,
    MonthlyReportSnapshot? previous,
  ) {
    if (current.availableSurplus <= 0 || current.goalProgress.isEmpty) {
      return [];
    }

    final incomplete = current.goalProgress
        .where((g) => g.progressPercent < 100)
        .toList()
      ..sort((a, b) {
        final aRemaining = a.targetAmount - a.savedAmount;
        final bRemaining = b.targetAmount - b.savedAmount;
        return aRemaining.compareTo(bRemaining);
      });

    if (incomplete.isEmpty) return [];
    final goal = incomplete.first;
    final remaining = goal.targetAmount - goal.savedAmount;
    if (remaining <= 0) return [];

    final monthsSaved = (remaining / current.availableSurplus).ceil();
    if (monthsSaved <= 0 || monthsSaved > 24) return [];

    return [
      ReportInsight(
        key: 'reportInsightSurplusToGoal',
        params: {
          'goal': goal.title,
          'months': monthsSaved.toString(),
        },
      ),
    ];
  }
}

InsightRuleEngine createDefaultInsightEngine() {
  return InsightRuleEngine([
    LargestSpendingCategoryRule(),
    CategoryMomChangeRule(),
    SavingsRateRule(),
    IncomeTrendRule(),
    BudgetPerformanceRule(),
    SurplusGoalRecommendationRule(),
  ]);
}
