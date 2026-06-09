import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/helpers/currency_uniqueness.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_form_fields.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/currency.dart';

/// Mutable row state for one opening-balance entry in the wallet form.
class OpeningBalanceRowState {
  OpeningBalanceRowState({
    required this.id,
    required this.balanceController,
    this.currencyCode,
    this.accountId,
  });

  final String id;
  final TextEditingController balanceController;
  String? currencyCode;
  String? accountId;

  void dispose() => balanceController.dispose();
}

/// Dynamic opening-balance rows with an add button.
class OpeningBalanceSection extends StatelessWidget {
  const OpeningBalanceSection({
    super.key,
    required this.rows,
    required this.currencies,
    required this.onAddRow,
    required this.onRemoveRow,
    required this.onCurrencyChanged,
    required this.usedCurrencyCodes,
    this.balanceFieldLabel,
    this.isLoadingCurrencies = false,
  });

  final List<OpeningBalanceRowState> rows;
  final List<Currency> currencies;
  final VoidCallback onAddRow;
  final ValueChanged<String> onRemoveRow;
  final void Function(String rowId, String? currencyCode) onCurrencyChanged;
  final Set<String> usedCurrencyCodes;
  final String? balanceFieldLabel;
  final bool isLoadingCurrencies;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final uniqueCurrencies = uniqueCurrenciesByCode(currencies);
    final canAddMoreRows =
        uniqueCurrencies.isNotEmpty &&
        usedCurrencyCodes.length < uniqueCurrencies.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.walletFormOpeningBalance,
          style: AppTextStyles.label.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        if (isLoadingCurrencies)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (uniqueCurrencies.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.walletFormNoCurrencies,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          )
        else ...[
          for (final row in rows) ...[
            _OpeningBalanceRow(
              key: ValueKey(row.id),
              row: row,
              currencies: uniqueCurrencies,
              usedCurrencyCodes: usedCurrencyCodes,
              balanceFieldLabel: balanceFieldLabel,
              onCurrencyChanged: (code) => onCurrencyChanged(row.id, code),
              onRemove: rows.length > 1 ? () => onRemoveRow(row.id) : null,
            ),
            const SizedBox(height: 10),
          ],
          OutlinedButton.icon(
            onPressed: canAddMoreRows ? onAddRow : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.dashboardPrimary,
              side: BorderSide(color: context.appColors.accentSurfaceBorder),
              backgroundColor: context.appColors.accentSurface,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: Text(
              l10n.walletFormAddOpeningBalance,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.dashboardPrimary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OpeningBalanceRow extends StatefulWidget {
  const _OpeningBalanceRow({
    super.key,
    required this.row,
    required this.currencies,
    required this.usedCurrencyCodes,
    required this.onCurrencyChanged,
    this.balanceFieldLabel,
    this.onRemove,
  });

  final OpeningBalanceRowState row;
  final List<Currency> currencies;
  final Set<String> usedCurrencyCodes;
  final ValueChanged<String?> onCurrencyChanged;
  final String? balanceFieldLabel;
  final VoidCallback? onRemove;

  @override
  State<_OpeningBalanceRow> createState() => _OpeningBalanceRowState();
}

class _OpeningBalanceRowState extends State<_OpeningBalanceRow> {
  String? _selectedCurrencyCode;

  @override
  void initState() {
    super.initState();
    _selectedCurrencyCode = _resolveSelectedCode(notifyParent: true);
  }

  @override
  void didUpdateWidget(covariant _OpeningBalanceRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final resolved = _resolveSelectedCode(notifyParent: false);
    if (resolved != _selectedCurrencyCode) {
      setState(() => _selectedCurrencyCode = resolved);
      if (resolved != null &&
          widget.row.currencyCode?.toUpperCase() != resolved) {
        widget.onCurrencyChanged(resolved);
      }
    }
  }

  String? _firstAvailableCode() {
    for (final currency in widget.currencies) {
      final code = currency.code.toUpperCase();
      final rowCode = _selectedCurrencyCode ?? widget.row.currencyCode?.toUpperCase();
      final isUsedElsewhere = widget.usedCurrencyCodes.contains(code) &&
          rowCode != code;
      if (!isUsedElsewhere) return code;
    }

    return null;
  }

  String? _resolveSelectedCode({required bool notifyParent}) {
    final current = widget.row.currencyCode?.toUpperCase();
    if (current != null) {
      final matches = widget.currencies.where(
        (c) => c.code.toUpperCase() == current,
      );
      if (matches.length == 1) return current;
    }

    final fallback = _firstAvailableCode() ??
        widget.currencies.firstOrNull?.code.toUpperCase();

    if (fallback != null &&
        notifyParent &&
        widget.row.currencyCode?.toUpperCase() != fallback) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onCurrencyChanged(fallback);
      });
    }
    return fallback;
  }

  List<DropdownMenuItem<String>> _buildItems() {
    return widget.currencies.map((currency) {
      final normalizedCode = currency.code.toUpperCase();
      final rowCode = _selectedCurrencyCode;
      final isUsedElsewhere = widget.usedCurrencyCodes.contains(normalizedCode) &&
          rowCode != normalizedCode;

      return DropdownMenuItem(
        value: normalizedCode,
        enabled: !isUsedElsewhere,
        child: Text(
          '${currency.name} (${currency.code})',
          style: AppFormFields.inputTextStyleFor(context.appColors),
        ),
      );
    }).toList();
  }

  String? _dropdownValue(
    String? selectedCode,
    List<DropdownMenuItem<String>> items,
  ) {
    if (selectedCode == null || items.isEmpty) return null;

    final exactMatches =
        items.where((item) => item.value == selectedCode).length;
    if (exactMatches == 1) return selectedCode;

    for (final item in items) {
      if (item.enabled && item.value != null) {
        return item.value;
      }
    }

    return items.first.value;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = _buildItems();
    final dropdownValue = _dropdownValue(_selectedCurrencyCode, items);

    if (dropdownValue == null) {
      return const SizedBox.shrink();
    }

    if (dropdownValue != _selectedCurrencyCode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_selectedCurrencyCode != dropdownValue) {
          setState(() => _selectedCurrencyCode = dropdownValue);
          widget.onCurrencyChanged(dropdownValue);
        }
      });
    }

    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: InputDecorator(
                  decoration: AppFormFields.decoration(
                    context,
                    labelText: l10n.walletFormCurrency,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      key: ValueKey(
                        'currency-${widget.row.id}-$dropdownValue',
                      ),
                      value: dropdownValue,
                      isExpanded: true,
                      style: AppFormFields.inputTextStyleFor(context.appColors),
                      dropdownColor: colors.dropdownBackground,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colors.textSecondary,
                      ),
                      items: items,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedCurrencyCode = value);
                        widget.onCurrencyChanged(value);
                      },
                    ),
                  ),
                ),
              ),
              if (widget.onRemove != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.close, size: 20),
                  color: colors.textSecondary,
                  tooltip: l10n.commonDelete,
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.row.balanceController,
            style: AppFormFields.inputTextStyleFor(context.appColors),
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
            ],
            decoration: AppFormFields.decoration(
              context,
              labelText:
                  widget.balanceFieldLabel ?? l10n.walletFormOpeningBalance,
              hintText: l10n.balanceHintZero,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value == '-') {
                return l10n.walletFormBalanceRequired;
              }
              if (double.tryParse(value) == null) {
                return l10n.walletFormInvalidNumber;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
