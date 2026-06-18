import '../../models/treasury.dart';

/// Treasury lists for transaction pickers (excludes goal savings wallets).
List<Treasury> regularTreasuries(Iterable<Treasury> treasuries) {
  return treasuries.where((t) => !t.isGoalWallet).toList();
}

/// Regular treasuries for [currencyId], optionally keeping [selectedWalletId].
List<Treasury> regularTreasuriesForCurrency({
  required Iterable<Treasury> treasuries,
  required String currencyCode,
  String? selectedWalletId,
}) {
  final normalized = currencyCode.toUpperCase();
  final matchesCurrency = treasuries.where(
    (treasury) => treasury.accounts.any(
      (a) => a.currencyCode.toUpperCase() == normalized,
    ),
  );

  final regular = regularTreasuries(matchesCurrency);
  if (selectedWalletId == null) return regular;

  final selected = matchesCurrency
      .where((t) => t.id == selectedWalletId)
      .firstOrNull;
  if (selected == null || regular.any((t) => t.id == selectedWalletId)) {
    return regular;
  }
  return [selected, ...regular];
}

/// Regular treasuries with a positive balance in [currencyCode].
List<Treasury> regularTreasuriesWithBalanceForCurrency({
  required Iterable<Treasury> treasuries,
  required String currencyCode,
  String? selectedWalletId,
}) {
  final normalized = currencyCode.toUpperCase();
  final withBalance = regularTreasuriesForCurrency(
    treasuries: treasuries,
    currencyCode: currencyCode,
    selectedWalletId: selectedWalletId,
  ).where((treasury) {
    final account = treasury.accounts
        .where((a) => a.currencyCode.toUpperCase() == normalized)
        .firstOrNull;
    return account != null && account.balance > 0.000001;
  }).toList();

  if (selectedWalletId == null) return withBalance;

  final alreadyListed =
      withBalance.any((treasury) => treasury.id == selectedWalletId);
  if (alreadyListed) return withBalance;

  final selected = regularTreasuriesForCurrency(
    treasuries: treasuries,
    currencyCode: currencyCode,
  ).where((t) => t.id == selectedWalletId).firstOrNull;
  if (selected == null) return withBalance;

  return [selected, ...withBalance];
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
