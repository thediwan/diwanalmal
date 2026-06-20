import '../constants/split_constants.dart';

/// One participant input for split amount calculation.
class SplitParticipantInput {
  const SplitParticipantInput({
    required this.contactId,
    this.percent,
    this.fixedAmount,
  });

  final String contactId;
  final double? percent;
  final double? fixedAmount;
}

/// Computed share for one participant.
class SplitShareResult {
  const SplitShareResult({
    required this.contactId,
    required this.shareAmount,
    this.sharePercent,
  });

  final String contactId;
  final double shareAmount;
  final double? sharePercent;
}

/// Outcome of a split calculation.
class SplitCalculationResult {
  const SplitCalculationResult({
    required this.participantShares,
    required this.userShareAmount,
    required this.totalAmount,
  });

  final List<SplitShareResult> participantShares;
  final double userShareAmount;
  final double totalAmount;

  double get participantsTotal => participantShares.fold(
        0.0,
        (sum, p) => sum + p.shareAmount,
      );
}

/// Pure split math for equal, percent, and fixed-amount modes.
abstract final class SplitCalculator {
  static const double _epsilon = 0.000001;

  /// Computes participant shares and the user's implicit remainder.
  static SplitCalculationResult calculate({
    required double totalAmount,
    required String splitMode,
    required List<SplitParticipantInput> participants,
    bool includeSelfInEqualSplit = true,
    double? fixedAmountPerPerson,
  }) {
    if (totalAmount <= 0) {
      throw ArgumentError('Total amount must be greater than zero');
    }
    if (participants.isEmpty) {
      throw ArgumentError('At least one participant is required');
    }

    switch (splitMode) {
      case SplitConstants.modeEqual:
        return _calculateEqual(
          totalAmount: totalAmount,
          participantCount: participants.length,
          includeSelf: includeSelfInEqualSplit,
          participants: participants,
        );
      case SplitConstants.modePercent:
        return _calculatePercent(
          totalAmount: totalAmount,
          participants: participants,
        );
      case SplitConstants.modeFixedAmount:
        return _calculateFixed(
          totalAmount: totalAmount,
          participants: participants,
          fixedAmountPerPerson: fixedAmountPerPerson,
        );
      default:
        throw ArgumentError('Invalid split mode: $splitMode');
    }
  }

  static SplitCalculationResult _calculateEqual({
    required double totalAmount,
    required int participantCount,
    required bool includeSelf,
    required List<SplitParticipantInput> participants,
  }) {
    final divisor = includeSelf ? participantCount + 1 : participantCount;
    if (divisor <= 0) {
      throw ArgumentError('Invalid equal split divisor');
    }

    final rawShare = totalAmount / divisor;
    final shares = <SplitShareResult>[];
    var assigned = 0.0;

    for (var i = 0; i < participantCount; i++) {
      final isLast = i == participantCount - 1;
      final amount = isLast
          ? _roundMoney(
              totalAmount - assigned - (includeSelf ? rawShare : 0),
            )
          : _roundMoney(rawShare);
      assigned += amount;
      shares.add(
        SplitShareResult(
          contactId: participants[i].contactId,
          shareAmount: amount,
        ),
      );
    }

    final userShare = includeSelf
        ? _roundMoney(totalAmount - assigned)
        : 0.0;

    return SplitCalculationResult(
      participantShares: shares,
      userShareAmount: userShare,
      totalAmount: totalAmount,
    );
  }

  static SplitCalculationResult _calculatePercent({
    required double totalAmount,
    required List<SplitParticipantInput> participants,
  }) {
    var percentSum = 0.0;
    for (final p in participants) {
      final pct = p.percent;
      if (pct == null || pct <= 0) {
        throw ArgumentError('Each participant must have a positive percent');
      }
      percentSum += pct;
    }

    if (percentSum > 100 + _epsilon) {
      throw ArgumentError('Percent total exceeds 100%');
    }

    final shares = <SplitShareResult>[];
    var assigned = 0.0;

    for (var i = 0; i < participants.length; i++) {
      final p = participants[i];
      final isLast = i == participants.length - 1;
      final amount = isLast
          ? _roundMoney(totalAmount - assigned)
          : _roundMoney(totalAmount * (p.percent! / 100));
      assigned += amount;
      shares.add(
        SplitShareResult(
          contactId: p.contactId,
          shareAmount: amount,
          sharePercent: p.percent,
        ),
      );
    }

    final userShare = _roundMoney(totalAmount - assigned);
    if (userShare < -_epsilon) {
      throw ArgumentError('Participant shares exceed total amount');
    }

    return SplitCalculationResult(
      participantShares: shares,
      userShareAmount: userShare < 0 ? 0 : userShare,
      totalAmount: totalAmount,
    );
  }

  static SplitCalculationResult _calculateFixed({
    required double totalAmount,
    required List<SplitParticipantInput> participants,
    required double? fixedAmountPerPerson,
  }) {
    final fixed = fixedAmountPerPerson ??
        participants.first.fixedAmount ??
        participants.firstOrNull?.fixedAmount;

    if (fixed == null || fixed <= 0) {
      throw ArgumentError('Fixed amount per person must be greater than zero');
    }

    final shares = <SplitShareResult>[];
    var assigned = 0.0;

    for (var i = 0; i < participants.length; i++) {
      final amount = _roundMoney(fixed);
      if (assigned + amount > totalAmount + _epsilon) {
        throw ArgumentError('Fixed shares exceed total amount');
      }
      assigned += amount;
      shares.add(
        SplitShareResult(
          contactId: participants[i].contactId,
          shareAmount: amount,
        ),
      );
    }

    final userShare = _roundMoney(totalAmount - assigned);
    if (userShare < -_epsilon) {
      throw ArgumentError('Fixed shares exceed total amount');
    }

    return SplitCalculationResult(
      participantShares: shares,
      userShareAmount: userShare < 0 ? 0 : userShare,
      totalAmount: totalAmount,
    );
  }

  static double _roundMoney(double value) {
    return (value * 100).roundToDouble() / 100;
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
