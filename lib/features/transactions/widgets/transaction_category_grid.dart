import 'package:flutter/material.dart';

import '../../../core/constants/category_icon_styles.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/helpers/category_localization.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/transaction_category.dart';

/// Category grid (4 columns) with optional "more" tile.
class TransactionCategoryGrid extends StatelessWidget {
  const TransactionCategoryGrid({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
    required this.moreLabel,
    required this.onMoreTap,
    this.maxVisible = 7,
    this.useOverflowPicker = false,
  });

  final List<TransactionCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<TransactionCategory> onSelected;
  final String moreLabel;
  final VoidCallback onMoreTap;
  final int maxVisible;
  final bool useOverflowPicker;

  List<TransactionCategory> get _visibleCategories =>
      categories.take(maxVisible).toList();

  List<TransactionCategory> get _overflowCategories =>
      categories.length > maxVisible
          ? categories.skip(maxVisible).toList()
          : const [];

  bool get _showMoreTile =>
      useOverflowPicker ? _overflowCategories.isNotEmpty : true;

  bool get _selectedInOverflow =>
      _overflowCategories.any((category) => category.id == selectedCategoryId);

  Future<void> _showOverflowPicker(BuildContext context) async {
    final overflow = _overflowCategories;
    if (overflow.isEmpty) return;

    final l10n = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: overflow.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (sheetContext, index) {
              final category = overflow[index];
              final selected = category.id == selectedCategoryId;
              final accent = CategoryIconStyles.colorFor(category.colorHex);

              return Material(
                color: Colors.transparent,
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: selected
                      ? Theme.of(sheetContext)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.08)
                      : null,
                  leading: Icon(
                    CategoryIconStyles.iconFor(category.iconKey),
                    color: selected
                        ? Theme.of(sheetContext).colorScheme.primary
                        : accent,
                  ),
                  title: Text(
                    category.localizedName(l10n),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? Theme.of(sheetContext).colorScheme.primary
                          : sheetContext.appColors.textPrimary,
                    ),
                  ),
                  onTap: () {
                    onSelected(category);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleCategories;
    final itemCount = visible.length + (_showMoreTile ? 1 : 0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        if (_showMoreTile && index == visible.length) {
          return _MoreCategoryTile(
            label: moreLabel,
            selected: _selectedInOverflow,
            onTap: useOverflowPicker
                ? () => _showOverflowPicker(context)
                : onMoreTap,
          );
        }

        final category = visible[index];
        return _CategoryTile(
          category: category,
          selected: category.id == selectedCategoryId,
          onTap: () => onSelected(category),
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final TransactionCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = context.l10n;
    final accent = CategoryIconStyles.colorFor(category.colorHex);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: selected
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                    : colors.inputFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      selected ? Theme.of(context).colorScheme.primary : colors.cardBorder,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Icon(
                CategoryIconStyles.iconFor(category.iconKey),
                color: selected ? Theme.of(context).colorScheme.primary : accent,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.localizedName(l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color:
                    selected ? Theme.of(context).colorScheme.primary : colors.textPrimary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreCategoryTile extends StatelessWidget {
  const _MoreCategoryTile({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: selected
                    ? primary.withValues(alpha: 0.12)
                    : colors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? primary : colors.cardBorder,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Icon(
                Icons.more_horiz,
                color: selected ? primary : colors.textMuted,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? primary : colors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
