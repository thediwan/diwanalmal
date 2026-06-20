import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/split_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/database_constants.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/helpers/app_date_formatter.dart';
import '../../core/helpers/currency_formatter.dart';
import '../../core/helpers/exchange_rate_display.dart';
import '../../core/helpers/number_format_preferences.dart';
import '../../core/helpers/currency_uniqueness.dart';
import '../../core/helpers/treasury_filters.dart';
import '../../core/helpers/split_calculator.dart';
import '../../core/helpers/user_facing_error.dart';
import '../../core/theme/app_form_fields.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/layouts/form_page_layout.dart';
import '../../core/widgets/auth_background.dart';
import '../../core/widgets/brand_logo.dart';
import '../../l10n/app_localizations.dart';
import '../../models/currency.dart';
import '../../models/treasury.dart';
import '../../models/transaction_category.dart';
import '../../providers/currency_provider.dart';
import '../../providers/dashboard_refresh_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../services/category_service.dart';
import '../../services/debt_service.dart';
import '../../services/lazarus_database_service.dart';
import '../../services/transaction_split_service.dart';
import '../../services/transfer_service.dart';
import '../contacts/widgets/person_picker_field.dart';
import 'models/transaction_entry_type.dart';
import 'widgets/form_feedback_banner.dart';
import 'widgets/transaction_category_grid.dart';
import 'widgets/transaction_currency_pills.dart';
import 'widgets/transaction_numeric_keypad.dart';
import 'widgets/split_whatsapp_success_sheet.dart';
import 'widgets/transaction_split_section.dart';
import 'widgets/transaction_type_toggle.dart';
import 'widgets/transaction_wallet_carousel.dart';

/// Add income, expense, transfer, or debt ledger entry.
class TransactionAddScreen extends StatefulWidget {
  const TransactionAddScreen({
    super.key,
    this.initialEntryType,
  });

  final TransactionEntryType? initialEntryType;

  @override
  State<TransactionAddScreen> createState() => _TransactionAddScreenState();
}

class _TransactionAddScreenState extends State<TransactionAddScreen>
    with WidgetsBindingObserver {
  static const _saveButtonAreaHeight = 78.0;

  final _amountInput = TransactionAmountInput();
  final _scrollController = ScrollController();
  final _notesFocusNode = FocusNode();
  final _notesFieldKey = GlobalKey();
  final _notesController = TextEditingController();
  final _transferAmountController = TextEditingController();
  final _exchangeRateController = TextEditingController();
  final _personNameController = TextEditingController();
  final _debtAmountController = TextEditingController();

  String? _debtContactId;
  String? _debtContactPhone;
  bool _splitEnabled = false;
  String _splitMode = SplitConstants.modeEqual;
  bool _splitIncludeSelf = true;
  double? _splitFixedAmountPerPerson;
  List<SplitParticipantDraft> _splitParticipants = const [];

  bool _isExpense = true;
  TransactionEntryType _entryType = TransactionEntryType.expense;
  bool _isLoading = true;
  bool _isSaving = false;

  FormFeedbackType? _feedbackType;
  String? _feedbackMessage;
  Timer? _feedbackDismissTimer;
  Timer? _notesScrollDebounce;
  bool _notesScrollAnimating = false;

  String? _selectedCurrencyId;
  String? _selectedWalletId;
  String? _selectedCategoryId;
  String? _sourceCurrencyId;
  String? _targetCurrencyId;
  String? _sourceWalletId;
  String? _targetWalletId;
  DateTime _transactionDate = DateTime.now();
  DateTime? _dueDate;

  List<TransactionCategory> _expenseCategories = [];
  List<TransactionCategory> _incomeCategories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notesFocusNode.addListener(_onNotesFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (_notesFocusNode.hasFocus) {
      _scheduleNotesFieldScroll();
    }
  }

  /// Waits for the keyboard to settle, then runs one smooth scroll.
  void _onNotesFocusChanged() {
    if (!_notesFocusNode.hasFocus) return;
    _scheduleNotesFieldScroll();
  }

  void _scheduleNotesFieldScroll() {
    _notesScrollDebounce?.cancel();
    _notesScrollDebounce = Timer(const Duration(milliseconds: 260), () {
      if (!mounted || !_notesFocusNode.hasFocus) return;
      _scrollNotesFieldIntoViewSmooth();
    });
  }

  Future<void> _scrollNotesFieldIntoViewSmooth() async {
    if (!mounted || !_notesFocusNode.hasFocus || _notesScrollAnimating) return;
    if (!_scrollController.hasClients) return;

    final fieldContext = _notesFieldKey.currentContext;
    if (fieldContext == null) return;

    final fieldBox = fieldContext.findRenderObject();
    if (fieldBox is! RenderBox || !fieldBox.hasSize) return;

    final scrollable = Scrollable.maybeOf(fieldContext);
    if (scrollable == null) return;

    final scrollBox = scrollable.context.findRenderObject();
    if (scrollBox is! RenderBox || !scrollBox.hasSize) return;

    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final visibleBottom =
        scrollBox.size.height - keyboardInset - _saveButtonAreaHeight - 12;
    final fieldTop =
        fieldBox.localToGlobal(Offset.zero, ancestor: scrollBox).dy;
    final fieldBottom = fieldTop + fieldBox.size.height;

    const topMargin = 20.0;
    var targetOffset = _scrollController.offset;

    if (fieldBottom > visibleBottom) {
      targetOffset += fieldBottom - visibleBottom;
    } else if (fieldTop < topMargin) {
      targetOffset -= topMargin - fieldTop;
    } else {
      return;
    }

    targetOffset = targetOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    if ((_scrollController.offset - targetOffset).abs() < 6) return;

    _notesScrollAnimating = true;
    try {
      await _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } finally {
      _notesScrollAnimating = false;
    }
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);

    final currencyProvider = context.read<CurrencyProvider>();
    final walletProvider = context.read<WalletProvider>();
    final categoryService = CategoryService(LazarusDatabaseService.instance);

    if (currencyProvider.currencies.isEmpty) {
      await currencyProvider.loadCurrencies();
    }
    if (walletProvider.treasuries.isEmpty) {
      await walletProvider.loadWallets();
    }

    final expense = await categoryService.getExpenseCategories();
    final income = await categoryService.getIncomeCategories();

    if (!mounted) return;

    final currencies = uniqueCurrenciesByCode(currencyProvider.currencies);
    final baseId = currencyProvider.baseCurrency?.id ?? currencies.firstOrNull?.id;

    setState(() {
      _expenseCategories = expense;
      _incomeCategories = income;
      _selectedCurrencyId = baseId;
      _sourceCurrencyId = baseId;
      if (widget.initialEntryType != null) {
        _entryType = widget.initialEntryType!;
        _isExpense = _entryType == TransactionEntryType.expense;
      }
      _targetCurrencyId = currencies
              .where((c) => c.id != baseId)
              .firstOrNull
              ?.id ??
          baseId;
      _isLoading = false;
    });

    _syncWalletAndCategoryDefaults();
    _syncExchangeRateFromCurrencies();
  }

  List<TransactionCategory> get _activeCategories =>
      _entryType == TransactionEntryType.income
          ? _incomeCategories
          : _expenseCategories;

  bool get _isTransferMode =>
      _entryType == TransactionEntryType.currencyTransfer;

  bool get _isDebtMode =>
      _entryType == TransactionEntryType.debtor ||
      _entryType == TransactionEntryType.creditor;

  bool get _isIncomeEntry => _entryType == TransactionEntryType.income;

  TransactionCategory? get _systemGeneralIncomeCategory =>
      _incomeCategories
          .where(
            (c) => c.id == DatabaseConstants.systemGeneralIncomeCategoryId,
          )
          .firstOrNull;

  double? get _debtAmountValue =>
      _parsePositiveDouble(_debtAmountController.text);

  List<Treasury> _eligibleWalletsFor(String? currencyId) {
    final currency = _currencies.where((c) => c.id == currencyId).firstOrNull;
    if (currency == null) return [];

    return regularTreasuries(
      context.read<WalletProvider>().treasuries.where((treasury) {
        return treasury.accounts.any(
          (a) => a.currencyCode.toUpperCase() == currency.code.toUpperCase(),
        );
      }),
    );
  }

  List<Treasury> get _eligibleWallets =>
      _eligibleWalletsFor(_selectedCurrencyId);

  List<Treasury> get _eligibleSourceWallets =>
      _eligibleWalletsFor(_sourceCurrencyId);

  List<Treasury> get _eligibleTargetWallets =>
      _eligibleWalletsFor(_targetCurrencyId);

  void _syncExchangeRateFromCurrencies() {
    final source = _sourceCurrency;
    final target = _targetCurrency;
    if (source == null || target == null) return;

    final rated = ExchangeRateDisplay.ratedCurrency(source: source, target: target);
    _exchangeRateController.text =
        ExchangeRateDisplay.defaultDisplayRateText(rated);
  }

  double? get _displayExchangeRateValue =>
      ExchangeRateDisplay.parseDisplayRate(_exchangeRateController.text);

  double? get _transferConvertedPreview {
    final source = _sourceCurrency;
    final target = _targetCurrency;
    final amount = _transferAmountValue;
    final displayRate = _displayExchangeRateValue;
    if (source == null ||
        target == null ||
        amount == null ||
        displayRate == null) {
      return null;
    }
    return ExchangeRateDisplay.resolveTransferTargetAmount(
      sourceAmount: amount,
      source: source,
      target: target,
      displayRate: displayRate,
    );
  }

  double? _parsePositiveDouble(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    final value = double.tryParse(normalized);
    if (value == null || value <= 0) return null;
    return value;
  }

  double? get _transferAmountValue =>
      _parsePositiveDouble(_transferAmountController.text);

  List<Currency> get _currencies =>
      uniqueCurrenciesByCode(context.read<CurrencyProvider>().currencies);

  Currency? get _selectedCurrency => _currencies
      .where((c) => c.id == _selectedCurrencyId)
      .firstOrNull;

  Currency? get _sourceCurrency => _currencies
      .where((c) => c.id == _sourceCurrencyId)
      .firstOrNull;

  Currency? get _targetCurrency => _currencies
      .where((c) => c.id == _targetCurrencyId)
      .firstOrNull;

  void _syncWalletAndCategoryDefaults() {
    if (_isDebtMode) {
      final wallets = _eligibleWallets;
      setState(() {
        if (wallets.every((w) => w.id != _selectedWalletId)) {
          _selectedWalletId = wallets.firstOrNull?.id;
        }
      });
      return;
    }

    if (_isTransferMode) {
      final sourceWallets = _eligibleSourceWallets;
      final targetWallets = _eligibleTargetWallets;
      setState(() {
        if (sourceWallets.every((w) => w.id != _sourceWalletId)) {
          _sourceWalletId = sourceWallets.firstOrNull?.id;
        }
        if (targetWallets.every((w) => w.id != _targetWalletId)) {
          _targetWalletId = targetWallets.firstOrNull?.id;
        }
      });
      return;
    }

    final wallets = _eligibleWallets;
    final categories = _activeCategories;

    setState(() {
      if (wallets.every((w) => w.id != _selectedWalletId)) {
        _selectedWalletId = wallets.firstOrNull?.id;
      }
      if (_isIncomeEntry) {
        _selectedCategoryId = _systemGeneralIncomeCategory?.id;
      } else if (_entryType == TransactionEntryType.expense) {
        final generalExpense = categories
            .where(
              (c) =>
                  c.id == DatabaseConstants.systemGeneralExpenseCategoryId,
            )
            .firstOrNull;
        if (_selectedCategoryId == null && generalExpense != null) {
          _selectedCategoryId = generalExpense.id;
        } else if (categories.every((c) => c.id != _selectedCategoryId)) {
          _selectedCategoryId = categories.firstOrNull?.id;
        }
      } else if (categories.every((c) => c.id != _selectedCategoryId)) {
        _selectedCategoryId = categories.firstOrNull?.id;
      }
    });
  }

  void _onEntryTypeChanged(TransactionEntryType type) {
    _clearFormFeedback();
    setState(() {
      _entryType = type;
      _isExpense = type == TransactionEntryType.expense;
      if (type != TransactionEntryType.currencyTransfer) {
        _selectedCategoryId = null;
      }
    });
    if (type == TransactionEntryType.currencyTransfer) {
      _syncExchangeRateFromCurrencies();
    }
    _syncWalletAndCategoryDefaults();
  }

  void _onSourceCurrencySelected(String id) {
    setState(() {
      _sourceCurrencyId = id;
      _sourceWalletId = null;
    });
    _syncWalletAndCategoryDefaults();
    _syncExchangeRateFromCurrencies();
  }

  void _onTargetCurrencySelected(String id) {
    setState(() {
      _targetCurrencyId = id;
      _targetWalletId = null;
    });
    _syncWalletAndCategoryDefaults();
    _syncExchangeRateFromCurrencies();
  }

  void _onCurrencySelected(String currencyId) {
    setState(() {
      _selectedCurrencyId = currencyId;
      _selectedWalletId = null;
    });
    _syncWalletAndCategoryDefaults();
  }

  void _onDigit(int digit) {
    setState(() => _amountInput.appendDigit(digit));
  }

  void _onDoubleZero() {
    setState(() => _amountInput.appendDoubleZero());
  }

  void _onDecimal() {
    setState(() => _amountInput.startDecimal());
  }

  void _onThousandsSeparator() {
    setState(() => _amountInput.toggleThousandsSeparators());
  }

  void _onBackspace() {
    setState(() => _amountInput.backspace());
  }

  void _clearFormFeedback() {
    _feedbackDismissTimer?.cancel();
    if (_feedbackMessage == null && _feedbackType == null) return;
    setState(() {
      _feedbackMessage = null;
      _feedbackType = null;
    });
  }

  void _showFormFeedback(
    FormFeedbackType type,
    String message, {
    bool autoDismiss = false,
  }) {
    _feedbackDismissTimer?.cancel();
    setState(() {
      _feedbackType = type;
      _feedbackMessage = message;
    });
    if (autoDismiss) {
      _feedbackDismissTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) _clearFormFeedback();
      });
    }
  }

  void _showFormSuccess(String message) {
    _showFormFeedback(FormFeedbackType.success, message, autoDismiss: true);
  }

  void _showFormWarning(String message) {
    _showFormFeedback(FormFeedbackType.warning, message);
  }

  void _showFormError(Object error) {
    _showFormFeedback(
      FormFeedbackType.error,
      UserFacingError.transactionMessage(context.l10n, error),
    );
  }

  Future<void> _pickDate() async {
    final locale = Localizations.localeOf(context);
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      locale: locale,
      helpText: context.l10n.transactionFormDate,
    );

    if (picked != null && mounted) {
      setState(() => _transactionDate = picked);
    }
  }

  void _showMoreCategoriesPlaceholder() {
    final type = _entryType == TransactionEntryType.income
        ? DatabaseConstants.categoryIncome
        : DatabaseConstants.categoryExpense;
    _openCategoriesManager(type);
  }

  Future<void> _openCategoriesManager(String type) async {
    await context.push('/categories?type=$type');
    if (!mounted) return;
    await _reloadCategories();
  }

  Future<void> _reloadCategories() async {
    final categoryService = CategoryService(LazarusDatabaseService.instance);
    final expense = await categoryService.getExpenseCategories();
    final income = await categoryService.getIncomeCategories();
    if (!mounted) return;
    setState(() {
      _expenseCategories = expense;
      _incomeCategories = income;
    });
    _syncWalletAndCategoryDefaults();
  }

  Future<void> _pickDueDate() async {
    final locale = Localizations.localeOf(context);
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
      locale: locale,
      helpText: context.l10n.transactionFormDueDate,
    );

    if (picked != null && mounted) {
      setState(() => _dueDate = picked);
    }
  }

  /// Shows a bottom-sheet confirmation for financially significant actions
  /// (transfers and debts). Returns [true] if the user confirms.
  Future<bool> _showConfirmSheet() async {
    final l10n = context.l10n;
    final colors = context.appColors;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 20),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.bottomSheetBorderRadius,
            boxShadow: Theme.of(context).brightness == Brightness.dark
                ? AppShadow.clayHeroDark
                : AppShadow.clayHeroLight,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius:
                          BorderRadius.circular(AppRadius.iconBadge),
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.transactionConfirmTitle,
                          style: AppTextStyles.headingSmall.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          l10n.transactionConfirmSubtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(l10n.commonCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(l10n.transactionConfirmSave),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    return result ?? false;
  }

  Future<void> _save() async {
    final l10n = context.l10n;

    if (_isDebtMode) {
      final confirmed = await _showConfirmSheet();
      if (!confirmed) return;
      await _saveDebt(l10n);
      return;
    }

    if (_isTransferMode) {
      final confirmed = await _showConfirmSheet();
      if (!confirmed) return;
      await _saveTransfer(l10n);
      return;
    }

    if (_amountInput.value <= 0) {
      _showFormWarning(l10n.transactionFormAmountRequired);
      return;
    }

    final currency = _selectedCurrency;
    if (currency == null) {
      _showFormWarning(l10n.transactionFormSelectCurrency);
      return;
    }

    if (_selectedWalletId == null) {
      _showFormWarning(l10n.transactionFormSelectWallet);
      return;
    }

    final category = _isIncomeEntry
        ? _systemGeneralIncomeCategory
        : _activeCategories
            .where((c) => c.id == _selectedCategoryId)
            .firstOrNull;

    if (category == null) {
      _showFormWarning(
        _isIncomeEntry
            ? l10n.transactionFormCategoryUnavailable
            : l10n.transactionFormSelectCategory,
      );
      return;
    }

    if (_splitEnabled && _splitParticipants.where((p) => p.hasIdentity).isEmpty) {
      _showFormWarning(l10n.transactionSplitParticipantsRequired);
      return;
    }

    setState(() => _isSaving = true);

    final hadSplit = _splitEnabled;
    final splitParticipants =
        List<SplitParticipantDraft>.from(_splitParticipants);
    final splitMode = _splitMode;
    final splitIncludeSelf = _splitIncludeSelf;
    final splitFixedAmount = _splitFixedAmountPerPerson;
    final savedAmount = _amountInput.value;
    final savedCategoryName = category.name;
    final savedCurrencyCode = currency.code;
    final savedDate = _transactionDate;

    try {
      final splitService =
          TransactionSplitService(LazarusDatabaseService.instance);
      await splitService.create(
        CreateSplitTransactionInput(
          walletId: _selectedWalletId!,
          category: category,
          type: _isExpense
              ? DatabaseConstants.txExpense
              : DatabaseConstants.txIncome,
          amount: _amountInput.value,
          currency: currency,
          notes: _notesController.text,
          transactionDate: _transactionDate,
          splitEnabled: _splitEnabled,
          splitMode: _splitMode,
          includeSelfInEqualSplit: _splitIncludeSelf,
          fixedAmountPerPerson: _splitFixedAmountPerPerson,
          participants: _splitParticipants,
        ),
      );

      if (!mounted) return;
      await context.read<WalletProvider>().loadWallets();
      if (!mounted) return;

      context.read<DashboardRefreshProvider>().notifyRefresh();

      if (hadSplit &&
          splitParticipants.any((participant) => participant.hasIdentity)) {
        final waParticipants = _whatsappParticipantsFromSplit(
          participants: splitParticipants,
          totalAmount: savedAmount,
          splitMode: splitMode,
          includeSelfInEqualSplit: splitIncludeSelf,
          fixedAmountPerPerson: splitFixedAmount,
        );
        if (waParticipants.isNotEmpty) {
          await SplitWhatsAppSuccessSheet.show(
            context,
            participants: waParticipants,
            transactionTitle: savedCategoryName,
            currencyCode: savedCurrencyCode,
            transactionDate: savedDate,
            localeName: Localizations.localeOf(context).toString(),
          );
        }
      }

      _resetFormAfterSave();

      _showFormSuccess(l10n.transactionFormSaveSuccess);
    } catch (e) {
      if (mounted) {
        _showFormError(e);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveTransfer(AppLocalizations l10n) async {
    final source = _sourceCurrency;
    final target = _targetCurrency;
    final amount = _transferAmountValue;
    final displayRate = _displayExchangeRateValue;

    if (source == null) {
      _showFormWarning(l10n.transactionFormSelectSourceCurrency);
      return;
    }
    if (target == null) {
      _showFormWarning(l10n.transactionFormSelectTargetCurrency);
      return;
    }
    if (amount == null) {
      _showFormWarning(l10n.transactionFormAmountRequired);
      return;
    }
    if (displayRate == null) {
      _showFormWarning(l10n.transactionFormExchangeRateRequired);
      return;
    }
    if (_sourceWalletId == null) {
      _showFormWarning(l10n.transactionFormSelectSourceWallet);
      return;
    }
    if (_targetWalletId == null) {
      _showFormWarning(l10n.transactionFormSelectTargetWallet);
      return;
    }
    if (source.id == target.id && _sourceWalletId == _targetWalletId) {
      _showFormWarning(l10n.transactionFormTransferSameError);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final currencyProvider = context.read<CurrencyProvider>();
      await ExchangeRateDisplay.persistDisplayRateIfChanged(
        provider: currencyProvider,
        source: source,
        target: target,
        rateText: _exchangeRateController.text,
      );

      final freshSource =
          ExchangeRateDisplay.findCurrency(currencyProvider, source) ?? source;
      final freshTarget =
          ExchangeRateDisplay.findCurrency(currencyProvider, target) ?? target;

      await TransferService(LazarusDatabaseService.instance).createCurrencyTransfer(
        CreateCurrencyTransferInput(
          fromWalletId: _sourceWalletId!,
          toWalletId: _targetWalletId!,
          sourceCurrency: freshSource,
          targetCurrency: freshTarget,
          sourceAmount: amount,
          notes: _notesController.text,
          transactionDate: _transactionDate,
        ),
      );

      if (!mounted) return;
      await context.read<WalletProvider>().loadWallets();
      context.read<DashboardRefreshProvider>().notifyRefresh();
      _resetFormAfterSave();

      _showFormSuccess(l10n.transactionFormTransferSaveSuccess);
    } catch (e) {
      if (mounted) {
        _showFormError(e);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveDebt(AppLocalizations l10n) async {
    final person = _personNameController.text.trim();
    if (person.isEmpty) {
      _showFormWarning(l10n.transactionFormPersonNameRequired);
      return;
    }

    final amount = _debtAmountValue;
    if (amount == null) {
      _showFormWarning(l10n.transactionFormAmountRequired);
      return;
    }

    final currency = _selectedCurrency;
    if (currency == null) {
      _showFormWarning(l10n.transactionFormSelectCurrency);
      return;
    }

    if (_selectedWalletId == null) {
      _showFormWarning(l10n.transactionFormSelectWallet);
      return;
    }

    final txType = _entryType == TransactionEntryType.debtor
        ? DatabaseConstants.txDebtor
        : DatabaseConstants.txCreditor;

    setState(() => _isSaving = true);
    try {
      await DebtService(LazarusDatabaseService.instance).create(
        CreateDebtEntryInput(
          type: txType,
          walletId: _selectedWalletId!,
          personName: person,
          contactId: _debtContactId,
          phone: _debtContactPhone,
          amount: amount,
          currency: currency,
          dueDate: _dueDate,
          notes: _notesController.text,
          transactionDate: _transactionDate,
        ),
      );

      if (!mounted) return;
      context.read<DashboardRefreshProvider>().notifyRefresh();
      _resetFormAfterSave();

      _showFormSuccess(l10n.transactionFormDebtSaveSuccess);
    } catch (e) {
      if (mounted) {
        _showFormError(e);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _resetFormAfterSave() {
    _amountInput.reset();
    _transferAmountController.clear();
    _personNameController.clear();
    _debtContactId = null;
    _debtContactPhone = null;
    _debtAmountController.clear();
    _splitEnabled = false;
    _splitMode = SplitConstants.modeEqual;
    _splitIncludeSelf = true;
    _splitFixedAmountPerPerson = null;
    _splitParticipants = const [];
    _notesController.clear();
    _dueDate = null;
    _transactionDate = DateTime.now();
    _syncExchangeRateFromCurrencies();
    setState(() {});
  }

  String _formatDateLabel(AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected =
        DateTime(_transactionDate.year, _transactionDate.month, _transactionDate.day);
    final formatted = AppDateFormatter.format(_transactionDate);

    if (selected == today) {
      return l10n.transactionFormTodayDate(formatted);
    }

    return formatted;
  }

  @override
  void dispose() {
    _feedbackDismissTimer?.cancel();
    _notesScrollDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _notesFocusNode.removeListener(_onNotesFocusChanged);
    _notesFocusNode.dispose();
    _scrollController.dispose();
    _notesController.dispose();
    _transferAmountController.dispose();
    _exchangeRateController.dispose();
    _personNameController.dispose();
    _debtAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final currencies = context.watch<CurrencyProvider>().currencies;
    final uniqueCurrencies = uniqueCurrenciesByCode(currencies);
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: AuthBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TransactionTopBar(
            title: l10n.appName,
            onClose: () => context.pop(),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : FormPageLayout(
                    padding: EdgeInsetsDirectional.zero,
                    child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      16 + keyboardInset + _saveButtonAreaHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TransactionTypeToggle(
                          selected: _entryType,
                          expenseLabel: l10n.transactionFormExpense,
                          incomeLabel: l10n.transactionFormIncome,
                          transferLabel: l10n.transactionFormCurrencyTransfer,
                          debtorLabel: l10n.transactionFormDebtor,
                          creditorLabel: l10n.transactionFormCreditor,
                          onChanged: _onEntryTypeChanged,
                        ),
                        const SizedBox(height: 20),
                        if (_isDebtMode) ...[
                          PersonPickerField(
                            label: l10n.transactionFormPersonName,
                            hint: l10n.transactionFormPersonNameHint,
                            showPhoneField: true,
                            onChanged: (selection) {
                              _debtContactId = selection.contactId;
                              _personNameController.text =
                                  selection.displayName;
                              final phone = selection.phone?.trim();
                              _debtContactPhone =
                                  (phone == null || phone.isEmpty)
                                      ? null
                                      : phone;
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.transactionFormAmountLabel,
                            style: AppFormFields.sectionLabelStyleOf(context),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _debtAmountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: AppFormFields.inputTextStyleOf(context),
                            decoration: AppFormFields.decoration(
                              context,
                              hintText: l10n.transactionFormAmountHint,
                            ).copyWith(
                              suffixText: _selectedCurrency?.code,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TransactionCurrencyPills(
                            currencies: uniqueCurrencies,
                            selectedCurrencyId: _selectedCurrencyId,
                            onSelected: _onCurrencySelected,
                          ),
                          const SizedBox(height: 10),
                          TransactionWalletCarousel(
                            treasuries: _eligibleWallets,
                            currencyCode: _selectedCurrency?.code ?? '',
                            selectedWalletId: _selectedWalletId,
                            onSelected: (id) =>
                                setState(() => _selectedWalletId = id),
                            emptyLabel: l10n.transactionFormNoWalletForCurrency,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.transactionFormDebtLedgerHint,
                            style: AppTextStyles.captionOnSurface(colors),
                          ),
                          const SizedBox(height: 20),
                          _SectionHeader(
                            title: l10n.transactionFormDueDate,
                            icon: Icons.event_outlined,
                          ),
                          const SizedBox(height: 10),
                          _DateBar(
                            dateLabel: _dueDate != null
                                ? AppDateFormatter.format(_dueDate!)
                                : l10n.transactionFormDueDateOptional,
                            changeLabel: _dueDate == null
                                ? l10n.transactionFormChangeDate
                                : l10n.transactionFormClearDueDate,
                            onChange: _dueDate == null
                                ? _pickDueDate
                                : () => setState(() => _dueDate = null),
                          ),
                        ] else if (_isTransferMode) ...[
                          Text(
                            l10n.transactionFormAmountLabel,
                            style: AppFormFields.sectionLabelStyleOf(context),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _transferAmountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: AppFormFields.inputTextStyleOf(context),
                            decoration: AppFormFields.decoration(
                              context,
                              hintText: l10n.transactionFormAmountHint,
                            ).copyWith(
                              suffixText: _sourceCurrency?.code,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.transactionFormSourceCurrency,
                            style: AppFormFields.sectionLabelStyleOf(context),
                          ),
                          const SizedBox(height: 8),
                          TransactionCurrencyPills(
                            currencies: uniqueCurrencies,
                            selectedCurrencyId: _sourceCurrencyId,
                            onSelected: _onSourceCurrencySelected,
                          ),
                          const SizedBox(height: 10),
                          TransactionWalletCarousel(
                            treasuries: _eligibleSourceWallets,
                            currencyCode: _sourceCurrency?.code ?? '',
                            selectedWalletId: _sourceWalletId,
                            onSelected: (id) =>
                                setState(() => _sourceWalletId = id),
                            emptyLabel: l10n.transactionFormNoWalletForCurrency,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.transactionFormTargetCurrency,
                            style: AppFormFields.sectionLabelStyleOf(context),
                          ),
                          const SizedBox(height: 8),
                          TransactionCurrencyPills(
                            currencies: uniqueCurrencies,
                            selectedCurrencyId: _targetCurrencyId,
                            onSelected: _onTargetCurrencySelected,
                          ),
                          const SizedBox(height: 10),
                          TransactionWalletCarousel(
                            treasuries: _eligibleTargetWallets,
                            currencyCode: _targetCurrency?.code ?? '',
                            selectedWalletId: _targetWalletId,
                            onSelected: (id) =>
                                setState(() => _targetWalletId = id),
                            emptyLabel: l10n.transactionFormNoWalletForCurrency,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.transactionFormExchangeRate,
                            style: AppFormFields.sectionLabelStyleOf(context),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _exchangeRateController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: AppFormFields.inputTextStyleOf(context),
                            decoration: AppFormFields.decoration(
                              context,
                              labelText: l10n.currencyFormRateLabel(
                                context
                                        .watch<CurrencyProvider>()
                                        .baseCurrency
                                        ?.code ??
                                    '—',
                              ),
                              hintText: l10n.currencyFormRateHint,
                            ).copyWith(
                              helperText: _sourceCurrency != null &&
                                      _targetCurrency != null
                                  ? l10n.currencyFormRateHelper(
                                      context
                                              .watch<CurrencyProvider>()
                                              .baseCurrency
                                              ?.code ??
                                          '—',
                                      ExchangeRateDisplay.ratedCurrency(
                                        source: _sourceCurrency!,
                                        target: _targetCurrency!,
                                      ).code,
                                    )
                                  : null,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            onChanged: (_) => setState(() {}),
                          ),
                          if (_transferConvertedPreview != null &&
                              _targetCurrency != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              l10n.transactionFormConvertedAmount(
                                CurrencyFormatter.formatCodeFirst(
                                  _transferConvertedPreview!,
                                  _targetCurrency!.code,
                                ),
                              ),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.captionOnSurface(colors),
                            ),
                          ],
                        ] else ...[
                          Text(
                            l10n.transactionFormAmountLabel,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _amountInput.display,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.headingLarge.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 42,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TransactionCurrencyPills(
                            currencies: uniqueCurrencies,
                            selectedCurrencyId: _selectedCurrencyId,
                            onSelected: _onCurrencySelected,
                          ),
                          const SizedBox(height: 16),
                          TransactionNumericKeypad(
                            onDigit: _onDigit,
                            onDecimal: _onDecimal,
                            onThousandsSeparator: _onThousandsSeparator,
                            onDoubleZero: _onDoubleZero,
                            onBackspace: _onBackspace,
                            showThousandsSeparatorKey:
                                NumberFormatPreferences
                                    .current
                                    .thousandsSeparator
                                    .isNotEmpty,
                          ),
                          const SizedBox(height: 22),
                          _SectionHeader(
                            title: l10n.transactionFormWallet,
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                          const SizedBox(height: 10),
                          TransactionWalletCarousel(
                            treasuries: _eligibleWallets,
                            currencyCode: _selectedCurrency?.code ?? '',
                            selectedWalletId: _selectedWalletId,
                            onSelected: (id) =>
                                setState(() => _selectedWalletId = id),
                            emptyLabel: l10n.transactionFormNoWalletForCurrency,
                          ),
                          if (_entryType == TransactionEntryType.expense) ...[
                            const SizedBox(height: 22),
                            _SectionHeader(
                              title: l10n.transactionFormCategory,
                              icon: Icons.category_outlined,
                            ),
                            const SizedBox(height: 10),
                            TransactionCategoryGrid(
                              categories: _activeCategories,
                              selectedCategoryId: _selectedCategoryId,
                              onSelected: (category) => setState(
                                () => _selectedCategoryId = category.id,
                              ),
                              moreLabel: l10n.transactionFormMore,
                              onMoreTap: _showMoreCategoriesPlaceholder,
                            ),
                          ],
                          const SizedBox(height: 22),
                          _SectionHeader(
                            title: l10n.transactionSplitEnable,
                            icon: Icons.groups_outlined,
                          ),
                          const SizedBox(height: 10),
                          TransactionSplitSection(
                            totalAmount: _amountInput.value,
                            currencyCode: _selectedCurrency?.code ?? '',
                            transactionTitle: (_isIncomeEntry
                                    ? _incomeCategories
                                    : _expenseCategories)
                                .where((c) => c.id == _selectedCategoryId)
                                .firstOrNull
                                ?.name ??
                                '',
                            transactionDate: _transactionDate,
                            onChanged: (state) {
                              _splitEnabled = state.enabled;
                              _splitMode = state.mode;
                              _splitIncludeSelf = state.includeSelfInEqualSplit;
                              _splitFixedAmountPerPerson =
                                  state.fixedAmountPerPerson;
                              _splitParticipants = state.participants;
                            },
                          ),
                        ],
                        const SizedBox(height: 22),
                        _SectionHeader(
                          title: l10n.transactionFormNotes,
                          icon: Icons.notes_outlined,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          key: _notesFieldKey,
                          controller: _notesController,
                          focusNode: _notesFocusNode,
                          maxLines: 3,
                          textInputAction: TextInputAction.done,
                          style: AppFormFields.inputTextStyleOf(context),
                          scrollPadding: EdgeInsets.zero,
                          decoration: AppFormFields.decoration(
                            context,
                            hintText: l10n.transactionFormNotesHint,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DateBar(
                          dateLabel: _formatDateLabel(l10n),
                          changeLabel: l10n.transactionFormChangeDate,
                          onChange: _pickDate,
                        ),
                      ],
                    ),
                  ),
                ),
          ),
          if (_feedbackMessage != null && _feedbackType != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: FormFeedbackBanner(
                message: _feedbackMessage!,
                type: _feedbackType!,
                onDismiss: _clearFormFeedback,
              ),
            ),
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_outlined, color: colors.onPrimary, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          l10n.transactionFormSave,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  List<SplitWhatsAppParticipant> _whatsappParticipantsFromSplit({
    required List<SplitParticipantDraft> participants,
    required double totalAmount,
    required String splitMode,
    required bool includeSelfInEqualSplit,
    required double? fixedAmountPerPerson,
  }) {
    final withIdentity =
        participants.where((participant) => participant.hasIdentity).toList();
    if (withIdentity.isEmpty || totalAmount <= 0) return const [];

    try {
      final calculation = SplitCalculator.calculate(
        totalAmount: totalAmount,
        splitMode: splitMode,
        participants: withIdentity
            .map(
              (participant) => SplitParticipantInput(
                contactId: participant.contactId ??
                    participant.contactName!.trim(),
                percent: participant.percent,
                fixedAmount: participant.fixedAmount,
              ),
            )
            .toList(),
        includeSelfInEqualSplit: includeSelfInEqualSplit,
        fixedAmountPerPerson: fixedAmountPerPerson,
      );

      final result = <SplitWhatsAppParticipant>[];
      for (var i = 0; i < withIdentity.length; i++) {
        final participant = withIdentity[i];
        final share = i < calculation.participantShares.length
            ? calculation.participantShares[i].shareAmount
            : 0.0;
        if (share <= 0) continue;
        result.add(
          SplitWhatsAppParticipant(
            name: participant.contactName?.trim() ?? '',
            phone: participant.phone,
            shareAmount: share,
          ),
        );
      }
      return result;
    } catch (_) {
      return const [];
    }
  }
}

class _TransactionTopBar extends StatelessWidget {
  const _TransactionTopBar({
    required this.title,
    required this.onClose,
  });

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Expanded(
            child: Center(
              child: BrandLogoImage(height: 28, fit: BoxFit.contain),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 26),
            color: colors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
      ],
    );
  }
}

class _DateBar extends StatelessWidget {
  const _DateBar({
    required this.dateLabel,
    required this.changeLabel,
    required this.onChange,
  });

  final String dateLabel;
  final String changeLabel;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: onChange,
            child: Text(
              changeLabel,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          Text(
            dateLabel,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.calendar_month_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
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
