import 'package:flutter/material.dart';

import '../../../core/constants/treasury_icon_styles.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import 'treasury_icon.dart';

/// Horizontally scrollable wallet type picker (add + edit screens).
class WalletTypeSelector extends StatelessWidget {
  const WalletTypeSelector({
    super.key,
    required this.selectedStyle,
    required this.onStyleSelected,
    this.styles = TreasuryIconStyles.selectable,
  });

  final String selectedStyle;
  final ValueChanged<String> onStyleSelected;
  final List<String> styles;

  static const _itemWidth = 96.0;
  static const _itemSpacing = 10.0;
  static const _listHeight = 118.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SizedBox(
      height: _listHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: styles.length,
        separatorBuilder: (_, __) => const SizedBox(width: _itemSpacing),
        itemBuilder: (context, index) {
          final style = styles[index];
          return SizedBox(
            width: _itemWidth,
            child: _WalletTypeOption(
              style: style,
              label: _labelForStyle(l10n, style),
              isSelected: selectedStyle == style,
              onTap: () => onStyleSelected(style),
            ),
          );
        },
      ),
    );
  }

  String _labelForStyle(dynamic l10n, String style) {
    return switch (style) {
      TreasuryIconStyles.cash => l10n.treasuryIconCashShort,
      TreasuryIconStyles.bank => l10n.treasuryIconBank,
      TreasuryIconStyles.crypto => l10n.treasuryIconCrypto,
      TreasuryIconStyles.travel => l10n.treasuryIconTravel,
      _ => l10n.treasuryIconCashShort,
    };
  }
}

class _WalletTypeOption extends StatelessWidget {
  const _WalletTypeOption({
    required this.style,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String style;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? colors.accentSurface : colors.inputFill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : colors.inputBorder,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: colors.cardShadow,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TreasuryIcon(
                  style: style,
                  size: 48,
                  iconSize: 24,
                  elevated: true,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
