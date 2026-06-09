import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/treasury_icon_styles.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/helpers/uuid_helper.dart';
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
  String? _editingTreasuryId;
  final List<OpeningBalanceRowState> _openingBalanceRows = [];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureWalletLoaded());
    }
  }

  Future<void> _ensureWalletLoaded() async {
    if (!mounted) return;

    setState(() => _isLoadingWallet = true);

    final provider = context.read<WalletProvider>();
    if (provider.treasuries.isEmpty) {
      await provider.loadWallets();
    }

    if (mounted) {
      _loadWallet();
      setState(() => _isLoadingWallet = false);
    }
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
          currencyCode: account.currencyCode,
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
    final currencies = context.read<CurrencyProvider>().currencies;
    final usedCodes = _usedCurrencyCodes();
    final available = currencies
        .where((c) => !usedCodes.contains(c.code))
        .toList();

    setState(() {
      _openingBalanceRows.add(
        OpeningBalanceRowState(
          id: UuidHelper.generate(),
          balanceController: TextEditingController(text: '0'),
          currencyCode: available.isNotEmpty ? available.first.code : null,
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
      row.currencyCode = currencyCode;
    });
  }

  Set<String> _usedCurrencyCodes() {
    return _openingBalanceRows
        .map((r) => r.currencyCode)
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
    final currencies = context.watch<CurrencyProvider>().currencies;
    final isEditing = widget.isEditing;

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
                        color: AppColors.textSecondaryLight,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.walletFormName,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: l10n.walletFormNameHintNew,
                              suffixIcon: const Icon(
                                Icons.edit_outlined,
                                color: AppColors.dashboardPrimary,
                                size: 20,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
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
                              color: AppColors.textSecondaryLight,
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
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
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
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(Icons.add, size: 16, color: Colors.white),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 26),
            color: AppColors.textPrimaryLight,
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
    return Container(
      width: 120,
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
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
