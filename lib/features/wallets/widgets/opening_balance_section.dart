import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_l10n.dart';
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
  });

  final List<OpeningBalanceRowState> rows;
  final List<Currency> currencies;
  final VoidCallback onAddRow;
  final ValueChanged<String> onRemoveRow;
  final void Function(String rowId, String? currencyCode) onCurrencyChanged;
  final Set<String> usedCurrencyCodes;
  final String? balanceFieldLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.walletFormOpeningBalance,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 10),
        for (final row in rows) ...[
          _OpeningBalanceRow(
            row: row,
            currencies: currencies,
            usedCurrencyCodes: usedCurrencyCodes,
            balanceFieldLabel: balanceFieldLabel,
            onCurrencyChanged: (code) => onCurrencyChanged(row.id, code),
            onRemove: rows.length > 1 ? () => onRemoveRow(row.id) : null,
          ),
          const SizedBox(height: 10),
        ],
        OutlinedButton.icon(
          onPressed: onAddRow,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.dashboardPrimary,
            side: const BorderSide(color: Color(0xFFBFDBFE)),
            backgroundColor: const Color(0xFFF0F5FF),
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
    );
  }
}

class _OpeningBalanceRow extends StatelessWidget {
  const _OpeningBalanceRow({
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: DropdownButtonFormField<String>(
              initialValue: row.currencyCode,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.walletFormCurrency,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: currencies.map((currency) {
                final isUsedElsewhere = usedCurrencyCodes.contains(currency.code) &&
                    row.currencyCode != currency.code;
                return DropdownMenuItem(
                  value: currency.code,
                  enabled: !isUsedElsewhere,
                  child: Text('${currency.name} (${currency.code})'),
                );
              }).toList(),
              onChanged: onCurrencyChanged,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: TextFormField(
              controller: row.balanceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: balanceFieldLabel ?? l10n.walletFormOpeningBalance,
                hintText: '0.00',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.walletFormBalanceRequired;
                }
                if (double.tryParse(value) == null) {
                  return l10n.walletFormInvalidNumber;
                }
                return null;
              },
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.textSecondaryLight,
              tooltip: l10n.commonDelete,
            ),
          ],
        ],
      ),
    );
  }
}
