import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/category_icon_styles.dart';
import '../../core/extensions/context_feedback.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/helpers/category_localization.dart';
import '../../core/helpers/currency_formatter.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/clay_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/budget_provider.dart';

/// Lists monthly budgets with actual spend progress.
class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().load();
    });
  }

  Future<void> _pickMonth(BudgetProvider provider) async {
    final initial = DateTime(provider.year, provider.month);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 1, 12),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked == null || !mounted) return;
    await provider.load(year: picked.year, month: picked.month);
  }

  Future<void> _copyPrevious(BudgetProvider provider) async {
    final l10n = context.l10n;
    final copied = await provider.copyFromPreviousMonth();
    if (!mounted) return;
    if (copied > 0) {
      context.showSuccessFeedback(l10n.budgetCopySuccess(copied));
    } else {
      context.showWarningFeedback(l10n.budgetCopyEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<BudgetProvider>();
    final monthLabel = DateFormat.yMMMM(l10n.localeName)
        .format(DateTime(provider.year, provider.month));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.budgetsTitle),
        actions: [
          IconButton(
            tooltip: l10n.budgetCopyPrevious,
            onPressed: provider.isLoading
                ? null
                : () => _copyPrevious(provider),
            icon: const Icon(Icons.content_copy_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '/budgets/add?year=${provider.year}&month=${provider.month}',
        ).then((_) {
          if (mounted) provider.load();
        }),
        icon: const Icon(Icons.add),
        label: Text(l10n.budgetAdd),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.load(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClayCard(
              child: ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: Text(l10n.budgetSelectedMonth),
                subtitle: Text(monthLabel, style: AppTextStyles.headingSmall),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => _pickMonth(provider),
              ),
            ),
            const SizedBox(height: 16),
            if (provider.isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ))
            else if (provider.items.isEmpty)
              EmptyState(
                message: '${l10n.budgetEmptyTitle}\n${l10n.budgetEmptySubtitle}',
                icon: Icons.pie_chart_outline,
              )
            else
              ...provider.items.map((row) {
                final overBudget = row.percentUsed > 100;
                final icon = CategoryIconStyles.iconFor(row.categoryIconKey);
                final color = CategoryIconStyles.colorFor(row.categoryColorHex);
                final budgetText = CurrencyFormatter.formatWithCode(
                  row.budget.amount,
                  row.currencyCode,
                );
                final actualText = CurrencyFormatter.formatWithCode(
                  row.actualBase,
                  row.currencyCode,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClayCard(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push(
                        '/budgets/${row.budget.id}/edit',
                      ).then((_) {
                        if (mounted) provider.load();
                      }),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(icon, color: color),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    CategoryLocalization.displayName(
                                      context.l10n,
                                      row.budget.categoryId,
                                      row.categoryName,
                                    ),
                                    style: AppTextStyles.headingSmall,
                                  ),
                                ),
                                if (overBudget)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.expense.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      l10n.budgetOverBadge,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.expense,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$actualText / $budgetText',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: context.appColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: (row.percentUsed / 100).clamp(0, 1),
                                minHeight: 8,
                                backgroundColor: context.appColors.divider,
                                color: overBudget
                                    ? AppColors.expense
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.budgetPercentUsed(
                                row.percentUsed.toStringAsFixed(0),
                              ),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: context.appColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
