/// Status of a monthly financial report.
enum MonthlyReportStatus {
  draft,
  finalized;

  static MonthlyReportStatus fromDb(String value) =>
      value == 'finalized' ? finalized : draft;

  String toDb() => this == finalized ? 'finalized' : 'draft';
}

/// How surplus was handled at month close.
enum SurplusAction {
  pending,
  carryForward,
  allocateGoal,
  partial;

  static SurplusAction fromDb(String? value) {
    return switch (value) {
      'carry_forward' => carryForward,
      'allocate_goal' => allocateGoal,
      'partial' => partial,
      _ => pending,
    };
  }

  String toDb() => switch (this) {
        carryForward => 'carry_forward',
        allocateGoal => 'allocate_goal',
        partial => 'partial',
        pending => 'pending',
      };
}

/// Category spending or income breakdown row.
class CategoryBreakdown {
  const CategoryBreakdown({
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

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'categoryName': categoryName,
        'iconKey': iconKey,
        'colorHex': colorHex,
        'totalBase': totalBase,
        'percentOfTotal': percentOfTotal,
      };

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      iconKey: json['iconKey'] as String?,
      colorHex: json['colorHex'] as String?,
      totalBase: (json['totalBase'] as num).toDouble(),
      percentOfTotal: (json['percentOfTotal'] as num).toDouble(),
    );
  }
}

/// Budget vs actual performance row in a report snapshot.
class BudgetPerformanceRow {
  const BudgetPerformanceRow({
    required this.categoryId,
    required this.categoryName,
    required this.budgetAmount,
    required this.actualBase,
    required this.percentUsed,
    required this.remaining,
    this.iconKey,
    this.colorHex,
  });

  final String categoryId;
  final String categoryName;
  final double budgetAmount;
  final double actualBase;
  final double percentUsed;
  final double remaining;
  final String? iconKey;
  final String? colorHex;

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'categoryName': categoryName,
        'budgetAmount': budgetAmount,
        'actualBase': actualBase,
        'percentUsed': percentUsed,
        'remaining': remaining,
        'iconKey': iconKey,
        'colorHex': colorHex,
      };

  factory BudgetPerformanceRow.fromJson(Map<String, dynamic> json) {
    return BudgetPerformanceRow(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      budgetAmount: (json['budgetAmount'] as num).toDouble(),
      actualBase: (json['actualBase'] as num).toDouble(),
      percentUsed: (json['percentUsed'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      iconKey: json['iconKey'] as String?,
      colorHex: json['colorHex'] as String?,
    );
  }
}

/// Goal progress captured in a report snapshot.
class GoalProgressSnapshot {
  const GoalProgressSnapshot({
    required this.goalId,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.progressPercent,
    this.iconKey,
  });

  final String goalId;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final int progressPercent;
  final String? iconKey;

  Map<String, dynamic> toJson() => {
        'goalId': goalId,
        'title': title,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'progressPercent': progressPercent,
        'iconKey': iconKey,
      };

  factory GoalProgressSnapshot.fromJson(Map<String, dynamic> json) {
    return GoalProgressSnapshot(
      goalId: json['goalId'] as String,
      title: json['title'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      savedAmount: (json['savedAmount'] as num).toDouble(),
      progressPercent: (json['progressPercent'] as num).toInt(),
      iconKey: json['iconKey'] as String?,
    );
  }
}

/// One month in a trend series.
class MonthlyTrendPointEntity {
  const MonthlyTrendPointEntity({
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

  Map<String, dynamic> toJson() => {
        'year': year,
        'month': month,
        'income': income,
        'expense': expense,
        'goalSavings': goalSavings,
        'surplus': surplus,
      };

  factory MonthlyTrendPointEntity.fromJson(Map<String, dynamic> json) {
    return MonthlyTrendPointEntity(
      year: json['year'] as int,
      month: json['month'] as int,
      income: (json['income'] as num).toDouble(),
      expense: (json['expense'] as num).toDouble(),
      goalSavings: (json['goalSavings'] as num).toDouble(),
      surplus: (json['surplus'] as num).toDouble(),
    );
  }
}

/// Localized insight stored as key + params.
class ReportInsight {
  const ReportInsight({
    required this.key,
    this.params = const {},
    this.severity = ReportInsightSeverity.info,
  });

  final String key;
  final Map<String, String> params;
  final ReportInsightSeverity severity;

  Map<String, dynamic> toJson() => {
        'key': key,
        'params': params,
        'severity': severity.name,
      };

  factory ReportInsight.fromJson(Map<String, dynamic> json) {
    return ReportInsight(
      key: json['key'] as String,
      params: (json['params'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          ) ??
          const {},
      severity: ReportInsightSeverity.values.firstWhere(
        (s) => s.name == json['severity'],
        orElse: () => ReportInsightSeverity.info,
      ),
    );
  }
}

enum ReportInsightSeverity { info, warning, success }

/// Full monthly report view model (KPIs + nested snapshot data).
class MonthlyReportSnapshot {
  const MonthlyReportSnapshot({
    required this.id,
    required this.year,
    required this.month,
    required this.status,
    required this.baseCurrencyCode,
    required this.totalIncome,
    required this.totalExpense,
    required this.surplus,
    required this.totalGoalSavings,
    required this.savingsRate,
    required this.previousCarryoverIn,
    required this.availableSurplus,
    this.incomeChangePct,
    this.expenseChangePct,
    this.savingsChangePct,
    required this.surplusAction,
    this.allocatedAmount,
    this.goalId,
    this.carriedForwardAmount,
    required this.generatedAt,
    this.finalizedAt,
    this.expenseBreakdown = const [],
    this.incomeBreakdown = const [],
    this.budgetPerformance = const [],
    this.goalProgress = const [],
    this.trendPoints = const [],
    this.insights = const [],
  });

  final String id;
  final int year;
  final int month;
  final MonthlyReportStatus status;
  final String baseCurrencyCode;
  final double totalIncome;
  final double totalExpense;
  final double surplus;
  final double totalGoalSavings;
  final double savingsRate;
  final double previousCarryoverIn;
  final double availableSurplus;
  final double? incomeChangePct;
  final double? expenseChangePct;
  final double? savingsChangePct;
  final SurplusAction surplusAction;
  final double? allocatedAmount;
  final String? goalId;
  final double? carriedForwardAmount;
  final DateTime generatedAt;
  final DateTime? finalizedAt;
  final List<CategoryBreakdown> expenseBreakdown;
  final List<CategoryBreakdown> incomeBreakdown;
  final List<BudgetPerformanceRow> budgetPerformance;
  final List<GoalProgressSnapshot> goalProgress;
  final List<MonthlyTrendPointEntity> trendPoints;
  final List<ReportInsight> insights;

  bool get hasPendingSurplus =>
      status == MonthlyReportStatus.draft &&
      availableSurplus > 0.000001 &&
      surplusAction == SurplusAction.pending;

  MonthlyReportSnapshot copyWith({
    MonthlyReportStatus? status,
    SurplusAction? surplusAction,
    double? allocatedAmount,
    String? goalId,
    double? carriedForwardAmount,
    DateTime? finalizedAt,
  }) {
    return MonthlyReportSnapshot(
      id: id,
      year: year,
      month: month,
      status: status ?? this.status,
      baseCurrencyCode: baseCurrencyCode,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      surplus: surplus,
      totalGoalSavings: totalGoalSavings,
      savingsRate: savingsRate,
      previousCarryoverIn: previousCarryoverIn,
      availableSurplus: availableSurplus,
      incomeChangePct: incomeChangePct,
      expenseChangePct: expenseChangePct,
      savingsChangePct: savingsChangePct,
      surplusAction: surplusAction ?? this.surplusAction,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      goalId: goalId ?? this.goalId,
      carriedForwardAmount: carriedForwardAmount ?? this.carriedForwardAmount,
      generatedAt: generatedAt,
      finalizedAt: finalizedAt ?? this.finalizedAt,
      expenseBreakdown: expenseBreakdown,
      incomeBreakdown: incomeBreakdown,
      budgetPerformance: budgetPerformance,
      goalProgress: goalProgress,
      trendPoints: trendPoints,
      insights: insights,
    );
  }
}

/// Serializable nested snapshot payload stored in [MonthlyReportRow.snapshotJson].
class ReportSnapshotPayload {
  const ReportSnapshotPayload({
    this.expenseBreakdown = const [],
    this.incomeBreakdown = const [],
    this.budgetPerformance = const [],
    this.goalProgress = const [],
    this.trendPoints = const [],
    this.insights = const [],
  });

  final List<CategoryBreakdown> expenseBreakdown;
  final List<CategoryBreakdown> incomeBreakdown;
  final List<BudgetPerformanceRow> budgetPerformance;
  final List<GoalProgressSnapshot> goalProgress;
  final List<MonthlyTrendPointEntity> trendPoints;
  final List<ReportInsight> insights;

  Map<String, dynamic> toJson() => {
        'expenseBreakdown':
            expenseBreakdown.map((e) => e.toJson()).toList(),
        'incomeBreakdown': incomeBreakdown.map((e) => e.toJson()).toList(),
        'budgetPerformance':
            budgetPerformance.map((e) => e.toJson()).toList(),
        'goalProgress': goalProgress.map((e) => e.toJson()).toList(),
        'trendPoints': trendPoints.map((e) => e.toJson()).toList(),
        'insights': insights.map((e) => e.toJson()).toList(),
      };

  factory ReportSnapshotPayload.fromJson(Map<String, dynamic> json) {
    List<T> mapList<T>(
      String key,
      T Function(Map<String, dynamic>) fromJson,
    ) {
      final raw = json[key] as List<dynamic>? ?? const [];
      return raw
          .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return ReportSnapshotPayload(
      expenseBreakdown: mapList('expenseBreakdown', CategoryBreakdown.fromJson),
      incomeBreakdown: mapList('incomeBreakdown', CategoryBreakdown.fromJson),
      budgetPerformance:
          mapList('budgetPerformance', BudgetPerformanceRow.fromJson),
      goalProgress: mapList('goalProgress', GoalProgressSnapshot.fromJson),
      trendPoints:
          mapList('trendPoints', MonthlyTrendPointEntity.fromJson),
      insights: mapList('insights', ReportInsight.fromJson),
    );
  }
}
