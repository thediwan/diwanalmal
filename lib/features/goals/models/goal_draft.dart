/// In-memory goal data passed between add-goal screens before persistence.
class GoalDraft {
  const GoalDraft({
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
    required this.currencyId,
    required this.currencyCode,
    required this.currencySymbol,
    required this.rateToBase,
    required this.targetDate,
    required this.iconStyle,
  });

  final String title;
  final double targetAmount;
  final double savedAmount;
  final String currencyId;
  final String currencyCode;
  final String currencySymbol;
  final double rateToBase;
  final DateTime targetDate;
  final String iconStyle;

  /// Remaining amount the user still needs to save.
  double get remainingAmount =>
      (targetAmount - savedAmount).clamp(0, double.infinity);

  GoalDraft copyWith({
    String? title,
    double? targetAmount,
    double? savedAmount,
    String? currencyId,
    String? currencyCode,
    String? currencySymbol,
    double? rateToBase,
    DateTime? targetDate,
    String? iconStyle,
  }) {
    return GoalDraft(
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      currencyId: currencyId ?? this.currencyId,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      rateToBase: rateToBase ?? this.rateToBase,
      targetDate: targetDate ?? this.targetDate,
      iconStyle: iconStyle ?? this.iconStyle,
    );
  }
}
