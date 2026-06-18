import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/goal_icon_styles.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/helpers/currency_uniqueness.dart';
import '../../core/theme/app_form_fields.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/auth_background.dart';
import '../../core/widgets/brand_logo.dart';
import '../../providers/currency_provider.dart';
import 'models/goal_draft.dart';
import 'widgets/goal_amount_field.dart';
import 'widgets/goal_icon_selector.dart';
import '../../core/extensions/context_feedback.dart';

/// Phase 1 — collect goal details before showing the savings plan.
class GoalFormScreen extends StatefulWidget {
  const GoalFormScreen({super.key, this.initialDraft});

  final GoalDraft? initialDraft;

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _savedAmountController = TextEditingController(text: '0');

  String _selectedIconStyle = GoalIconStyles.defaultStyle;
  String? _selectedCurrencyId;
  DateTime? _targetDate;
  bool _isLoadingCurrencies = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeForm());
  }

  Future<void> _initializeForm() async {
    if (!mounted) return;
    setState(() => _isLoadingCurrencies = true);

    final currencyProvider = context.read<CurrencyProvider>();
    if (currencyProvider.currencies.isEmpty) {
      await currencyProvider.loadCurrencies();
    }

    if (!mounted) return;

    final draft = widget.initialDraft;
    if (draft != null) {
      _titleController.text = draft.title;
      _targetAmountController.text = _formatNumber(draft.targetAmount);
      _savedAmountController.text = _formatNumber(draft.savedAmount);
      _selectedIconStyle = draft.iconStyle;
      _selectedCurrencyId = draft.currencyId;
      _targetDate = draft.targetDate;
    } else {
      _selectedCurrencyId = currencyProvider.baseCurrency?.id ??
          currencyProvider.currencies.firstOrNull?.id;
    }

    if (mounted) {
      setState(() => _isLoadingCurrencies = false);
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  Future<void> _pickDate() async {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final now = DateTime.now();
    final initial = _targetDate ?? now.add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: now,
      lastDate: DateTime(now.year + 30),
      locale: locale,
      helpText: l10n.goalFormTargetDate,
    );

    if (picked != null && mounted) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_targetDate == null) {
      context.showWarningFeedback(context.l10n.goalFormDateRequired);
      return;
    }

    final currencies = uniqueCurrenciesByCode(
      context.read<CurrencyProvider>().currencies,
    );
    final currency = currencies
        .where((c) => c.id == _selectedCurrencyId)
        .firstOrNull;

    if (currency == null) {
      context.showWarningFeedback(context.l10n.goalFormSelectCurrency);
      return;
    }

    final targetAmount = double.parse(_targetAmountController.text.trim());
    final savedAmount = double.tryParse(_savedAmountController.text.trim()) ?? 0;

    if (savedAmount > targetAmount) {
      context.showWarningFeedback(context.l10n.goalFormSavedExceedsTarget);
      return;
    }

    final draft = GoalDraft(
      title: _titleController.text.trim(),
      targetAmount: targetAmount,
      savedAmount: savedAmount,
      currencyId: currency.id,
      currencyCode: currency.code,
      currencySymbol: currency.symbol,
      rateToBase: currency.rateToBase,
      targetDate: _targetDate!,
      iconStyle: _selectedIconStyle,
    );

    final updated = await context.push<GoalDraft>('/goals/plan', extra: draft);
    if (updated != null && mounted) {
      _applyDraft(updated);
    }
  }

  void _applyDraft(GoalDraft draft) {
    _titleController.text = draft.title;
    _targetAmountController.text = _formatNumber(draft.targetAmount);
    _savedAmountController.text = _formatNumber(draft.savedAmount);
    _selectedIconStyle = draft.iconStyle;
    _selectedCurrencyId = draft.currencyId;
    _targetDate = draft.targetDate;
    setState(() {});
  }

  String? _validateRequiredAmount(String? value) {
    final l10n = context.l10n;
    if (value == null || value.trim().isEmpty) {
      return l10n.goalFormAmountRequired;
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return l10n.goalFormInvalidAmount;
    }
    return null;
  }

  String? _validateSavedAmount(String? value) {
    final l10n = context.l10n;
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return l10n.goalFormInvalidAmount;
    }
    return null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _savedAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final currencies = uniqueCurrenciesByCode(
      context.watch<CurrencyProvider>().currencies,
    );
    final inputStyle = AppFormFields.inputTextStyleOf(context);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = _targetDate == null
        ? l10n.goalFormDateHint
        : DateFormat.yMMMd(locale).format(_targetDate!);

    return AuthBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GoalFormTopBar(
            title: l10n.goalFormTitle,
            onClose: () => context.pop(),
          ),
          Expanded(
            child: _isLoadingCurrencies
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const _GoalHeroLogo(),
                          const SizedBox(height: 16),
                          Text(
                            l10n.goalFormHeading,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headingSmall.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.goalFormSubtitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: GoalFormLabel(text: l10n.goalFormName),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            style: inputStyle,
                            decoration: AppFormFields.decoration(
                              context,
                              hintText: l10n.goalFormNameHint,
                              suffixIcon: const Icon(
                                Icons.flag_outlined,
                                color: AppColors.dashboardPrimary,
                                size: 20,
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? l10n.goalFormNameRequired
                                    : null,
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: GoalFormLabel(text: l10n.goalFormTargetAmount),
                          ),
                          const SizedBox(height: 8),
                          GoalAmountField(
                            controller: _targetAmountController,
                            currencies: currencies,
                            selectedCurrencyId: _selectedCurrencyId,
                            onCurrencyChanged: (id) =>
                                setState(() => _selectedCurrencyId = id),
                            validator: _validateRequiredAmount,
                            suffixIcon: const Icon(
                              Icons.payments_outlined,
                              color: AppColors.dashboardPrimary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: GoalFormLabel(text: l10n.goalFormSavedAmount),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _savedAmountController,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            style: inputStyle,
                            decoration: AppFormFields.decoration(
                              context,
                              hintText: '0',
                              suffixIcon: const Icon(
                                Icons.savings_outlined,
                                color: AppColors.dashboardPrimary,
                                size: 20,
                              ),
                            ),
                            validator: _validateSavedAmount,
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: GoalFormLabel(text: l10n.goalFormTargetDate),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: AppFormFields.decoration(
                                context,
                                suffixIcon: const Icon(
                                  Icons.calendar_month_outlined,
                                  color: AppColors.dashboardPrimary,
                                  size: 20,
                                ),
                              ),
                              child: Text(
                                dateLabel,
                                style: inputStyle.copyWith(
                                  color: _targetDate == null
                                      ? colors.inputHint
                                      : colors.inputText,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: GoalFormLabel(text: l10n.goalFormChooseIcon),
                          ),
                          const SizedBox(height: 10),
                          GoalIconSelector(
                            selectedStyle: _selectedIconStyle,
                            onStyleSelected: (style) =>
                                setState(() => _selectedIconStyle = style),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.dashboardPrimary,
                foregroundColor: colors.onPrimary,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.goalFormSave,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.done_all_rounded, color: colors.onPrimary, size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalFormTopBar extends StatelessWidget {
  const _GoalFormTopBar({
    required this.title,
    required this.onClose,
  });

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 26),
            color: colors.textPrimary,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.dashboardPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _GoalHeroLogo extends StatelessWidget {
  const _GoalHeroLogo();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: BrandLogoImage(
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.account_balance,
          color: AppColors.dashboardPrimary,
          size: 32,
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
