import '../../../../core/helpers/uuid_helper.dart';
import '../../../../database/daos/finance_dao.dart';
import '../../../../database/lazarus_database.dart';
import '../../domain/entities/report_entities.dart';
import '../../domain/insights/insight_rules.dart';
import '../../domain/repositories/monthly_report_repository.dart';
import '../mappers/monthly_report_mapper.dart';

/// Drift-backed monthly report repository.
class MonthlyReportRepositoryImpl implements MonthlyReportRepository {
  MonthlyReportRepositoryImpl({
    required LazarusDatabase database,
    required Future<String?> Function() resolveActiveUserId,
    required InsightRuleEngine insightEngine,
  })  : _database = database,
        _resolveActiveUserId = resolveActiveUserId,
        _insightEngine = insightEngine;

  final LazarusDatabase _database;
  final Future<String?> Function() _resolveActiveUserId;
  final InsightRuleEngine _insightEngine;

  FinanceDao get _dao => _database.financeDao;

  @override
  Future<MonthlyReportSnapshot?> getReport({
    required int year,
    required int month,
  }) async {
    final userId = await _resolveActiveUserId();
    if (userId == null) return null;

    final row = await _dao.getMonthlyReport(
      userId: userId,
      year: year,
      month: month,
    );
    return row == null ? null : MonthlyReportMapper.fromRow(row);
  }

  @override
  Future<List<MonthlyReportSnapshot>> listReports() async {
    final userId = await _resolveActiveUserId();
    if (userId == null) return [];

    final rows = await _dao.listMonthlyReports(userId);
    return rows.map(MonthlyReportMapper.fromRow).toList();
  }

  @override
  Future<MonthlyReportSnapshot?> getPreviousReport({
    required int year,
    required int month,
  }) async {
    final userId = await _resolveActiveUserId();
    if (userId == null) return null;

    final row = await _dao.getPreviousFinalizedReport(
      userId: userId,
      year: year,
      month: month,
    );
    return row == null ? null : MonthlyReportMapper.fromRow(row);
  }

  @override
  Future<MonthlyReportSnapshot> generateReport({
    required int year,
    required int month,
  }) async {
    final userId = await _requireUserId();
    final baseCode = await _resolveBaseCurrencyCode(userId);
    final previousCarryover =
        await _dao.getPreviousCarryoverIn(userId: userId, year: year, month: month);

    final income = await _dao.sumMonthlyIncomeBase(
      userId: userId,
      year: year,
      month: month,
    );
    final expense = await _dao.sumMonthlyExpenseBase(
      userId: userId,
      year: year,
      month: month,
    );
    final goalSavings = await _dao.sumGoalDepositsBase(
      userId: userId,
      year: year,
      month: month,
    );

    final surplus = income - expense;
    final availableSurplus = surplus + previousCarryover;
    final savingsRate =
        income <= 0 ? 0.0 : (goalSavings / income) * 100.0;

    final expenseBreakdown = (await _dao.sumExpensesByCategory(
      userId: userId,
      year: year,
      month: month,
    ))
        .map(
          (row) => CategoryBreakdown(
            categoryId: row.categoryId,
            categoryName: row.categoryName,
            iconKey: row.iconKey,
            colorHex: row.colorHex,
            totalBase: row.totalBase,
            percentOfTotal: row.percentOfTotal,
          ),
        )
        .toList();

    final incomeBreakdown = (await _dao.sumIncomeByCategory(
      userId: userId,
      year: year,
      month: month,
    ))
        .map(
          (row) => CategoryBreakdown(
            categoryId: row.categoryId,
            categoryName: row.categoryName,
            iconKey: row.iconKey,
            colorHex: row.colorHex,
            totalBase: row.totalBase,
            percentOfTotal: row.percentOfTotal,
          ),
        )
        .toList();

    final budgetRows = await _dao.getBudgetsWithActuals(
      userId: userId,
      year: year,
      month: month,
    );
    final budgetPerformance = budgetRows
        .map(
          (row) => BudgetPerformanceRow(
            categoryId: row.budget.categoryId,
            categoryName: row.categoryName,
            budgetAmount: row.budget.amount,
            actualBase: row.actualBase,
            percentUsed: row.percentUsed,
            remaining: row.remaining,
            iconKey: row.categoryIconKey,
            colorHex: row.categoryColorHex,
          ),
        )
        .toList();

    await _dao.syncAllGoalSavedAmounts(userId);
    final goals = await _dao.getGoals(userId);
    final goalProgress = goals
        .map(
          (g) => GoalProgressSnapshot(
            goalId: g.id,
            title: g.title,
            targetAmount: g.targetAmount,
            savedAmount: g.savedAmount,
            progressPercent: g.targetAmount <= 0
                ? 0
                : ((g.savedAmount / g.targetAmount) * 100)
                    .round()
                    .clamp(0, 100),
            iconKey: g.icon,
          ),
        )
        .toList();

    final trendDao = await _dao.getMonthlyTrend(
      userId: userId,
      monthsBack: 6,
    );
    final trendPoints = trendDao
        .map(
          (p) => MonthlyTrendPointEntity(
            year: p.year,
            month: p.month,
            income: p.income,
            expense: p.expense,
            goalSavings: p.goalSavings,
            surplus: p.surplus,
          ),
        )
        .toList();

    final prevMonth = DateTime(year, month - 1);
    final prevIncome = await _dao.sumMonthlyIncomeBase(
      userId: userId,
      year: prevMonth.year,
      month: prevMonth.month,
    );
    final prevExpense = await _dao.sumMonthlyExpenseBase(
      userId: userId,
      year: prevMonth.year,
      month: prevMonth.month,
    );
    final prevSavings = await _dao.sumGoalDepositsBase(
      userId: userId,
      year: prevMonth.year,
      month: prevMonth.month,
    );

    final existing = await _dao.getMonthlyReport(
      userId: userId,
      year: year,
      month: month,
    );

    final now = DateTime.now();
    final draft = MonthlyReportSnapshot(
      id: existing?.id ?? UuidHelper.generate(),
      year: year,
      month: month,
      status: existing == null
          ? MonthlyReportStatus.draft
          : MonthlyReportStatus.fromDb(existing.status),
      baseCurrencyCode: baseCode,
      totalIncome: income,
      totalExpense: expense,
      surplus: surplus,
      totalGoalSavings: goalSavings,
      savingsRate: savingsRate,
      previousCarryoverIn: previousCarryover,
      availableSurplus: availableSurplus,
      incomeChangePct: MonthlyReportMapper.percentChange(income, prevIncome),
      expenseChangePct: MonthlyReportMapper.percentChange(expense, prevExpense),
      savingsChangePct: MonthlyReportMapper.percentChange(goalSavings, prevSavings),
      surplusAction: existing?.surplusAction == null
          ? SurplusAction.pending
          : SurplusAction.fromDb(existing!.surplusAction),
      allocatedAmount: existing?.allocatedAmount,
      goalId: existing?.goalId,
      carriedForwardAmount: existing?.carriedForwardAmount,
      generatedAt: existing?.generatedAt ?? now,
      finalizedAt: existing?.finalizedAt,
      expenseBreakdown: expenseBreakdown,
      incomeBreakdown: incomeBreakdown,
      budgetPerformance: budgetPerformance,
      goalProgress: goalProgress,
      trendPoints: trendPoints,
    );

    final previousReport = await getPreviousReport(year: year, month: month);
    final insights = _insightEngine.generate(draft, previousReport);
    final withInsights = MonthlyReportSnapshot(
      id: draft.id,
      year: draft.year,
      month: draft.month,
      status: draft.status,
      baseCurrencyCode: draft.baseCurrencyCode,
      totalIncome: draft.totalIncome,
      totalExpense: draft.totalExpense,
      surplus: draft.surplus,
      totalGoalSavings: draft.totalGoalSavings,
      savingsRate: draft.savingsRate,
      previousCarryoverIn: draft.previousCarryoverIn,
      availableSurplus: draft.availableSurplus,
      incomeChangePct: draft.incomeChangePct,
      expenseChangePct: draft.expenseChangePct,
      savingsChangePct: draft.savingsChangePct,
      surplusAction: draft.surplusAction,
      allocatedAmount: draft.allocatedAmount,
      goalId: draft.goalId,
      carriedForwardAmount: draft.carriedForwardAmount,
      generatedAt: draft.generatedAt,
      finalizedAt: draft.finalizedAt,
      expenseBreakdown: draft.expenseBreakdown,
      incomeBreakdown: draft.incomeBreakdown,
      budgetPerformance: draft.budgetPerformance,
      goalProgress: draft.goalProgress,
      trendPoints: draft.trendPoints,
      insights: insights,
    );

    await _dao.upsertMonthlyReport(
      MonthlyReportMapper.toCompanionWithUser(
        snapshot: withInsights,
        userId: userId,
        createdAt: existing?.createdAt,
      ),
    );

    return withInsights;
  }

  @override
  Future<MonthlyReportSnapshot> carrySurplusForward({
    required int year,
    required int month,
    double? amount,
  }) async {
    final report = await getReport(year: year, month: month) ??
        await generateReport(year: year, month: month);

    final carryAmount = amount ?? report.availableSurplus;
    if (carryAmount <= 0) throw StateError('no_surplus_to_carry');

    final finalized = report.copyWith(
      status: MonthlyReportStatus.finalized,
      surplusAction: SurplusAction.carryForward,
      carriedForwardAmount: carryAmount,
      finalizedAt: DateTime.now(),
    );

    await _persist(finalized);
    return finalized;
  }

  @override
  Future<MonthlyReportSnapshot> recordSurplusAllocation({
    required int year,
    required int month,
    required double allocatedAmount,
    required String goalId,
    required SurplusAction action,
  }) async {
    final report = await getReport(year: year, month: month) ??
        await generateReport(year: year, month: month);

    final updated = report.copyWith(
      status: MonthlyReportStatus.finalized,
      surplusAction: action,
      allocatedAmount: allocatedAmount,
      goalId: goalId,
      carriedForwardAmount: report.availableSurplus - allocatedAmount,
      finalizedAt: DateTime.now(),
    );

    await _persist(updated);
    return updated;
  }

  Future<void> _persist(MonthlyReportSnapshot snapshot) async {
    final userId = await _requireUserId();
    await _dao.upsertMonthlyReport(
      MonthlyReportMapper.toCompanionWithUser(
        snapshot: snapshot,
        userId: userId,
      ),
    );
  }

  Future<String> _requireUserId() async {
    final userId = await _resolveActiveUserId();
    if (userId == null) throw StateError('no_active_user');
    return userId;
  }

  Future<String> _resolveBaseCurrencyCode(String userId) async {
    final settings = await (_database.select(_database.userSettings)
          ..where((s) => s.userId.equals(userId))
          ..limit(1))
        .getSingleOrNull();
    if (settings == null) return 'USD';

    final currency = await (_database.select(_database.currencies)
          ..where((c) => c.id.equals(settings.baseCurrencyId))
          ..limit(1))
        .getSingleOrNull();
    return currency?.code ?? 'USD';
  }
}
