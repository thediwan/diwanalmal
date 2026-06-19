import 'package:flutter/material.dart';

import '../../../core/constants/treasury_icon_styles.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/helpers/currency_formatter.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/wallets/widgets/treasury_icon.dart';
import '../../../models/treasury.dart';

/// Horizontal wallet cards filtered by selected currency.
class TransactionWalletCarousel extends StatelessWidget {
  const TransactionWalletCarousel({
    super.key,
    required this.treasuries,
    required this.currencyCode,
    required this.selectedWalletId,
    required this.onSelected,
    required this.emptyLabel,
  });

  final List<Treasury> treasuries;
  final String currencyCode;
  final String? selectedWalletId;
  final ValueChanged<String> onSelected;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (treasuries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          emptyLabel,
          style: AppTextStyles.bodySmall.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
      );
    }

    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: treasuries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final treasury = treasuries[index];
          final account = treasury.accounts
              .where(
                (a) => a.currencyCode.toUpperCase() == currencyCode.toUpperCase(),
              )
              .firstOrNull;
          final balance = account?.balance ?? 0;
          final selected = treasury.id == selectedWalletId;

          return _WalletCard(
            treasury: treasury,
            balanceText:
                '${currencyCode.toUpperCase()} ${CurrencyFormatter.formatAmountOnly(balance)}',
            selected: selected,
            onTap: () => onSelected(treasury.id),
          );
        },
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.treasury,
    required this.balanceText,
    required this.selected,
    required this.onTap,
  });

  final Treasury treasury;
  final String balanceText;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final iconStyle = treasury.iconStyle ?? TreasuryIconStyles.cash;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 168,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : colors.cardBorder,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (selected)
              Positioned(
                top: 0,
                left: 0,
                child: Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TreasuryIcon(
                  style: iconStyle,
                  size: 36,
                  iconSize: 18,
                ),
                const Spacer(),
                Text(
                  treasury.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  balanceText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
