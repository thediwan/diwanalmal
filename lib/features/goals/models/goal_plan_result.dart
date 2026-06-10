/// Calculated savings plan for a goal draft (not persisted until accepted).
class GoalPlanResult {
  const GoalPlanResult({
    required this.monthlyRequired,
    required this.monthsUntilTarget,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.netIncome,
    required this.isLargeAmountWarning,
    required this.isUnrealisticDateWarning,
    required this.alternatives,
  });

  /// Required monthly savings in the goal currency.
  final double monthlyRequired;
  final int monthsUntilTarget;
  final double monthlyIncome;
  final double monthlyExpense;
  final double netIncome;
  final bool isLargeAmountWarning;
  final bool isUnrealisticDateWarning;
  final List<GoalPlanAlternative> alternatives;
}

/// One savings scenario for comparison.
class GoalPlanAlternative {
  const GoalPlanAlternative({
    required this.key,
    required this.monthlyAmount,
    required this.targetDate,
    required this.isRecommended,
  });

  final String key;
  final double monthlyAmount;
  final DateTime targetDate;
  final bool isRecommended;
}
