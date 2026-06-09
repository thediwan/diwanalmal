import '../models/treasury.dart';

/// Builds wallets screen summary and search filtering for treasuries.
class WalletsDisplayService {
  /// Positive treasury totals in base currency + growth estimate for the month.
  WalletsSummary buildSummary({
    required List<Treasury> treasuries,
    required String baseCode,
    required double monthlyNetChangeInBase,
  }) {
    var positiveTotal = 0.0;

    for (final treasury in treasuries) {
      if (treasury.totalInBase > 0) {
        positiveTotal += treasury.totalInBase;
      }
    }

    final startOfMonth = positiveTotal - monthlyNetChangeInBase;
    final growthPercent = startOfMonth > 0
        ? (monthlyNetChangeInBase / startOfMonth) * 100
        : 0.0;

    return WalletsSummary(
      positiveTotalInBase: positiveTotal,
      baseCode: baseCode,
      walletCount: treasuries.length,
      monthlyGrowthPercent: growthPercent,
    );
  }

  List<Treasury> filterTreasuries(List<Treasury> treasuries, String query) {
    final q = query.trim();
    if (q.isEmpty) return treasuries;

    return treasuries.where((treasury) {
      if (treasury.name.contains(q)) return true;
      if (treasury.subtitle?.contains(q) ?? false) return true;

      return treasury.accounts.any(
        (a) => a.currencyCode.contains(q.toUpperCase()),
      );
    }).toList();
  }
}

/// Summary metrics for the wallets screen header.
class WalletsSummary {
  const WalletsSummary({
    required this.positiveTotalInBase,
    required this.baseCode,
    required this.walletCount,
    required this.monthlyGrowthPercent,
  });

  final double positiveTotalInBase;
  final String baseCode;
  final int walletCount;
  final double monthlyGrowthPercent;
}
