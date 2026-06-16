import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_form_fields.dart';
import '../../../core/theme/app_text_styles.dart';

/// Result from [DebtSettlementSheet].
class DebtSettlementResult {
  const DebtSettlementResult({
    required this.amount,
    this.notes,
  });

  final double amount;
  final String? notes;
}

/// Bottom sheet for partial or full debt pay / receive.
class DebtSettlementSheet extends StatefulWidget {
  const DebtSettlementSheet({
    super.key,
    required this.remaining,
    required this.currencyCode,
    required this.actionLabel,
  });

  final double remaining;
  final String currencyCode;
  final String actionLabel;

  @override
  State<DebtSettlementSheet> createState() => _DebtSettlementSheetState();
}

class _DebtSettlementSheetState extends State<DebtSettlementSheet> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = _formatAmount(widget.remaining);
  }

  String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toString();
  }

  double? _parseAmount() {
    final normalized = _amountController.text.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    final value = double.tryParse(normalized);
    if (value == null || value <= 0) return null;
    return value;
  }

  void _submit() {
    final amount = _parseAmount();
    if (amount == null) return;
    if (amount > widget.remaining + 0.000001) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.transactionDebtSettleExceedsRemaining)),
      );
      return;
    }

    Navigator.pop(
      context,
      DebtSettlementResult(
        amount: amount,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
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

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.actionLabel,
            style: AppTextStyles.headingSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.transactionDebtSettleTitle,
            style: AppFormFields.sectionLabelStyleOf(context),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppFormFields.inputTextStyleOf(context),
            decoration: AppFormFields.decoration(
              context,
              hintText: l10n.transactionDebtSettleHint,
            ).copyWith(suffixText: widget.currencyCode),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            style: AppFormFields.inputTextStyleOf(context),
            decoration: AppFormFields.decoration(
              context,
              hintText: l10n.transactionFormNotesHint,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.dashboardPrimary,
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(l10n.transactionDebtSettleConfirm),
          ),
        ],
      ),
    );
  }
}
