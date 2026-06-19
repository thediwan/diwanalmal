import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/goal_icon_styles.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/helpers/currency_formatter.dart';
import '../../core/helpers/currency_uniqueness.dart';
import '../../core/helpers/date_only.dart';
import '../../core/theme/app_form_fields.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/layouts/form_page_layout.dart';
import '../../core/widgets/auth_background.dart';
import '../../core/widgets/brand_logo.dart';
import '../../database/daos/finance_dao.dart';
import '../../providers/currency_provider.dart';
import '../../services/goal_planning_service.dart';
import '../../services/goal_service.dart';
import '../../services/lazarus_database_service.dart';
import 'models/goal_draft.dart';
import 'widgets/goal_amount_field.dart';
import 'widgets/goal_icon_selector.dart';
import 'widgets/goal_progress_header.dart';
import '../../core/extensions/context_feedback.dart';

/// View and edit an existing financial goal with progress summary.
class GoalEditScreen extends StatefulWidget {
  const GoalEditScreen({super.key, required this.goalId});

  final String goalId;

  @override
  State<GoalEditScreen> createState() => _GoalEditScreenState();
}

class _GoalEditScreenState extends State<GoalEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();

  String _selectedIconStyle = GoalIconStyles.defaultStyle;
  String? _selectedCurrencyId;
  String? _currencySymbol;
  String? _walletId;
  double _savedAmount = 0;
  double _monthlyRequired = 0;
  double _monthlyNet = 0;
  List<TransferWithMeta> _transfers = [];
  DateTime? _targetDate;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _targetAmountController.addListener(_refreshProgressPreview);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadGoal());
  }

  void _refreshProgressPreview() {
    if (mounted) setState(() {});
  }

  Future<void> _loadGoal() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currencyProvider = context.read<CurrencyProvider>();
      if (currencyProvider.currencies.isEmpty) {
        await currencyProvider.loadCurrencies();
      }

      final goalService = GoalService(LazarusDatabaseService.instance);
      final goal = await goalService.getById(widget.goalId);

      if (!mounted) return;

      if (goal == null) {
        setState(() {
          _error = context.l10n.goalEditNotFound;
          _isLoading = false;
        });
        return;
      }

      final currency = currencyProvider.currencies
          .where((c) => c.id == goal.currencyId)
          .firstOrNull;

      var transfers = <TransferWithMeta>[];
      final userId = await LazarusDatabaseService.instance.getActiveUserId();
      if (userId != null && goal.walletId != null) {
        transfers = await LazarusDatabaseService.instance.database.financeDao
            .getTransfersForWallet(
          userId: userId,
          walletId: goal.walletId!,
          limit: 20,
        );
      }

      final monthlyNet = await goalService.netContributionsThisMonth(goal);
      final monthlyRequired = goal.targetDate == null
          ? 0.0
          : GoalPlanningService.monthlyRequiredFor(
              targetAmount: goal.targetAmount,
              savedAmount: goal.savedAmount,
              targetDate: goal.targetDate!,
            );

      _titleController.text = goal.title;
      _targetAmountController.text = _formatNumber(goal.targetAmount);
      _savedAmount = goal.savedAmount;
      _walletId = goal.walletId;
      _monthlyNet = monthlyNet;
      _monthlyRequired = monthlyRequired;
      _transfers = transfers;
      _selectedIconStyle = goal.icon ?? GoalIconStyles.defaultStyle;
      _selectedCurrencyId = goal.currencyId;
      _currencySymbol = currency?.symbol ?? '';
      _targetDate =
          goal.targetDate == null ? null : dateOnly(goal.targetDate!);

      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
      setState(() => _targetDate = dateOnly(picked));
    }
  }

  GoalDraft? _buildDraftFromForm() {
    final l10n = context.l10n;

    if (!_formKey.currentState!.validate()) return null;
    if (_targetDate == null) {
      context.showWarningFeedback(l10n.goalFormDateRequired);
      return null;
    }

    final currencies = uniqueCurrenciesByCode(
      context.read<CurrencyProvider>().currencies,
    );
    final currency = currencies
        .where((c) => c.id == _selectedCurrencyId)
        .firstOrNull;

    if (currency == null) {
      context.showWarningFeedback(l10n.goalFormSelectCurrency);
      return null;
    }

    final targetAmount = double.parse(_targetAmountController.text.trim());

    if (_savedAmount > targetAmount) {
      context.showWarningFeedback(l10n.goalFormSavedExceedsTarget);
      return null;
    }

    return GoalDraft(
      title: _titleController.text.trim(),
      targetAmount: targetAmount,
      savedAmount: _savedAmount,
      currencyId: currency.id,
      currencyCode: currency.code,
      currencySymbol: currency.symbol,
      rateToBase: currency.rateToBase,
      targetDate: dateOnly(_targetDate!),
      iconStyle: _selectedIconStyle,
    );
  }

  Future<void> _save() async {
    final draft = _buildDraftFromForm();
    if (draft == null) return;

    setState(() => _isSaving = true);

    try {
      await GoalService(LazarusDatabaseService.instance).update(
        id: widget.goalId,
        draft: draft,
      );
      if (mounted) {
        context.showSuccessFeedback(context.l10n.goalEditSaveSuccess);
        context.pop('updated');
      }
    } catch (e) {
      if (mounted) {
        context.showOperationError(e);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.goalEditDeleteTitle),
        content: Text(l10n.goalEditDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await GoalService(LazarusDatabaseService.instance)
          .delete(widget.goalId);
      if (mounted) {
        context.showSuccessFeedback(l10n.goalEditDeleteSuccess);
        context.pop('deleted');
      }
    } catch (e) {
      if (mounted) {
        if (e is StateError && e.message == 'goal_wallet_has_balance') {
          context.showWarningFeedback(l10n.goalDeleteHasBalance);
        } else {
          context.showOperationError(e);
        }
      }
    }
  }

  Future<void> _openDeposit() async {
    if (_walletId == null) return;
    await context.push('/goals/${widget.goalId}/deposit');
    if (mounted) await _loadGoal();
  }

  Future<void> _openWithdraw() async {
    if (_walletId == null) return;
    await context.push('/goals/${widget.goalId}/withdraw');
    if (mounted) await _loadGoal();
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

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    return AuthBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EditTopBar(
            title: l10n.goalEditTitle,
            onClose: () => context.pop(),
            onDelete: _delete,
          ),
          Expanded(
            child: FormPageLayout(
              padding: EdgeInsetsDirectional.zero,
              child: _buildBody(l10n, colors),
            ),
          ),
          if (!_isLoading && _error == null) _buildSaveButton(l10n, colors),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, AppThemeColors colors) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadGoal,
                child: Text(l10n.dashboardRetry),
              ),
            ],
          ),
        ),
      );
    }

    final currencies = uniqueCurrenciesByCode(
      context.watch<CurrencyProvider>().currencies,
    );
    final inputStyle = AppFormFields.inputTextStyleOf(context);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = _targetDate == null
        ? l10n.goalFormDateHint
        : DateFormat.yMMMd(locale).format(_targetDate!);

    final targetAmount =
        double.tryParse(_targetAmountController.text.trim()) ?? 0;
    final savedAmount = _savedAmount;
    final symbol = currencies
            .where((c) => c.id == _selectedCurrencyId)
            .firstOrNull
            ?.symbol ??
        _currencySymbol ??
        '';

    final liveProgress = targetAmount <= 0
        ? 0
        : ((savedAmount / targetAmount) * 100).round().clamp(0, 100);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const _GoalHeroLogo(),
            const SizedBox(height: 16),
            Text(
              l10n.goalEditHeading,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingSmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.goalEditSubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            GoalProgressHeader(
              icon: GoalIconStyles.iconFor(_selectedIconStyle),
              progressPercent: liveProgress,
              savedAmount: savedAmount,
              targetAmount: targetAmount,
              currencySymbol: symbol,
              progressLabel: l10n.goalEditProgress(liveProgress),
              savedOfTargetLabel: l10n.goalEditSavedOfTarget(
                CurrencyFormatter.format(savedAmount, symbol: symbol),
                CurrencyFormatter.format(targetAmount, symbol: symbol),
              ),
            ),
            if (_walletId != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openDeposit,
                      icon: const Icon(Icons.add_circle_outline),
                      label: Text(l10n.goalDeposit),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openWithdraw,
                      icon: const Icon(Icons.remove_circle_outline),
                      label: Text(l10n.goalWithdraw),
                    ),
                  ),
                ],
              ),
              if (_monthlyRequired > 0) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.goalThisMonthProgress(
                    CurrencyFormatter.format(_monthlyNet, symbol: symbol),
                    CurrencyFormatter.format(_monthlyRequired, symbol: symbol),
                  ),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GoalFormLabel(text: l10n.goalFormName),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              style: inputStyle,
              onChanged: (_) => setState(() {}),
              decoration: AppFormFields.decoration(
                context,
                hintText: l10n.goalFormNameHint,
                suffixIcon: const Icon(
                  Icons.flag_outlined,
                  color: AppColors.dashboardPrimary,
                  size: 20,
                ),
              ),
              validator: (value) => value == null || value.trim().isEmpty
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
              onCurrencyChanged: (id) => setState(() => _selectedCurrencyId = id),
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
              child: GoalFormLabel(text: l10n.goalSavedAmountReadOnly),
            ),
            const SizedBox(height: 8),
            InputDecorator(
              decoration: AppFormFields.decoration(
                context,
                suffixIcon: const Icon(
                  Icons.savings_outlined,
                  color: AppColors.dashboardPrimary,
                  size: 20,
                ),
              ),
              child: Text(
                CurrencyFormatter.format(savedAmount, symbol: symbol),
                style: inputStyle,
              ),
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
            if (_walletId != null) ...[
              const SizedBox(height: 24),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: GoalFormLabel(text: l10n.goalTransferHistory),
              ),
              const SizedBox(height: 8),
              if (_transfers.isEmpty)
                Text(
                  l10n.goalNoTransfersYet,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                )
              else
                ..._transfers.map(
                  (row) => _GoalTransferRow(
                    row: row,
                    goalWalletId: _walletId!,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n, AppThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: FilledButton(
        onPressed: _isSaving ? null : _save,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.dashboardPrimary,
          foregroundColor: colors.onPrimary,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.onPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.goalEditSave,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.check_rounded, color: colors.onPrimary, size: 22),
                ],
              ),
      ),
    );
  }
}

class _GoalTransferRow extends StatelessWidget {
  const _GoalTransferRow({
    required this.row,
    required this.goalWalletId,
  });

  final TransferWithMeta row;
  final String goalWalletId;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = Localizations.localeOf(context).toString();
    final isDeposit = row.transfer.toWalletId == goalWalletId;
    final date = DateFormat.yMMMd(locale).format(row.transfer.transactionDate);
    final displayAmount = isDeposit
        ? (row.transfer.toAmount ?? row.transfer.amount)
        : row.transfer.amount;
    final code = isDeposit ? row.toCurrencyCode : row.currencyCode;
    final amount = CurrencyFormatter.formatWithCode(displayAmount, code);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
            size: 18,
            color: isDeposit ? AppColors.success : AppColors.expense,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${row.fromWalletName} → ${row.toWalletName}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  date,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditTopBar extends StatelessWidget {
  const _EditTopBar({
    required this.title,
    required this.onClose,
    required this.onDelete,
  });

  final String title;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
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
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
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
