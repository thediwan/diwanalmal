import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/transaction_icon_styles.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/transaction_list_item.dart';
import 'transaction_icon_badge.dart';

/// Single row in the transactions list — swipe to delete, tap to edit.
class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.item,
    required this.onLongPress,
    required this.deleteLabel,
    this.onTap,
    this.onEdit,
    this.onDismissDelete,
  });

  final TransactionListItem item;
  final VoidCallback onLongPress;
  final String deleteLabel;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final Future<bool> Function()? onDismissDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tile = Material(
      color: colors.scaffoldBackground,
      child: InkWell(
        onLongPress: onLongPress,
        onTap: onTap ?? (item.canEdit ? onEdit : null),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TransactionIconBadge(
                icon: item.icon,
                iconColor: item.iconColor,
              ),
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
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
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

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.item});

  final TransactionListItem item;

  static String? _truncateNotesPreview(String? notes, int maxWords) {
    final trimmed = notes?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    final words = trimmed.split(RegExp(r'\s+'));
    if (words.length <= maxWords) return trimmed;

    return words.take(maxWords).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final notesPreview = _truncateNotesPreview(item.notes, 2);

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
        if (item.isShared || item.isSplitLinked) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.accentSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.isSplitLinked
                  ? context.l10n.transactionSplitLinkedBadge
                  : context.l10n.transactionSplitSharedBadge,
              style: AppTextStyles.captionOnSurface(colors).copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        if (notesPreview != null) ...[
          const SizedBox(height: 4),
          Text(
            notesPreview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.captionOnSurface(colors).copyWith(
              fontSize: 12,
            ),
          ),
        ],
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
    final amountColor = TransactionIconStyles.amountColorForKind(item.kind);

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
