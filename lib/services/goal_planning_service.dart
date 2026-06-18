import '../features/goals/models/goal_draft.dart';
import '../features/goals/models/goal_plan_result.dart';
import 'lazarus_database_service.dart';

/// Computes monthly savings plans from goal drafts and user finances.
class GoalPlanningService {
  GoalPlanningService(this._lazarus);

  final LazarusDatabaseService _lazarus;

  static const _largeAmountIncomeRatio = 0.5;
  static const _comfortableNetRatio = 0.3;
  static const _extendedNetRatio = 0.5;

  /// Builds a savings plan for [draft] using transaction or salary data.
  Future<GoalPlanResult> buildPlan(GoalDraft draft) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) {
      return _emptyPlan(draft);
    }

    final dao = _lazarus.database.financeDao;
    final now = DateTime.now();
    final months = _monthsUntil(now, draft.targetDate);
    final remaining = draft.remainingAmount;
    final monthlyRequired =
        months <= 0 ? remaining : remaining / months;

    final hasTransactions = await dao.hasAnyTransactions(userId);
    double incomeBase = await dao.sumMonthlyIncomeBase(
      userId: userId,
      year: now.year,
      month: now.month,
    );
    final expenseBase = await dao.sumMonthlyExpenseBase(
      userId: userId,
      year: now.year,
      month: now.month,
    );

    if (incomeBase <= 0) {
      incomeBase = await dao.averageSalaryIncomeBase(userId);
    }

    if (!hasTransactions && incomeBase <= 0) {
      incomeBase = await dao.averageSalaryIncomeBase(userId);
    }

    final income = _fromBase(incomeBase, draft.rateToBase);
    final expense = _fromBase(expenseBase, draft.rateToBase);
    final netIncome = (income - expense).clamp(0.0, double.infinity).toDouble();

    final isLargeAmountWarning = income > 0 &&
        monthlyRequired > income * _largeAmountIncomeRatio;
    final isUnrealisticDateWarning =
        netIncome > 0 && monthlyRequired > netIncome;

    final alternatives = _buildAlternatives(
      draft: draft,
      monthlyRequired: monthlyRequired,
      netIncome: netIncome,
      months: months,
      now: now,
    );

    return GoalPlanResult(
      monthlyRequired: monthlyRequired,
      monthsUntilTarget: months,
      monthlyIncome: income,
      monthlyExpense: expense,
      netIncome: netIncome,
      isLargeAmountWarning: isLargeAmountWarning,
      isUnrealisticDateWarning: isUnrealisticDateWarning,
      alternatives: alternatives,
    );
  }

  List<GoalPlanAlternative> _buildAlternatives({
    required GoalDraft draft,
    required double monthlyRequired,
    required double netIncome,
    required int months,
    required DateTime now,
  }) {
    final remaining = draft.remainingAmount;
    final targetPlan = GoalPlanAlternative(
      key: 'target_date',
      monthlyAmount: monthlyRequired,
      targetDate: draft.targetDate,
      isRecommended: true,
    );

    if (netIncome <= 0) {
      return [targetPlan];
    }

    final comfortableMonthly = netIncome * _comfortableNetRatio;
    final comfortableDate = _dateForMonthly(
      start: now,
      remaining: remaining,
      monthly: comfortableMonthly,
    );

    final extendedMonthly = netIncome * _extendedNetRatio;
    final extendedDate = _dateForMonthly(
      start: now,
      remaining: remaining,
      monthly: extendedMonthly,
    );

    return [
      targetPlan,
      GoalPlanAlternative(
        key: 'comfortable',
        monthlyAmount: comfortableMonthly,
        targetDate: comfortableDate,
        isRecommended: false,
      ),
      GoalPlanAlternative(
        key: 'extended',
        monthlyAmount: extendedMonthly,
        targetDate: extendedDate,
        isRecommended: false,
      ),
    ];
  }

  GoalPlanResult _emptyPlan(GoalDraft draft) {
    final months = _monthsUntil(DateTime.now(), draft.targetDate);
    final monthlyRequired = months <= 0
        ? draft.remainingAmount
        : draft.remainingAmount / months;

    return GoalPlanResult(
      monthlyRequired: monthlyRequired,
      monthsUntilTarget: months,
      monthlyIncome: 0,
      monthlyExpense: 0,
      netIncome: 0,
      isLargeAmountWarning: false,
      isUnrealisticDateWarning: false,
      alternatives: [
        GoalPlanAlternative(
          key: 'target_date',
          monthlyAmount: monthlyRequired,
          targetDate: draft.targetDate,
          isRecommended: true,
        ),
      ],
    );
  }

  int _monthsUntil(DateTime from, DateTime to) {
    if (!to.isAfter(from)) return 0;
    var months = (to.year - from.year) * 12 + (to.month - from.month);
    if (to.day < from.day) months -= 1;
    return months.clamp(1, 600).toInt();
  }

  DateTime _dateForMonthly({
    required DateTime start,
    required double remaining,
    required double monthly,
  }) {
    if (monthly <= 0) return start;
    final monthsNeeded = (remaining / monthly).ceil().clamp(1, 600);
    return DateTime(start.year, start.month + monthsNeeded, start.day);
  }

  double _fromBase(double baseAmount, double rateToBase) {
    if (rateToBase == 0) return 0;
    return baseAmount / rateToBase;
  }

  /// Monthly savings still required to reach [targetDate].
  static double monthlyRequiredFor({
    required double targetAmount,
    required double savedAmount,
    required DateTime targetDate,
  }) {
    final now = DateTime.now();
    var months = (targetDate.year - now.year) * 12 + (targetDate.month - now.month);
    if (targetDate.day < now.day) months -= 1;
    months = months.clamp(1, 600);
    final remaining = (targetAmount - savedAmount).clamp(0, double.infinity);
    if (!targetDate.isAfter(now)) return remaining.toDouble();
    return remaining / months;
  }
}
