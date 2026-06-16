import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/database_constants.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/helpers/currency_formatter.dart';
import '../../core/helpers/currency_uniqueness.dart';
import '../../core/theme/app_form_fields.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/auth_background.dart';
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
import '../../services/transaction_service.dart';
import '../../services/transfer_service.dart';
import 'models/transaction_entry_type.dart';
import 'widgets/transaction_category_grid.dart';
import 'widgets/transaction_currency_pills.dart';
import 'widgets/transaction_numeric_keypad.dart';
import 'widgets/transaction_type_toggle.dart';
import 'widgets/transaction_wallet_carousel.dart';

/// Add income, expense, transfer, or debt ledger entry.
class TransactionAddScreen extends StatefulWidget {
  const TransactionAddScreen({super.key, this.initialEntryType});

  final TransactionEntryType? initialEntryType;

  @override
  State<TransactionAddScreen> createState() => _TransactionAddScreenState();
}

class _TransactionAddScreenState extends State<TransactionAddScreen> {
  static const _logoAsset = 'assets/images/logo_amanah.png';

  final _amountInput = TransactionAmountInput();
  final _notesController = TextEditingController();
  final _transferAmountController = TextEditingController();
  final _exchangeRateController = TextEditingController();
  final _personNameController = TextEditingController();
  final _debtAmountController = TextEditingController();

  bool _isExpense = true;
  TransactionEntryType _entryType = TransactionEntryType.expense;
  bool _isLoading = true;
  bool _isSaving = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
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

  double? get _debtAmountValue =>
      _parsePositiveDouble(_debtAmountController.text);

  List<Treasury> _eligibleWalletsFor(String? currencyId) {
    final currency = _currencies.where((c) => c.id == currencyId).firstOrNull;
    if (currency == null) return [];

    return context.read<WalletProvider>().treasuries.where((treasury) {
      return treasury.accounts.any(
        (a) => a.currencyCode.toUpperCase() == currency.code.toUpperCase(),
      );
    }).toList();
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

    final rate = TransferService.defaultCrossRate(
      source: source,
      target: target,
    );
    _exchangeRateController.text = _formatRate(rate);
  }

  String _formatRate(double rate) {
    if (rate == rate.roundToDouble()) {
      return rate.toStringAsFixed(0);
    }
    return rate.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
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

  double? get _crossExchangeRateValue =>
      _parsePositiveDouble(_exchangeRateController.text);

  double? get _transferConvertedPreview {
    final source = _sourceCurrency;
    final target = _targetCurrency;
    final amount = _transferAmountValue;
    final rate = _crossExchangeRateValue;
    if (source == null || target == null || amount == null || rate == null) {
      return null;
    }
    return TransferService.resolveTargetAmount(
      sourceAmount: amount,
      source: source,
      target: target,
      crossExchangeRate: rate,
    );
  }

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
      if (categories.every((c) => c.id != _selectedCategoryId)) {
        _selectedCategoryId = categories.firstOrNull?.id;
      }
    });
  }

  void _onEntryTypeChanged(TransactionEntryType type) {
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

  void _onBackspace() {
    setState(() => _amountInput.backspace());
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.transactionFormCategoriesComingSoon)),
    );
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

  Future<void> _save() async {
    final l10n = context.l10n;

    if (_isDebtMode) {
      await _saveDebt(l10n);
      return;
    }

    if (_isTransferMode) {
      await _saveTransfer(l10n);
      return;
    }

    if (_amountInput.value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormAmountRequired)),
      );
      return;
    }

    final currency = _selectedCurrency;
    if (currency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormSelectCurrency)),
      );
      return;
    }

    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormSelectWallet)),
      );
      return;
    }

    final category = _activeCategories
        .where((c) => c.id == _selectedCategoryId)
        .firstOrNull;

    if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormSelectCategory)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await TransactionService(LazarusDatabaseService.instance).create(
        CreateTransactionInput(
          walletId: _selectedWalletId!,
          category: category,
          type: _isExpense
              ? DatabaseConstants.txExpense
              : DatabaseConstants.txIncome,
          amount: _amountInput.value,
          currency: currency,
          notes: _notesController.text,
          transactionDate: _transactionDate,
        ),
      );

      if (!mounted) return;
      await context.read<WalletProvider>().loadWallets();
      if (!mounted) return;

      context.read<DashboardRefreshProvider>().notifyRefresh();
      _resetFormAfterSave();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormSaveSuccess)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.transactionFormSaveError(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveTransfer(AppLocalizations l10n) async {
    final source = _sourceCurrency;
    final target = _targetCurrency;
    final amount = _transferAmountValue;
    final crossRate = _crossExchangeRateValue;

    if (source == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormSelectSourceCurrency)),
      );
      return;
    }
    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormSelectTargetCurrency)),
      );
      return;
    }
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormAmountRequired)),
      );
      return;
    }
    if (crossRate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormExchangeRateRequired)),
      );
      return;
    }
    if (_sourceWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormSelectSourceWallet)),
      );
      return;
    }
    if (_targetWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormSelectTargetWallet)),
      );
      return;
    }
    if (source.id == target.id && _sourceWalletId == _targetWalletId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormTransferSameError)),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await TransferService(LazarusDatabaseService.instance).createCurrencyTransfer(
        CreateCurrencyTransferInput(
          fromWalletId: _sourceWalletId!,
          toWalletId: _targetWalletId!,
          sourceCurrency: source,
          targetCurrency: target,
          sourceAmount: amount,
          crossExchangeRate: crossRate,
          notes: _notesController.text,
          transactionDate: _transactionDate,
        ),
      );

      if (!mounted) return;
      await context.read<WalletProvider>().loadWallets();
      context.read<DashboardRefreshProvider>().notifyRefresh();
      _resetFormAfterSave();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormTransferSaveSuccess)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.transactionFormSaveError(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveDebt(AppLocalizations l10n) async {
    final person = _personNameController.text.trim();
    if (person.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormPersonNameRequired)),
      );
      return;
    }

    final amount = _debtAmountValue;
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormAmountRequired)),
      );
      return;
    }

    final currency = _selectedCurrency;
    if (currency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormSelectCurrency)),
      );
      return;
    }

    if (_selectedWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormSelectWallet)),
      );
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionFormDebtSaveSuccess)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.transactionFormSaveError(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _resetFormAfterSave() {
    _amountInput.reset();
    _transferAmountController.clear();
    _personNameController.clear();
    _debtAmountController.clear();
    _notesController.clear();
    _dueDate = null;
    _transactionDate = DateTime.now();
    _syncExchangeRateFromCurrencies();
    setState(() {});
  }

  String _formatDateLabel(AppLocalizations l10n, String locale) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected =
        DateTime(_transactionDate.year, _transactionDate.month, _transactionDate.day);

    if (selected == today) {
      return l10n.transactionFormTodayDate(
        DateFormat.yMMMMd(locale).format(_transactionDate),
      );
    }

    return DateFormat.yMMMMd(locale).format(_transactionDate);
  }

  @override
  void dispose() {
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
    final locale = Localizations.localeOf(context).toString();
    final currencies = context.watch<CurrencyProvider>().currencies;
    final uniqueCurrencies = uniqueCurrenciesByCode(currencies);

    return AuthBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TransactionTopBar(
            title: l10n.appName,
            logoAsset: _logoAsset,
            onClose: () => context.pop(),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
                          Text(
                            l10n.transactionFormPersonName,
                            style: AppFormFields.sectionLabelStyleOf(context),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _personNameController,
                            textCapitalization: TextCapitalization.words,
                            style: AppFormFields.inputTextStyleOf(context),
                            decoration: AppFormFields.decoration(
                              context,
                              hintText: l10n.transactionFormPersonNameHint,
                            ),
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
                                ? DateFormat.yMMMMd(locale).format(_dueDate!)
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
                              hintText: l10n.transactionFormExchangeRateHint(
                                _sourceCurrency?.code ?? '—',
                                _targetCurrency?.code ?? '—',
                              ),
                            ),
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
                          Text(
                            _amountInput.display,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headingLarge.copyWith(
                              color: AppColors.dashboardPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 42,
                              height: 1.1,
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
                            onBackspace: _onBackspace,
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
                          title: l10n.transactionFormNotes,
                          icon: Icons.notes_outlined,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          style: AppFormFields.inputTextStyleOf(context),
                          decoration: AppFormFields.decoration(
                            context,
                            hintText: l10n.transactionFormNotesHint,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DateBar(
                          dateLabel: _formatDateLabel(l10n, locale),
                          changeLabel: l10n.transactionFormChangeDate,
                          onChange: _pickDate,
                        ),
                      ],
                    ),
                  ),
          ),
          Padding(
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
    );
  }
}

class _TransactionTopBar extends StatelessWidget {
  const _TransactionTopBar({
    required this.title,
    required this.logoAsset,
    required this.onClose,
  });

  final String title;
  final String logoAsset;
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
              color: AppColors.dashboardPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                logoAsset,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
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
        Icon(icon, color: AppColors.dashboardPrimary, size: 22),
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
                color: AppColors.dashboardPrimary,
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
          const Icon(
            Icons.calendar_month_outlined,
            color: AppColors.dashboardPrimary,
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
