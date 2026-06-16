import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/transaction_list_item.dart';

/// Single row in the transactions list — swipe to delete, tap to edit.
class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.item,
    required this.onLongPress,
    required this.deleteLabel,
    this.onEdit,
    this.onDismissDelete,
  });

  final TransactionListItem item;
  final VoidCallback onLongPress;
  final String deleteLabel;
  final VoidCallback? onEdit;
  final Future<bool> Function()? onDismissDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tile = Material(
      color: colors.scaffoldBackground,
      child: InkWell(
        onLongPress: onLongPress,
        onTap: item.canEdit ? onEdit : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _IconBadge(item: item),
              const SizedBox(width: 12),
              Expanded(child: _TitleBlock(item: item)),
              const SizedBox(width: 8),
              _AmountBlock(item: item),
              if (item.canEdit) ...[
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.dashboardPrimary,
                  ),
                  onPressed: onEdit,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!item.canDelete || onDismissDelete == null) {
      return tile;
    }

    return Dismissible(
      key: ValueKey('tx-${item.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final deleted = await onDismissDelete!();
        return deleted;
      },
      background: _SwipeDeleteBackground(label: deleteLabel),
      child: tile,
    );
  }
}

class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.expense,
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(end: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.delete_outline, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.item});

  final TransactionListItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: item.iconColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.iconColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Icon(item.icon, color: item.iconColor, size: 24),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.item});

  final TransactionListItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.captionOnSurface(colors).copyWith(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _AmountBlock extends StatelessWidget {
  const _AmountBlock({required this.item});

  final TransactionListItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final amountColor = item.isTransfer
        ? AppColors.dashboardPrimary
        : item.isDebt
            ? (item.kind == TransactionListKind.debtor
                ? AppColors.success
                : AppColors.debtAccent)
            : item.isIncome
                ? AppColors.success
                : AppColors.expense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            item.primaryAmount,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: amountColor,
              fontSize: 15,
            ),
          ),
        ),
        if (item.secondaryAmount != null) ...[
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              item.secondaryAmount!,
              style: AppTextStyles.captionOnSurface(colors).copyWith(
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
