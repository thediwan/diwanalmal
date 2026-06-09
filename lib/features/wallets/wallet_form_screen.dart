import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/treasury_icon_styles.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/helpers/currency_uniqueness.dart';
import '../../core/helpers/uuid_helper.dart';
import '../../core/theme/app_form_fields.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/auth_background.dart';
import '../../models/opening_balance_input.dart';
import '../../providers/currency_provider.dart';
import '../../providers/wallet_provider.dart';
import 'widgets/opening_balance_section.dart';
import 'widgets/wallet_type_selector.dart';

/// Form to create or edit a wallet (add flow matches client mockup).
class WalletFormScreen extends StatefulWidget {
  const WalletFormScreen({super.key, this.walletId});

  final String? walletId;

  bool get isEditing => walletId != null;

  @override
  State<WalletFormScreen> createState() => _WalletFormScreenState();
}

class _WalletFormScreenState extends State<WalletFormScreen> {
  static const _logoAsset = 'assets/images/logo_amanah.png';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedIconStyle = TreasuryIconStyles.bank;
  bool _isSaving = false;
  bool _isLoadingWallet = false;
  bool _isLoadingCurrencies = false;
  String? _editingTreasuryId;
  final List<OpeningBalanceRowState> _openingBalanceRows = [];

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

    if (widget.isEditing) {
      setState(() => _isLoadingWallet = true);
      final walletProvider = context.read<WalletProvider>();
      if (walletProvider.treasuries.isEmpty) {
        await walletProvider.loadWallets();
      }
      if (mounted) {
        _loadWallet();
        setState(() => _isLoadingWallet = false);
      }
    } else {
      _ensureInitialBalanceRow();
    }

    if (mounted) {
      setState(() => _isLoadingCurrencies = false);
    }
  }

  void _ensureInitialBalanceRow() {
    if (_openingBalanceRows.isNotEmpty) return;

    final currencies =
        uniqueCurrenciesByCode(context.read<CurrencyProvider>().currencies);
    if (currencies.isEmpty) return;

    _openingBalanceRows.add(
      OpeningBalanceRowState(
        id: UuidHelper.generate(),
        balanceController: TextEditingController(text: '0'),
        currencyCode: currencies.first.code.toUpperCase(),
      ),
    );
  }

  void _loadWallet() {
    final treasury = context.read<WalletProvider>().treasuries
        .where((t) => t.id == widget.walletId)
        .firstOrNull;

    if (treasury == null) return;

    _editingTreasuryId = treasury.id;
    _nameController.text = treasury.name;
    _selectedIconStyle =
        treasury.iconStyle ?? TreasuryIconStyles.cash;

    for (final row in _openingBalanceRows) {
      row.dispose();
    }
    _openingBalanceRows.clear();

    for (final account in treasury.accounts) {
      _openingBalanceRows.add(
        OpeningBalanceRowState(
          id: UuidHelper.generate(),
          accountId: account.accountId,
          balanceController: TextEditingController(
            text: _formatBalanceField(account.balance),
          ),
          currencyCode: account.currencyCode.toUpperCase(),
        ),
      );
    }

    setState(() {});
  }

  String _formatBalanceField(double balance) {
    if (balance == balance.roundToDouble()) {
      return balance.toInt().toString();
    }
    return balance.toString();
  }

  void _addOpeningBalanceRow() {
    final currencies = uniqueCurrenciesByCode(
      context.read<CurrencyProvider>().currencies,
    );
    final usedCodes = _usedCurrencyCodes();
    final available = currencies
        .where((c) => !usedCodes.contains(c.code.toUpperCase()))
        .toList();

    setState(() {
      _openingBalanceRows.add(
        OpeningBalanceRowState(
          id: UuidHelper.generate(),
          balanceController: TextEditingController(text: '0'),
          currencyCode: available.isNotEmpty
              ? available.first.code.toUpperCase()
              : null,
        ),
      );
    });
  }

  void _removeOpeningBalanceRow(String rowId) {
    setState(() {
      final index = _openingBalanceRows.indexWhere((r) => r.id == rowId);
      if (index == -1) return;
      _openingBalanceRows[index].dispose();
      _openingBalanceRows.removeAt(index);
    });
  }

  void _onCurrencyChanged(String rowId, String? currencyCode) {
    setState(() {
      final row = _openingBalanceRows.firstWhere((r) => r.id == rowId);
      if (row.currencyCode != currencyCode) {
        row.accountId = null;
      }
      row.currencyCode = currencyCode?.toUpperCase();
    });
  }

  Set<String> _usedCurrencyCodes() {
    return _openingBalanceRows
        .map((r) => r.currencyCode?.toUpperCase())
        .whereType<String>()
        .toSet();
  }

  List<OpeningBalanceInput>? _parseOpeningBalances() {
    final l10n = context.l10n;

    if (_openingBalanceRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.walletFormOpeningBalanceRequired)),
      );
      return null;
    }

    final entries = <OpeningBalanceInput>[];
    final seenCodes = <String>{};

    for (final row in _openingBalanceRows) {
      if (row.currencyCode == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.walletFormSelectCurrency)),
        );
        return null;
      }

      final code = row.currencyCode!.toUpperCase();
      if (seenCodes.contains(code)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.walletFormDuplicateCurrency)),
        );
        return null;
      }

      final raw = row.balanceController.text.trim();
      if (raw.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.walletFormBalanceRequired)),
        );
        return null;
      }

      final balance = double.tryParse(raw);
      if (balance == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.walletFormInvalidNumber)),
        );
        return null;
      }

      seenCodes.add(code);
      entries.add(
        OpeningBalanceInput(
          currencyCode: code,
          initialBalance: balance,
          accountId: row.accountId,
        ),
      );
    }

    return entries;
  }

  Future<void> _save() async {
    final l10n = context.l10n;

    if (!_formKey.currentState!.validate()) return;

    final openingBalances = _parseOpeningBalances();
    if (openingBalances == null) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<WalletProvider>();
      final legacyIcon = TreasuryIconStyles.legacyEmoji(_selectedIconStyle);
      final name = _nameController.text.trim();

      if (widget.isEditing && _editingTreasuryId != null) {
        await provider.updateWallet(
          id: _editingTreasuryId!,
          name: name,
          icon: legacyIcon,
          iconStyle: _selectedIconStyle,
          openingBalances: openingBalances,
        );
      } else {
        await provider.createWallet(
          name: name,
          icon: legacyIcon,
          iconStyle: _selectedIconStyle,
          openingBalances: openingBalances,
        );
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        final message = e.toString().contains('duplicate_currency')
            ? l10n.walletFormDuplicateCurrency
            : e.toString().contains('account_has_transactions')
                ? l10n.walletFormAccountHasTransactions
                : l10n.walletFormError(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
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
        title: Text(l10n.walletFormDeleteTitle),
        content: Text(l10n.walletFormDeleteMessage),
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

    if (confirmed != true || _editingTreasuryId == null || !mounted) return;

    await context.read<WalletProvider>().deleteWallet(_editingTreasuryId!);
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final row in _openingBalanceRows) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final currencies = context.watch<CurrencyProvider>().currencies;
    final isEditing = widget.isEditing;
    final inputStyle = AppFormFields.inputTextStyleOf(context);

    return AuthBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FormTopBar(
            title: isEditing ? l10n.walletFormTitleEdit : l10n.walletFormAddTitle,
            onClose: () => context.pop(),
            showDelete: isEditing,
            onDelete: _delete,
          ),
          Expanded(
            child: _isLoadingWallet
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Center(child: _HeroLogo(logoAsset: _logoAsset)),
                    const SizedBox(height: 12),
                    Text(
                      isEditing
                          ? l10n.walletFormEditSubtitle
                          : l10n.walletFormAddSubtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: colors.cardShadow,
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.walletFormName,
                            style: AppTextStyles.label.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            style: inputStyle,
                            decoration: AppFormFields.decoration(
                              context,
                              hintText: l10n.walletFormNameHintNew,
                              suffixIcon: const Icon(
                                Icons.edit_outlined,
                                color: AppColors.dashboardPrimary,
                                size: 20,
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? l10n.walletFormNameRequired
                                    : null,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.walletFormWalletType,
                            style: AppTextStyles.label.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          WalletTypeSelector(
                            selectedStyle: _selectedIconStyle,
                            onStyleSelected: (style) =>
                                setState(() => _selectedIconStyle = style),
                          ),
                          const SizedBox(height: 20),
                          OpeningBalanceSection(
                            rows: _openingBalanceRows,
                            currencies: currencies,
                            isLoadingCurrencies: _isLoadingCurrencies,
                            onAddRow: _addOpeningBalanceRow,
                            onRemoveRow: _removeOpeningBalanceRow,
                            onCurrencyChanged: _onCurrencyChanged,
                            usedCurrencyCodes: _usedCurrencyCodes(),
                            balanceFieldLabel: isEditing
                                ? l10n.walletFormCurrentBalance
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                        Text(
                          isEditing
                              ? l10n.walletFormSave
                              : l10n.walletFormConfirmAdd,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: colors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.onPrimary, width: 1.5),
                          ),
                          child: Icon(Icons.add, size: 16, color: colors.onPrimary),
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

class _FormTopBar extends StatelessWidget {
  const _FormTopBar({
    required this.title,
    required this.onClose,
    required this.showDelete,
    required this.onDelete,
  });

  final String title;
  final VoidCallback onClose;
  final bool showDelete;
  final VoidCallback onDelete;

  static const _logoAsset = 'assets/images/logo_amanah.png';

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
          if (showDelete)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            )
          else
            Image.asset(
              _logoAsset,
              width: 36,
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.account_balance,
                size: 28,
                color: AppColors.dashboardPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroLogo extends StatelessWidget {
  const _HeroLogo({required this.logoAsset});

  final String logoAsset;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 120,
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Image.asset(
        logoAsset,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Text(
          AppConstants.appName,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.dashboardPrimary,
            fontWeight: FontWeight.w700,
          ),
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
