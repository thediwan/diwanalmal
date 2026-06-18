/// A treasury (خزينة) holding one or more currency accounts.
class Treasury {
  const Treasury({
    required this.id,
    required this.name,
    required this.icon,
    required this.createdAt,
    required this.accounts,
    this.subtitle,
    this.iconStyle,
    this.isGoalWallet = false,
  });

  final String id;
  final String name;
  final String icon;
  final DateTime createdAt;
  final String? subtitle;
  final String? iconStyle;
  final List<TreasuryAccountBalance> accounts;
  final bool isGoalWallet;

  double get totalInBase =>
      accounts.fold(0, (sum, a) => sum + a.balanceInBase);

  bool get isNegative => totalInBase < 0;
}

/// Computed balance for one currency inside a treasury.
class TreasuryAccountBalance {
  const TreasuryAccountBalance({
    required this.accountId,
    required this.currencyId,
    required this.currencyCode,
    required this.balance,
    required this.balanceInBase,
    required this.rateToBase,
  });

  final String accountId;
  final String currencyId;
  final String currencyCode;
  final double balance;
  final double balanceInBase;
  final double rateToBase;
}
