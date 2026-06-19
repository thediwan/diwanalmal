import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/goal_icon_styles.dart';
import '../../core/extensions/context_feedback.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/helpers/currency_uniqueness.dart';
import '../../core/helpers/date_only.dart';
import '../../core/helpers/treasury_filters.dart';
import '../../core/helpers/user_facing_error.dart';
import '../../core/theme/app_form_fields.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/layouts/form_page_layout.dart';
import '../../core/widgets/auth_background.dart';
import '../../database/lazarus_database.dart';
import '../../models/treasury.dart';
import '../../providers/currency_provider.dart';
import '../../providers/dashboard_refresh_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/goal_service.dart';
import '../../services/lazarus_database_service.dart';
import '../transactions/widgets/transaction_wallet_carousel.dart';
import 'models/goal_savings_mode.dart';
import 'widgets/goal_amount_field.dart';
import 'widgets/goal_icon_selector.dart' show GoalFormLabel;

/// Dedicated deposit or withdraw form for a financial goal.
class GoalSavingsFormScreen extends StatefulWidget {
  const GoalSavingsFormScreen({
    super.key,
    required this.goalId,
    required this.mode,
  });

  final String goalId;
  final GoalSavingsMode mode;

  @override
  State<GoalSavingsFormScreen> createState() => _GoalSavingsFormScreenState();
}

class _GoalSavingsFormScreenState extends State<GoalSavingsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  FinancialGoal? _goal;
  String? _selectedWalletId;
  DateTime _transactionDate = todayDateOnly();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  bool get _isDeposit => widget.mode == GoalSavingsMode.deposit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currencyProvider = context.read<CurrencyProvider>();
      final walletProvider = context.read<WalletProvider>();

      if (currencyProvider.currencies.isEmpty) {
        await currencyProvider.loadCurrencies();
      }
      if (walletProvider.treasuries.isEmpty) {
        await walletProvider.loadWallets();
      }

      final goal =
          await GoalService(LazarusDatabaseService.instance).getById(widget.goalId);

      if (!mounted) return;

      if (goal == null) {
        setState(() {
          _error = context.l10n.goalEditNotFound;
          _isLoading = false;
        });
        return;
      }

      final eligible = _eligibleWallets(walletProvider.treasuries, goal);
      setState(() {
        _goal = goal;
        _selectedWalletId = eligible
                .any((w) => w.id == _selectedWalletId)
            ? _selectedWalletId
            : eligible.firstOrNull?.id;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Treasury> _eligibleWallets(List<Treasury> treasuries, FinancialGoal goal) {
    final currency = uniqueCurrenciesByCode(
      context.read<CurrencyProvider>().currencies,
    ).where((c) => c.id == goal.currencyId).firstOrNull;
    if (currency == null) return [];

    if (_isDeposit) {
      return regularTreasuriesWithBalanceForCurrency(
        treasuries: treasuries,
        currencyCode: currency.code,
        selectedWalletId: _selectedWalletId,
      );
    }

    return regularTreasuriesForCurrency(
      treasuries: treasuries,
      currencyCode: currency.code,
      selectedWalletId: _selectedWalletId,
    );
  }

  String? _currencyCode(FinancialGoal goal) {
    return uniqueCurrenciesByCode(context.read<CurrencyProvider>().currencies)
        .where((c) => c.id == goal.currencyId)
        .firstOrNull
        ?.code;
  }

  String? _currencySymbol(FinancialGoal goal) {
    return uniqueCurrenciesByCode(context.read<CurrencyProvider>().currencies)
        .where((c) => c.id == goal.currencyId)
        .firstOrNull
        ?.symbol;
  }

  Future<void> _pickDate() async {
    final locale = Localizations.localeOf(context);
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      locale: locale,
      helpText: context.l10n.transactionFormDate,
    );

    if (picked != null && mounted) {
      setState(() => _transactionDate = dateOnly(picked));
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) return;

    final goal = _goal;
    if (goal == null || goal.walletId == null) {
      context.showWarningFeedback(l10n.goalEditNotFound);
      return;
    }
    if (_selectedWalletId == null) {
      context.showWarningFeedback(l10n.goalSavingsSelectWallet);
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      context.showWarningFeedback(l10n.goalFormInvalidAmount);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final service = GoalService(LazarusDatabaseService.instance);
      final notes = _notesController.text.trim();

      if (_isDeposit) {
        await service.deposit(
          goalId: widget.goalId,
          sourceWalletId: _selectedWalletId!,
          amount: amount,
          date: _transactionDate,
          notes: notes.isEmpty ? null : notes,
        );
      } else {
        await service.withdraw(
          goalId: widget.goalId,
          destinationWalletId: _selectedWalletId!,
          amount: amount,
          date: _transactionDate,
          notes: notes.isEmpty ? null : notes,
        );
      }

      if (!mounted) return;
      context.read<DashboardRefreshProvider>().notifyRefresh();
      context.showSuccessFeedback(l10n.goalSavingsSuccess);
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      final message = UserFacingError.goalMessage(l10n, e);
      context.showWarningFeedback(message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _validateAmount(String? value) {
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
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final title = _isDeposit
        ? l10n.goalSavingsDepositTitle
        : l10n.goalSavingsWithdrawTitle;

    return AuthBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TopBar(title: title, onClose: () => context.pop()),
          Expanded(
            child: FormPageLayout(
              padding: EdgeInsetsDirectional.zero,
              child: _buildBody(colors, l10n),
            ),
          ),
          if (!_isLoading && _error == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
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
                    : Text(
                        _isDeposit ? l10n.goalDeposit : l10n.goalWithdraw,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(AppThemeColors colors, AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }

    final goal = _goal!;
    final currencyCode = _currencyCode(goal) ?? '';
    final currencySymbol = _currencySymbol(goal) ?? '';
    final currencies = uniqueCurrenciesByCode(
      context.watch<CurrencyProvider>().currencies,
    ).where((c) => c.id == goal.currencyId).toList();
    final eligibleWallets = _eligibleWallets(
      context.watch<WalletProvider>().treasuries,
      goal,
    );
    final inputStyle = AppFormFields.inputTextStyleOf(context);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat.yMMMd(locale).format(_transactionDate);
    final walletLabel = _isDeposit
        ? l10n.goalSavingsSourceWallet
        : l10n.goalSavingsDestinationWallet;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  GoalIconStyles.iconFor(goal.icon),
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    goal.title,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GoalFormLabel(text: l10n.goalSavingsAmount),
            ),
            const SizedBox(height: 8),
            GoalAmountField(
              controller: _amountController,
              currencies: currencies,
              selectedCurrencyId: goal.currencyId,
              onCurrencyChanged: (_) {},
              validator: _validateAmount,
              suffixIcon: Icon(
                Icons.payments_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GoalFormLabel(text: walletLabel),
            ),
            const SizedBox(height: 8),
            TransactionWalletCarousel(
              treasuries: eligibleWallets,
              currencyCode: currencyCode,
              selectedWalletId: _selectedWalletId,
              onSelected: (id) => setState(() => _selectedWalletId = id),
              emptyLabel: l10n.transactionFormNoWalletForCurrency,
            ),
            const SizedBox(height: 18),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GoalFormLabel(text: l10n.transactionFormDate),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: AppFormFields.decoration(
                  context,
                  suffixIcon: Icon(
                    Icons.calendar_month_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                child: Text(dateLabel, style: inputStyle),
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GoalFormLabel(text: l10n.transactionFormNotes),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              style: inputStyle,
              maxLines: 2,
              decoration: AppFormFields.decoration(
                context,
                hintText: l10n.transactionFormNotesHint,
              ),
            ),
            if (currencySymbol.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '${l10n.goalFormSavedAmount}: ${goal.savedAmount} $currencySymbol',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onClose});

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
                color: Theme.of(context).colorScheme.primary,
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

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
