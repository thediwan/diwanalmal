import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/split_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/database_constants.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/helpers/app_date_formatter.dart';
import '../../core/helpers/currency_formatter.dart';
import '../../core/helpers/exchange_rate_display.dart';
import '../../core/helpers/number_format_preferences.dart';
import '../../core/helpers/currency_uniqueness.dart';
import '../../core/helpers/treasury_filters.dart';
import '../../core/helpers/user_facing_error.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/theme/app_form_fields.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';
import '../../models/currency.dart';
import '../../models/treasury.dart';
import '../../models/transaction_category.dart';
import '../../providers/currency_provider.dart';
import '../../providers/dashboard_refresh_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../database/daos/finance_dao.dart';
import '../../services/category_service.dart';
import '../../core/helpers/whatsapp_message_helper.dart';
import '../../services/debt_service.dart';
import '../../services/lazarus_database_service.dart';
import '../../services/transaction_split_service.dart';
import '../../services/transfer_service.dart';
import '../../services/whatsapp_service.dart';
import '../contacts/widgets/person_picker_field.dart';
import 'models/transaction_list_item.dart';
import 'widgets/debt_settlement_sheet.dart';
import 'widgets/form_feedback_banner.dart';
import 'widgets/transaction_category_grid.dart';
import 'widgets/transaction_currency_pills.dart';
import 'widgets/transaction_numeric_keypad.dart';
import 'widgets/transaction_split_section.dart';
import 'widgets/transaction_wallet_carousel.dart';
import '../../core/extensions/context_feedback.dart';

/// Edit an existing income, expense, or currency transfer (type is read-only).
class TransactionEditScreen extends StatefulWidget {
  const TransactionEditScreen({
    super.key,
    required this.id,
    required this.kind,
  });

  final String id;
  final TransactionListKind kind;

  @override
  State<TransactionEditScreen> createState() => _TransactionEditScreenState();
}

class _TransactionEditScreenState extends State<TransactionEditScreen> {
  final _amountInput = TransactionAmountInput();
  final _notesController = TextEditingController();
  final _transferAmountController = TextEditingController();
  final _exchangeRateController = TextEditingController();
  final _personNameController = TextEditingController();
  final _debtAmountController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _canEdit = false;

  FormFeedbackType? _feedbackType;
  String? _feedbackMessage;
  Timer? _feedbackDismissTimer;

  DateTime _createdAt = DateTime.now();
  DateTime _transactionDate = DateTime.now();
  DateTime? _dueDate;

  String? _walletId;
  String? _categoryId;
  String? _currencyId;
  String? _debtId;
  String? _debtContactId;
  String? _debtContactPhone;
  String? _parentTransactionId;
  TransactionListKind? _parentTransactionKind;
  DebtLedgerDetail? _debtDetail;

  bool _splitEnabled = false;
  String _splitMode = SplitConstants.modeEqual;
  bool _splitIncludeSelf = true;
  double? _splitFixedAmountPerPerson;
  List<SplitParticipantRowState> _splitParticipantRows = const [];
  List<SplitParticipantDraft> _splitParticipants = const [];
  String? _sourceCurrencyId;
  String? _targetCurrencyId;
  String? _sourceWalletId;
  String? _targetWalletId;

  List<TransactionCategory> _expenseCategories = [];
  List<TransactionCategory> _incomeCategories = [];

  bool get _isSplitLinkedDebt => _parentTransactionId != null;

  bool get _isTransferLike =>
      widget.kind == TransactionListKind.transfer ||
      widget.kind == TransactionListKind.goalDeposit ||
      widget.kind == TransactionListKind.goalWithdraw;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final settings = context.read<SettingsProvider>();
    final currencyProvider = context.read<CurrencyProvider>();
    final walletProvider = context.read<WalletProvider>();
    final lazarus = LazarusDatabaseService.instance;
    final categoryService = CategoryService(lazarus);

    if (currencyProvider.currencies.isEmpty) {
      await currencyProvider.loadCurrencies();
    }
    if (walletProvider.treasuries.isEmpty) {
      await walletProvider.loadWallets();
    }

    _expenseCategories = await categoryService.getExpenseCategories();
    _incomeCategories = await categoryService.getIncomeCategories();

    if (_isTransferLike) {
      final row = await lazarus.database.financeDao.getTransferById(widget.id);
      if (row == null || !mounted) {
        context.pop();
        return;
      }
      final tr = row.transfer;
      _createdAt = tr.createdAt;
      _canEdit = settings.transactionEditWindowDays > 0 &&
          DateTime.now().difference(_createdAt) <=
              Duration(days: settings.transactionEditWindowDays);
      _transactionDate = tr.transactionDate;
      _sourceCurrencyId = tr.currencyId;
      _targetCurrencyId = tr.toCurrencyId ?? tr.currencyId;
      _sourceWalletId = tr.fromWalletId;
      _targetWalletId = tr.toWalletId;
      _transferAmountController.text = tr.amount.toString();
      _syncExchangeRateFromCurrencies();
      _notesController.text = tr.notes ?? '';
    } else if (_isDebtKind) {
      final debtService = DebtService(lazarus);
      final detail =
          await debtService.getDetailByLedgerTransactionId(widget.id);
      if (detail == null || !mounted) {
        context.pop();
        return;
      }
      _debtDetail = detail;
      final tx = detail.ledgerTransaction;
      _createdAt = tx.createdAt;
      _parentTransactionId = tx.parentTransactionId;
      if (_parentTransactionId != null) {
        _canEdit = false;
        final parentRow = await lazarus.database.financeDao
            .getTransactionById(_parentTransactionId!);
        if (parentRow != null) {
          _parentTransactionKind =
              parentRow.transaction.type == DatabaseConstants.txIncome
                  ? TransactionListKind.income
                  : TransactionListKind.expense;
        }
      } else {
        _canEdit = settings.transactionEditWindowDays > 0 &&
            DateTime.now().difference(_createdAt) <=
                Duration(days: settings.transactionEditWindowDays);
      }
      _transactionDate = tx.transactionDate;
      _debtId = detail.debt.id;
      _debtContactId = detail.debt.contactId;
      if (_debtContactId != null) {
        final contact =
            await lazarus.database.financeDao.getContactById(_debtContactId!);
        _debtContactPhone = contact?.phone;
      }
      _currencyId = tx.currencyId;
      _walletId = detail.debt.walletId;
      _personNameController.text = tx.title;
      _debtAmountController.text = tx.amount.toString();
      _dueDate = detail.debt.dueDate;
      _notesController.text = tx.notes ?? '';
    } else {
      final row = await lazarus.database.financeDao.getTransactionById(widget.id);
      if (row == null || !mounted) {
        context.pop();
        return;
      }
      final tx = row.transaction;
      _createdAt = tx.createdAt;
      _canEdit = settings.transactionEditWindowDays > 0 &&
          DateTime.now().difference(_createdAt) <=
              Duration(days: settings.transactionEditWindowDays);
      _transactionDate = tx.transactionDate;
      _walletId = tx.walletId;
      _categoryId = tx.categoryId;
      _currencyId = tx.currencyId;
      _amountInput.setValue(tx.amount);
      _notesController.text = tx.notes ?? '';

      final splitDetail = await TransactionSplitService(lazarus)
          .getDetailByTransactionId(widget.id);
      if (splitDetail != null) {
        _splitEnabled = true;
        _splitMode = splitDetail.split.splitMode;
        _splitIncludeSelf = splitDetail.split.includeSelfInEqualSplit;
        _splitFixedAmountPerPerson = splitDetail.split.fixedAmountPerPerson;
        _splitParticipantRows = await Future.wait(
          splitDetail.participants.map((p) async {
            String? phone;
            if (p.participant.contactId.isNotEmpty) {
              final contact = await lazarus.database.financeDao
                  .getContactById(p.participant.contactId);
              phone = contact?.phone;
            }
            return SplitParticipantRowState(
              contactId: p.participant.contactId,
              contactName: p.contactName,
              phone: phone,
              percent: p.participant.sharePercent,
              fixedAmount: splitDetail.split.splitMode ==
                      SplitConstants.modeFixedAmount
                  ? p.participant.shareAmount
                  : null,
            );
          }),
        );
        _splitParticipants =
            _splitParticipantRows.map((r) => r.toDraft()).toList();
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  List<Currency> get _currencies =>
      uniqueCurrenciesByCode(context.read<CurrencyProvider>().currencies);

  Currency? _currencyById(String? id) =>
      _currencies.where((c) => c.id == id).firstOrNull;

  List<Treasury> _walletsForCurrency(String? currencyId, {String? keepWalletId}) {
    final currency = _currencyById(currencyId);
    if (currency == null) return [];
    return regularTreasuriesForCurrency(
      treasuries: context.read<WalletProvider>().treasuries,
      currencyCode: currency.code,
      selectedWalletId: keepWalletId,
    );
  }

  List<TransactionCategory> get _activeCategories {
    if (widget.kind == TransactionListKind.income) {
      return _incomeCategories;
    }
    return _expenseCategories;
  }

  bool get _isDebtKind =>
      widget.kind == TransactionListKind.debtor ||
      widget.kind == TransactionListKind.creditor;

  Future<void> _openCategoriesManager() async {
    final type = widget.kind == TransactionListKind.income
        ? DatabaseConstants.categoryIncome
        : DatabaseConstants.categoryExpense;
    await context.push('/categories?type=$type');
    if (!mounted) return;
    final categoryService = CategoryService(LazarusDatabaseService.instance);
    _expenseCategories = await categoryService.getExpenseCategories();
    _incomeCategories = await categoryService.getIncomeCategories();
    setState(() {});
  }

  double? _parsePositiveDouble(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    final value = double.tryParse(normalized);
    if (value == null || value <= 0) return null;
    return value;
  }

  void _syncExchangeRateFromCurrencies() {
    final source = _currencyById(_sourceCurrencyId);
    final target = _currencyById(_targetCurrencyId);
    if (source == null || target == null) return;
    final rated = ExchangeRateDisplay.ratedCurrency(source: source, target: target);
    _exchangeRateController.text =
        ExchangeRateDisplay.defaultDisplayRateText(rated);
  }

  String _typeLabel(AppLocalizations l10n) {
    return switch (widget.kind) {
      TransactionListKind.income => l10n.transactionFormIncome,
      TransactionListKind.expense => l10n.transactionFormExpense,
      TransactionListKind.transfer => l10n.transactionFormCurrencyTransfer,
      TransactionListKind.goalDeposit => l10n.goalSavingsDepositTitle,
      TransactionListKind.goalWithdraw => l10n.goalSavingsWithdrawTitle,
      TransactionListKind.debtor => l10n.transactionFormDebtor,
      TransactionListKind.creditor => l10n.transactionFormCreditor,
    };
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
      locale: Localizations.localeOf(context),
      helpText: context.l10n.transactionFormDueDate,
    );
    if (picked != null && mounted) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _reloadDebtDetail() async {
    if (!_isDebtKind || _debtId == null) return;
    final detail = await DebtService(LazarusDatabaseService.instance)
        .getDetailByLedgerTransactionId(widget.id);
    if (!mounted) return;
    setState(() => _debtDetail = detail);
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
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
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

  Future<void> _sendDebtWhatsApp() async {
    final l10n = context.l10n;
    final phone = _debtContactPhone;
    final name = _personNameController.text.trim();
    final amount = _parsePositiveDouble(_debtAmountController.text);
    final currency = _currencyById(_currencyId);

    if (phone == null || phone.trim().isEmpty || name.isEmpty || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.whatsappNoPhone)),
      );
      return;
    }

    final message = WhatsAppMessageHelper.splitDebtMessage(
      l10n: l10n,
      localeName: Localizations.localeOf(context).toString(),
      personName: name,
      transactionTitle: name,
      shareAmount: amount,
      currencyCode: currency?.code ?? '',
      transactionDate: _transactionDate,
    );

    final opened = await WhatsAppService().openChat(
      phone: phone,
      message: message,
    );
    if (!mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.whatsappOpenFailed)),
      );
    }
  }

  void _goToParentTransaction() {
    final parentId = _parentTransactionId;
    final kind = _parentTransactionKind;
    if (parentId == null || kind == null) return;
    context.push('/transactions/$parentId/edit', extra: kind);
  }

  Future<void> _openSettlementSheet() async {
    final detail = _debtDetail;
    if (detail == null || detail.isFullyPaid) return;

    final l10n = context.l10n;
    final actionLabel = widget.kind == TransactionListKind.debtor
        ? l10n.transactionDebtReceive
        : l10n.transactionDebtPay;

    final result = await showModalBottomSheet<DebtSettlementResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DebtSettlementSheet(
        remaining: detail.remaining,
        currencyCode: detail.currencyCode,
        actionLabel: actionLabel,
      ),
    );

    if (result == null || !mounted) return;

    final currency = _currencyById(_currencyId);
    if (currency == null || _debtId == null) return;

    setState(() => _isSaving = true);
    try {
      final settlementTitle = widget.kind == TransactionListKind.debtor
          ? l10n.transactionDebtSettlementTitleReceive(detail.debt.personName)
          : l10n.transactionDebtSettlementTitlePay(detail.debt.personName);

      await DebtService(LazarusDatabaseService.instance).settle(
        SettleDebtInput(
          debtId: _debtId!,
          amount: result.amount,
          currency: currency,
          settlementTitle: settlementTitle,
          notes: result.notes,
          paymentDate: DateTime.now(),
        ),
      );

      if (!mounted) return;
      await context.read<WalletProvider>().loadWallets();
      context.read<DashboardRefreshProvider>().notifyRefresh();
      await _reloadDebtDetail();

      _showFormSuccess(l10n.transactionDebtSettleSuccess);
    } catch (e) {
      if (mounted) {
        _showFormError(e);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 1),
      locale: Localizations.localeOf(context),
      helpText: context.l10n.transactionFormDate,
    );
    if (picked != null && mounted) {
      setState(() => _transactionDate = picked);
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if (!_canEdit) {
      _showFormWarning(l10n.transactionEditExpired);
      return;
    }

    if (_isTransferLike) {
      final amount = _parsePositiveDouble(_transferAmountController.text);
      final displayRate =
          ExchangeRateDisplay.parseDisplayRate(_exchangeRateController.text);
      if (amount == null) {
        _showFormWarning(l10n.transactionFormAmountRequired);
        return;
      }
      if (displayRate == null) {
        _showFormWarning(l10n.transactionFormExchangeRateRequired);
        return;
      }
    } else if (_isDebtKind) {
      if (_personNameController.text.trim().isEmpty) {
        _showFormWarning(l10n.transactionFormPersonNameRequired);
        return;
      }
      if (_parsePositiveDouble(_debtAmountController.text) == null) {
        _showFormWarning(l10n.transactionFormAmountRequired);
        return;
      }
      if (_walletId == null) {
        _showFormWarning(l10n.transactionFormSelectWallet);
        return;
      }
    } else if (_amountInput.value <= 0) {
      _showFormWarning(l10n.transactionFormAmountRequired);
      return;
    }

    if (!_isTransferLike &&
        !_isDebtKind &&
        _splitEnabled &&
        _splitParticipants.where((p) => p.hasIdentity).isEmpty) {
      _showFormWarning(l10n.transactionSplitParticipantsRequired);
      return;
    }

    final settings = context.read<SettingsProvider>();
    setState(() => _isSaving = true);

    try {
      if (_isTransferLike) {
        final source = _currencyById(_sourceCurrencyId);
        final target = _currencyById(_targetCurrencyId);
        if (source == null || target == null) return;
        if (_sourceWalletId == null || _targetWalletId == null) return;

        final currencyProvider = context.read<CurrencyProvider>();
        await ExchangeRateDisplay.persistDisplayRateIfChanged(
          provider: currencyProvider,
          source: source,
          target: target,
          rateText: _exchangeRateController.text,
        );

        final freshSource =
            ExchangeRateDisplay.findCurrency(currencyProvider, source) ??
                source;
        final freshTarget =
            ExchangeRateDisplay.findCurrency(currencyProvider, target) ??
                target;

        await TransferService(LazarusDatabaseService.instance).updateCurrencyTransfer(
          input: UpdateCurrencyTransferInput(
            id: widget.id,
            fromWalletId: _sourceWalletId!,
            toWalletId: _targetWalletId!,
            sourceCurrency: freshSource,
            targetCurrency: freshTarget,
            sourceAmount: _parsePositiveDouble(_transferAmountController.text)!,
            notes: _notesController.text,
            transactionDate: _transactionDate,
          ),
          editWindowDays: settings.transactionEditWindowDays,
        );
      } else if (_isDebtKind) {
        final currency = _currencyById(_currencyId);
        final debtId = _debtId;
        if (currency == null || debtId == null || _walletId == null) return;

        final txType = widget.kind == TransactionListKind.debtor
            ? DatabaseConstants.txDebtor
            : DatabaseConstants.txCreditor;

        await DebtService(LazarusDatabaseService.instance).update(
          input: UpdateDebtEntryInput(
            transactionId: widget.id,
            debtId: debtId,
            type: txType,
            walletId: _walletId!,
            personName: _personNameController.text,
            contactId: _debtContactId,
            phone: _debtContactPhone,
            amount: _parsePositiveDouble(_debtAmountController.text)!,
            currency: currency,
            dueDate: _dueDate,
            notes: _notesController.text,
            transactionDate: _transactionDate,
          ),
          editWindowDays: settings.transactionEditWindowDays,
        );
      } else {
        final currency = _currencyById(_currencyId);
        final categoryId = widget.kind == TransactionListKind.income
            ? DatabaseConstants.systemGeneralIncomeCategoryId
            : _categoryId;
        if (currency == null || _walletId == null || categoryId == null) {
          return;
        }

        await TransactionSplitService(LazarusDatabaseService.instance).update(
          input: UpdateSplitTransactionInput(
            transactionId: widget.id,
            walletId: _walletId!,
            categoryId: categoryId,
            type: widget.kind == TransactionListKind.income
                ? DatabaseConstants.txIncome
                : DatabaseConstants.txExpense,
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
          editWindowDays: settings.transactionEditWindowDays,
        );
      }

      if (!mounted) return;
      await context.read<WalletProvider>().loadWallets();
      context.read<DashboardRefreshProvider>().notifyRefresh();
      context.showSuccessFeedback(l10n.transactionEditSaveSuccess);
      context.pop();
    } catch (e) {
      if (mounted) {
        _showFormError(e);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _feedbackDismissTimer?.cancel();
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
    final uniqueCurrencies = uniqueCurrenciesByCode(
      context.watch<CurrencyProvider>().currencies,
    );

    final sourceCurrency = _currencyById(
      _isTransferLike ? _sourceCurrencyId : _currencyId,
    );
    final targetCurrency = _currencyById(_targetCurrencyId);
    final transferAmount = _parsePositiveDouble(_transferAmountController.text);
    final displayRate =
        ExchangeRateDisplay.parseDisplayRate(_exchangeRateController.text);
    final convertedPreview = _isTransferLike &&
            sourceCurrency != null &&
            targetCurrency != null &&
            transferAmount != null &&
            displayRate != null
        ? CurrencyFormatter.formatCodeFirst(
            ExchangeRateDisplay.resolveTransferTargetAmount(
              sourceAmount: transferAmount,
              source: sourceCurrency,
              target: targetCurrency,
              displayRate: displayRate,
            ),
            targetCurrency.code,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionEditTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colors.inputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          l10n.transactionEditTypeLabel,
                          style: AppFormFields.sectionLabelStyleOf(context),
                        ),
                        const Spacer(),
                        Text(
                          _typeLabel(l10n),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_feedbackMessage != null && _feedbackType != null) ...[
                    const SizedBox(height: 12),
                    FormFeedbackBanner(
                      message: _feedbackMessage!,
                      type: _feedbackType!,
                      onDismiss: _clearFormFeedback,
                    ),
                  ],
                  if (_isSplitLinkedDebt) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.accentSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.transactionSplitLinkedCannotEdit,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: TextButton(
                              onPressed: _goToParentTransaction,
                              child: Text(l10n.transactionSplitGoToParent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (_isTransferLike) ...[
                    Text(
                      l10n.transactionFormAmountLabel,
                      style: AppFormFields.sectionLabelStyleOf(context),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _transferAmountController,
                      enabled: _canEdit,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: AppFormFields.inputTextStyleOf(context),
                      decoration: AppFormFields.decoration(
                        context,
                        hintText: l10n.transactionFormAmountHint,
                      ).copyWith(
                        suffixText: sourceCurrency?.code,
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
                      onSelected: (id) => setState(() {
                        _sourceCurrencyId = id;
                        _sourceWalletId = null;
                        _syncExchangeRateFromCurrencies();
                      }),
                    ),
                    const SizedBox(height: 10),
                    TransactionWalletCarousel(
                      treasuries: _walletsForCurrency(
                        _sourceCurrencyId,
                        keepWalletId: _sourceWalletId,
                      ),
                      currencyCode: sourceCurrency?.code ?? '',
                      selectedWalletId: _sourceWalletId,
                      onSelected: (id) => setState(() => _sourceWalletId = id),
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
                      onSelected: (id) => setState(() {
                        _targetCurrencyId = id;
                        _targetWalletId = null;
                        _syncExchangeRateFromCurrencies();
                      }),
                    ),
                    const SizedBox(height: 10),
                    TransactionWalletCarousel(
                      treasuries: _walletsForCurrency(
                        _targetCurrencyId,
                        keepWalletId: _targetWalletId,
                      ),
                      currencyCode: targetCurrency?.code ?? '',
                      selectedWalletId: _targetWalletId,
                      onSelected: (id) => setState(() => _targetWalletId = id),
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
                      enabled: _canEdit,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: AppFormFields.inputTextStyleOf(context),
                      decoration: AppFormFields.decoration(
                        context,
                        labelText: l10n.currencyFormRateLabel(
                          context.watch<CurrencyProvider>().baseCurrency?.code ??
                              '—',
                        ),
                        hintText: l10n.currencyFormRateHint,
                      ).copyWith(
                        helperText: sourceCurrency != null &&
                                targetCurrency != null
                            ? l10n.currencyFormRateHelper(
                                context
                                        .watch<CurrencyProvider>()
                                        .baseCurrency
                                        ?.code ??
                                    '—',
                                ExchangeRateDisplay.ratedCurrency(
                                  source: sourceCurrency,
                                  target: targetCurrency,
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
                    if (convertedPreview != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.transactionFormConvertedAmount(convertedPreview),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.captionOnSurface(colors),
                      ),
                    ],
                  ] else if (_isDebtKind) ...[
                    PersonPickerField(
                      enabled: _canEdit,
                      label: l10n.transactionFormPersonName,
                      hint: l10n.transactionFormPersonNameHint,
                      initialSelection: PersonSelection(
                        contactId: _debtContactId,
                        displayName: _personNameController.text,
                        phone: _debtContactPhone,
                      ),
                      showPhoneField: true,
                      onWhatsAppTap:
                          (_debtContactPhone?.trim().isNotEmpty ?? false)
                              ? _sendDebtWhatsApp
                              : null,
                      onChanged: (selection) {
                        setState(() {
                          _debtContactId = selection.contactId;
                          _personNameController.text = selection.displayName;
                          final phone = selection.phone?.trim();
                          _debtContactPhone =
                              (phone == null || phone.isEmpty) ? null : phone;
                        });
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
                      enabled: _canEdit,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: AppFormFields.inputTextStyleOf(context),
                      decoration: AppFormFields.decoration(
                        context,
                        hintText: l10n.transactionFormAmountHint,
                      ).copyWith(
                        suffixText: sourceCurrency?.code,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TransactionCurrencyPills(
                      currencies: uniqueCurrencies,
                      selectedCurrencyId: _currencyId,
                      onSelected: (id) => setState(() {
                        _currencyId = id;
                        _walletId = null;
                      }),
                    ),
                    const SizedBox(height: 10),
                    TransactionWalletCarousel(
                      treasuries: _walletsForCurrency(
                        _currencyId,
                        keepWalletId: _walletId,
                      ),
                      currencyCode: sourceCurrency?.code ?? '',
                      selectedWalletId: _walletId,
                      onSelected: (id) => setState(() => _walletId = id),
                      emptyLabel: l10n.transactionFormNoWalletForCurrency,
                    ),
                    const SizedBox(height: 20),
                    if (_debtDetail != null) ...[
                      _DebtProgressCard(
                        detail: _debtDetail!,
                        l10n: l10n,
                        colors: colors,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.transactionDebtPaymentHistory,
                        style: AppFormFields.sectionLabelStyleOf(context),
                      ),
                      const SizedBox(height: 8),
                      if (_debtDetail!.payments.isEmpty)
                        Text(
                          l10n.transactionDebtNoPayments,
                          style: AppTextStyles.captionOnSurface(colors),
                        )
                      else
                        ..._debtDetail!.payments.map(
                          (payment) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              CurrencyFormatter.formatCodeFirst(
                                payment.amount,
                                _debtDetail!.currencyCode,
                              ),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              AppDateFormatter.format(payment.paymentDate),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _debtDetail!.isFullyPaid || _isSaving
                            ? null
                            : _openSettlementSheet,
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              widget.kind == TransactionListKind.debtor
                                  ? AppColors.success
                                  : AppColors.debtAccent,
                          minimumSize: const Size.fromHeight(48),
                        ),
                        icon: Icon(
                          widget.kind == TransactionListKind.debtor
                              ? Icons.call_received
                              : Icons.payments_outlined,
                        ),
                        label: Text(
                          _debtDetail!.isFullyPaid
                              ? l10n.transactionDebtFullyPaid
                              : widget.kind == TransactionListKind.debtor
                                  ? l10n.transactionDebtReceive
                                  : l10n.transactionDebtPay,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      l10n.transactionFormDueDate,
                      style: AppFormFields.sectionLabelStyleOf(context),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _dueDate != null
                            ? AppDateFormatter.format(_dueDate!)
                            : l10n.transactionFormDueDateOptional,
                        style: AppFormFields.inputTextStyleOf(context),
                      ),
                      trailing: _canEdit
                          ? TextButton(
                              onPressed: _dueDate == null
                                  ? _pickDueDate
                                  : () => setState(() => _dueDate = null),
                              child: Text(
                                _dueDate == null
                                    ? l10n.transactionFormChangeDate
                                    : l10n.transactionFormClearDueDate,
                              ),
                            )
                          : null,
                      onTap: _canEdit ? _pickDueDate : null,
                    ),
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
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TransactionNumericKeypad(
                      onDigit: (d) => setState(() => _amountInput.appendDigit(d)),
                      onDecimal: () => setState(() => _amountInput.startDecimal()),
                      onThousandsSeparator: () => setState(
                        () => _amountInput.toggleThousandsSeparators(),
                      ),
                      onDoubleZero: () =>
                          setState(() => _amountInput.appendDoubleZero()),
                      onBackspace: () => setState(() => _amountInput.backspace()),
                      showThousandsSeparatorKey:
                          NumberFormatPreferences
                              .current
                              .thousandsSeparator
                              .isNotEmpty,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.transactionFormSelectCurrency,
                      style: AppFormFields.sectionLabelStyleOf(context),
                    ),
                    const SizedBox(height: 8),
                    TransactionCurrencyPills(
                      currencies: uniqueCurrencies,
                      selectedCurrencyId: _currencyId,
                      onSelected: (id) => setState(() {
                        _currencyId = id;
                        _walletId = null;
                      }),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.transactionFormWallet,
                      style: AppFormFields.sectionLabelStyleOf(context),
                    ),
                    const SizedBox(height: 8),
                    TransactionWalletCarousel(
                      treasuries: _walletsForCurrency(
                        _currencyId,
                        keepWalletId: _walletId,
                      ),
                      currencyCode: sourceCurrency?.code ?? '',
                      selectedWalletId: _walletId,
                      onSelected: (id) => setState(() => _walletId = id),
                      emptyLabel: l10n.transactionFormNoWalletForCurrency,
                    ),
                    if (widget.kind == TransactionListKind.expense) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n.transactionFormCategory,
                        style: AppFormFields.sectionLabelStyleOf(context),
                      ),
                      const SizedBox(height: 8),
                      TransactionCategoryGrid(
                        categories: _activeCategories,
                        selectedCategoryId: _categoryId,
                        onSelected: (cat) =>
                            setState(() => _categoryId = cat.id),
                        moreLabel: l10n.transactionFormMore,
                        onMoreTap: _openCategoriesManager,
                      ),
                    ],
                    const SizedBox(height: 16),
                    TransactionSplitSection(
                      initialEnabled: _splitEnabled,
                      initialMode: _splitMode,
                      initialIncludeSelf: _splitIncludeSelf,
                      initialFixedAmountPerPerson: _splitFixedAmountPerPerson,
                      initialParticipants: _splitParticipantRows,
                      totalAmount: _amountInput.value,
                      currencyCode: sourceCurrency?.code ?? '',
                      transactionTitle: _activeCategories
                              .where((c) => c.id == _categoryId)
                              .firstOrNull
                              ?.name ??
                          '',
                      transactionDate: _transactionDate,
                      onChanged: (state) {
                        _splitEnabled = state.enabled;
                        _splitMode = state.mode;
                        _splitIncludeSelf = state.includeSelfInEqualSplit;
                        _splitFixedAmountPerPerson = state.fixedAmountPerPerson;
                        _splitParticipants = state.participants;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    enabled: _canEdit,
                    maxLines: 3,
                    style: AppFormFields.inputTextStyleOf(context),
                    decoration: AppFormFields.decoration(
                      context,
                      labelText: l10n.transactionFormNotes,
                      hintText: l10n.transactionFormNotesHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(AppDateFormatter.format(_transactionDate)),
                    trailing: TextButton(
                      onPressed: _canEdit ? _pickDate : null,
                      child: Text(l10n.transactionFormChangeDate),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _canEdit && !_isSaving ? _save : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.transactionEditSave),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DebtProgressCard extends StatelessWidget {
  const _DebtProgressCard({
    required this.detail,
    required this.l10n,
    required this.colors,
  });

  final DebtLedgerDetail detail;
  final AppLocalizations l10n;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final code = detail.currencyCode;
    final rows = [
      (l10n.transactionDebtTotal, detail.debt.amount),
      (l10n.transactionDebtPaid, detail.paidAmount),
      (l10n.transactionDebtRemaining, detail.remaining),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.$1,
                        style: AppTextStyles.captionOnSurface(colors),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatCodeFirst(row.$2, code),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
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
