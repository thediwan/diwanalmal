/// Opening balance for one currency when creating or updating a treasury.
class OpeningBalanceInput {
  const OpeningBalanceInput({
    required this.currencyCode,
    required this.initialBalance,
    this.accountId,
  });

  final String currencyCode;
  final double initialBalance;

  /// Existing currency account id when updating a treasury.
  final String? accountId;
}
