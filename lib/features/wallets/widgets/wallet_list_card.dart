import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/helpers/currency_formatter.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/treasury.dart';
import 'treasury_icon.dart';

/// Single grouped card containing all treasury rows (matches client mockup).
class WalletsGroupedCard extends StatelessWidget {
  const WalletsGroupedCard({
    super.key,
    required this.treasuries,
    this.onEdit,
  });

  final List<Treasury> treasuries;
  final ValueChanged<String>? onEdit;

  @override
  Widget build(BuildContext context) {
    if (treasuries.isEmpty) return const SizedBox.shrink();

    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < treasuries.length; i++) ...[
            WalletListItem(
              treasury: treasuries[i],
              onEdit: onEdit,
            ),
            if (i < treasuries.length - 1) const _DashedDivider(),
          ],
        ],
      ),
    );
  }
}

/// One treasury row inside the grouped wallets card.
class WalletListItem extends StatelessWidget {
  const WalletListItem({
    super.key,
    required this.treasury,
    this.onEdit,
  });

  final Treasury treasury;
  final ValueChanged<String>? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final isNegative = treasury.isNegative;
    final amountText = _formatUsdAmount(treasury.totalInBase.abs(), isNegative);
    final valueLabel =
        isNegative ? l10n.walletsRemainingDebt : l10n.walletsTotalValue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TreasuryIcon(style: treasury.iconStyle),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            treasury.name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (onEdit != null) ...[
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => onEdit!(treasury.id),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: AppColors.dashboardPrimary,
                                semanticLabel: l10n.walletsEditWallet,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (treasury.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        treasury.subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountText,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isNegative
                          ? AppColors.expense
                          : AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valueLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (treasury.accounts.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                for (final account in treasury.accounts)
                  Text(
                    _formatAccountAmount(account, isNegative),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: account.balance < 0 || isNegative
                          ? AppColors.expense
                          : colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatUsdAmount(double amount, bool negative) {
    final formatted = CurrencyFormatter.formatAmountOnly(amount);
    final prefix = negative ? r'-$' : r'$';
    return '$prefix$formatted';
  }

  String _formatAccountAmount(
    TreasuryAccountBalance account,
    bool treasuryNegative,
  ) {
    final formatted =
        CurrencyFormatter.formatAmountOnly(account.balance.abs());
    if (account.currencyCode == 'USD') {
      final prefix = account.balance < 0 || treasuryNegative ? r'-$' : r'$';
      return '$prefix$formatted USD';
    }
    return CurrencyFormatter.formatWithCode(
      account.balance,
      account.currencyCode,
    );
  }
}

/// Thin dashed separator between treasury rows.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    final dividerColor = context.appColors.divider;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 5.0;
          const dashSpace = 4.0;
          final dashCount =
              (constraints.maxWidth / (dashWidth + dashSpace)).floor();

          return Row(
            children: List.generate(dashCount, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == dashCount - 1 ? 0 : dashSpace,
                ),
                child: Container(
                  width: dashWidth,
                  height: 1,
                  color: dividerColor,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
