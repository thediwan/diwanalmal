import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/database_constants.dart';
import '../../core/extensions/context_feedback.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/helpers/category_localization.dart';
import '../../core/theme/app_form_fields.dart';
import '../../models/currency.dart';
import '../../models/transaction_category.dart';
import '../../providers/currency_provider.dart';
import '../../services/budget_service.dart';
import '../../services/category_service.dart';
import '../../services/lazarus_database_service.dart';

/// Form to add or edit a monthly category budget.
class BudgetFormScreen extends StatefulWidget {
  const BudgetFormScreen({
    super.key,
    this.budgetId,
    this.initialYear,
    this.initialMonth,
  });

  final String? budgetId;
  final int? initialYear;
  final int? initialMonth;

  bool get isEditing => budgetId != null;

  @override
  State<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _budgetService =
      BudgetService(LazarusDatabaseService.instance, CategoryService(LazarusDatabaseService.instance));
  final _categoryService =
      CategoryService(LazarusDatabaseService.instance);

  List<TransactionCategory> _categories = [];
  Currency? _baseCurrency;
  String? _selectedCategoryId;
  late int _year;
  late int _month;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = widget.initialYear ?? now.year;
    _month = widget.initialMonth ?? now.month;
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    _categories = await _categoryService.getExpenseCategories();
    if (!mounted) return;
    _baseCurrency = context.read<CurrencyProvider>().baseCurrency;

    if (widget.isEditing) {
      final budget = await _budgetService.getById(widget.budgetId!);
      if (!mounted) return;
      if (budget == null) {
        context.pop();
        return;
      }
      _selectedCategoryId = budget.categoryId;
      _year = budget.year;
      _month = budget.month;
      _amountController.text = budget.amount.toStringAsFixed(2);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? _parseAmount() {
    final raw = _amountController.text.trim();
    if (raw.isEmpty) return null;
    return double.tryParse(raw.replaceAll(',', '.'));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      context.showWarningFeedback(context.l10n.budgetCategoryRequired);
      return;
    }

    final amount = _parseAmount();
    if (amount == null || amount <= 0) {
      context.showWarningFeedback(context.l10n.budgetAmountInvalid);
      return;
    }

    final currencyId = _baseCurrency?.id;
    if (currencyId == null) {
      context.showWarningFeedback(context.l10n.currencyNotFound);
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (widget.isEditing) {
        await _budgetService.update(
          id: widget.budgetId!,
          categoryId: _selectedCategoryId!,
          year: _year,
          month: _month,
          amount: amount,
          currencyId: currencyId,
        );
      } else {
        await _budgetService.create(
          categoryId: _selectedCategoryId!,
          year: _year,
          month: _month,
          amount: amount,
          currencyId: currencyId,
        );
      }
      if (!mounted) return;
      context.showSuccessFeedback(context.l10n.budgetSaveSuccess);
      context.pop();
    } catch (e) {
      if (!mounted) return;
      final l10n = context.l10n;
      final message = e.toString().contains('budget_category_exists')
          ? l10n.budgetCategoryExists
          : l10n.budgetSaveError;
      context.showErrorFeedback(message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? l10n.budgetEditTitle : l10n.budgetAddTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    l10n.budgetCategoryLabel,
                    style: AppFormFields.sectionLabelStyleOf(context),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: AppFormFields.decoration(
                      context,
                      hintText: l10n.budgetCategoryHint,
                    ),
                    items: _categories
                        .where((c) => c.type == DatabaseConstants.categoryExpense)
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              CategoryLocalization.displayName(
                                context.l10n,
                                c.id,
                                c.name,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: widget.isEditing
                        ? null
                        : (value) => setState(() => _selectedCategoryId = value),
                    validator: (value) =>
                        value == null ? l10n.budgetCategoryRequired : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.budgetAmountLabel,
                    style: AppFormFields.sectionLabelStyleOf(context),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: AppFormFields.decoration(
                      context,
                      hintText: '0.00',
                      suffixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 12),
                        child: Center(
                          widthFactor: 1,
                          child: Text(_baseCurrency?.code ?? 'USD'),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.budgetAmountInvalid;
                      }
                      final parsed =
                          double.tryParse(value.replaceAll(',', '.'));
                      if (parsed == null || parsed <= 0) {
                        return l10n.budgetAmountInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.commonSave),
                  ),
                ],
              ),
            ),
    );
  }
}
