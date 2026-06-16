import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_form_fields.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../database/daos/finance_dao.dart';
import '../../../models/transaction_category.dart';

/// Bottom sheet for advanced list filters (date range, category, type).
class TransactionListFilterSheet extends StatefulWidget {
  const TransactionListFilterSheet({
    super.key,
    required this.initialFilter,
    required this.categories,
  });

  final ActivityFeedFilter initialFilter;
  final List<TransactionCategory> categories;

  @override
  State<TransactionListFilterSheet> createState() =>
      _TransactionListFilterSheetState();
}

class _TransactionListFilterSheetState extends State<TransactionListFilterSheet> {
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _categoryId;
  ActivityFeedTab? _typeFilter;

  @override
  void initState() {
    super.initState();
    _dateFrom = widget.initialFilter.dateFrom;
    _dateTo = widget.initialFilter.dateTo;
    _categoryId = widget.initialFilter.categoryId;
    _typeFilter = widget.initialFilter.advancedTypeFilter;
  }

  Future<void> _pickDate({
    required bool isFrom,
  }) async {
    final initial = isFrom
        ? (_dateFrom ?? DateTime.now())
        : (_dateTo ?? _dateFrom ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _dateFrom = picked;
      } else {
        _dateTo = picked;
      }
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      widget.initialFilter.copyWith(
        dateFrom: _dateFrom,
        clearDateFrom: _dateFrom == null,
        dateTo: _dateTo,
        clearDateTo: _dateTo == null,
        categoryId: _categoryId,
        clearCategoryId: _categoryId == null,
        advancedTypeFilter: _typeFilter,
        clearAdvancedTypeFilter: _typeFilter == null,
        thisMonthOnly: _dateFrom == null && _dateTo == null
            ? widget.initialFilter.thisMonthOnly
            : false,
      ),
    );
  }

  void _reset() {
    Navigator.pop(
      context,
      widget.initialFilter.copyWith(
        clearDateFrom: true,
        clearDateTo: true,
        clearCategoryId: true,
        clearAdvancedTypeFilter: true,
        thisMonthOnly: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final localeName = Localizations.localeOf(context).toString();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.paddingOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.transactionsListFilterTitle,
            style: AppTextStyles.headingSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _DateField(
            label: l10n.transactionsListFilterDateFrom,
            value: _dateFrom,
            localeName: localeName,
            onTap: () => _pickDate(isFrom: true),
          ),
          const SizedBox(height: 12),
          _DateField(
            label: l10n.transactionsListFilterDateTo,
            value: _dateTo,
            localeName: localeName,
            onTap: () => _pickDate(isFrom: false),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.transactionsListFilterCategory,
            style: AppFormFields.sectionLabelStyleOf(context),
          ),
          const SizedBox(height: 8),
          AppFormFields.dropdown<String?>(
            context: context,
            value: _categoryId,
            onChanged: (value) => setState(() => _categoryId = value),
            items: [
              AppFormFields.dropdownItem<String?>(
                context: context,
                value: null,
                label: l10n.transactionsListFilterAllCategories,
              ),
              ...widget.categories.map(
                (cat) => AppFormFields.dropdownItem<String?>(
                  context: context,
                  value: cat.id,
                  label: cat.name,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.transactionsListFilterType,
            style: AppFormFields.sectionLabelStyleOf(context),
          ),
          const SizedBox(height: 8),
          AppFormFields.dropdown<ActivityFeedTab?>(
            context: context,
            value: _typeFilter,
            onChanged: (value) => setState(() => _typeFilter = value),
            items: [
              AppFormFields.dropdownItem<ActivityFeedTab?>(
                context: context,
                value: null,
                label: l10n.transactionsListFilterAllTypes,
              ),
              AppFormFields.dropdownItem<ActivityFeedTab?>(
                context: context,
                value: ActivityFeedTab.expense,
                label: l10n.transactionsListTabExpenses,
              ),
              AppFormFields.dropdownItem<ActivityFeedTab?>(
                context: context,
                value: ActivityFeedTab.income,
                label: l10n.transactionsListTabIncomes,
              ),
              AppFormFields.dropdownItem<ActivityFeedTab?>(
                context: context,
                value: ActivityFeedTab.debt,
                label: l10n.transactionsListTabDebts,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  child: Text(l10n.transactionsListFilterReset),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.dashboardPrimary,
                  ),
                  onPressed: _apply,
                  child: Text(l10n.transactionsListFilterApply),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.localeName,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final String localeName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final formatted = value != null
        ? DateFormat.yMMMd(localeName).format(value!)
        : '—';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: colors.inputFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.captionOnSurface(colors),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatted,
                    style: AppFormFields.inputTextStyleOf(context),
                  ),
                ],
              ),
            ),
            Icon(Icons.calendar_today_outlined, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
