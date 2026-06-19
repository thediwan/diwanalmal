import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Visual icon styles for treasuries (matches wallets screen mockup).
abstract final class TreasuryIconStyles {
  static const String cash = 'cash';
  static const String bank = 'bank';
  static const String crypto = 'crypto';
  static const String travel = 'travel';

  static const List<String> selectable = [cash, bank, crypto, travel];

  static String legacyEmoji(String? style) {
    return switch (style) {
      cash => '💵',
      bank => '🏦',
      crypto => '₿',
      travel => '✈️',
      _ => '💰',
    };
  }
}

/// Resolved colors and icon for one treasury style.
class TreasuryIconSpec {
  const TreasuryIconSpec({
    required this.background,
    required this.foreground,
    required this.icon,
    required this.radius,
  });

  final Color background;
  final Color foreground;
  final IconData icon;
  final double radius;
}

TreasuryIconSpec treasuryIconSpecFor(String? style) {
  return switch (style) {
    TreasuryIconStyles.bank => const TreasuryIconSpec(
        background: Color(0xFFDCFCE7),
        foreground: Color(0xFF15803D),
        icon: Icons.account_balance_rounded,
        radius: 14,
      ),
    TreasuryIconStyles.crypto => const TreasuryIconSpec(
        background: Color(0xFFFEE2E2),
        foreground: Color(0xFFB91C1C),
        icon: Icons.currency_bitcoin_rounded,
        radius: 14,
      ),
    TreasuryIconStyles.travel => const TreasuryIconSpec(
        background: Color(0xFFFFEDD5),
        foreground: Color(0xFFC2410C),
        icon: Icons.flight_rounded,
        radius: 14,
      ),
    TreasuryIconStyles.cash => const TreasuryIconSpec(
        background: AppColors.primary,
        foreground: Colors.white,
        icon: Icons.account_balance_wallet_rounded,
        radius: 14,
      ),
    _ => const TreasuryIconSpec(
        background: Color(0xFFDBEAFE),
        foreground: AppColors.primary,
        icon: Icons.account_balance_wallet_rounded,
        radius: 14,
      ),
  };
}
