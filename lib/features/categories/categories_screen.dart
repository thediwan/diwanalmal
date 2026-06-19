import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/category_icon_styles.dart';
import '../../core/constants/database_constants.dart';
import '../../core/extensions/context_feedback.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/helpers/category_localization.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/transaction_category.dart';
import '../../services/category_service.dart';
import '../../services/lazarus_database_service.dart';

/// Lists income or expense categories with delete on non-system rows.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({
    super.key,
    this.initialType = DatabaseConstants.categoryExpense,
  });

  final String initialType;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _categoryService =
      CategoryService(LazarusDatabaseService.instance);

  late String _type;
  bool _isLoading = true;
  List<TransactionCategory> _categories = [];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final items = _type == DatabaseConstants.categoryIncome
        ? await _categoryService.getIncomeCategories()
        : await _categoryService.getExpenseCategories();
    if (!mounted) return;
    setState(() {
      _categories = items;
      _isLoading = false;
    });
  }

  Future<void> _openAdd() async {
    await context.push('/categories/add?type=$_type');
    if (mounted) await _load();
  }

  Future<void> _openEdit(TransactionCategory category) async {
    if (category.isSystem) {
      context.showWarningFeedback(context.l10n.categoryFormSystemProtected);
      return;
    }
    await context.push('/categories/${category.id}/edit');
    if (mounted) await _load();
  }

  Future<void> _deleteCategory(TransactionCategory category) async {
    final l10n = context.l10n;

    if (category.isSystem) {
      context.showWarningFeedback(l10n.categoryFormSystemProtected);
      return;
    }

    final hasTx = await _categoryService.hasTransactions(category.id);
    if (!mounted) return;

    if (hasTx) {
      context.showWarningFeedback(l10n.categoryFormHasTransactions);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.categoryFormDeleteTitle),
        content: Text(
          l10n.categoryFormDeleteMessage(category.localizedName(l10n)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _categoryService.delete(category.id);
      if (!mounted) return;
      context.showSuccessFeedback(l10n.categoryFormDeleteSuccess);
      await _load();
    } catch (e) {
      if (mounted) {
        context.showOperationError(e, categoryContext: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _type == DatabaseConstants.categoryIncome
              ? l10n.categoriesTitleIncome
              : l10n.categoriesTitleExpense,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: DatabaseConstants.categoryExpense,
                  label: Text(l10n.categoryFormTypeExpense),
                  icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                ),
                ButtonSegment(
                  value: DatabaseConstants.categoryIncome,
                  label: Text(l10n.categoryFormTypeIncome),
                  icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (value) {
                setState(() => _type = value.first);
                _load();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _categories.isEmpty
                    ? EmptyState(
                        message: l10n.categoriesEmpty,
                        icon: Icons.category_outlined,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return _CategoryListTile(
                            category: category,
                            onTap: () => _openEdit(category),
                            onDelete: category.isSystem
                                ? null
                                : () => _deleteCategory(category),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryListTile extends StatelessWidget {
  const _CategoryListTile({
    required this.category,
    required this.onTap,
    this.onDelete,
  });

  final TransactionCategory category;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = CategoryIconStyles.colorFor(category.colorHex);

    return ClayCard(
      elevation: ClayElevation.low,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.iconBadge),
            ),
            child: Icon(
              CategoryIconStyles.iconFor(category.iconKey),
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    category.localizedName(l10n),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (category.isSystem) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Text(
                      l10n.categoryFormSystemBadge,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: l10n.commonDelete,
              onPressed: onDelete,
              icon: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.expense.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.expense,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
