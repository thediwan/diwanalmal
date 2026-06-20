import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/extensions/context_l10n.dart';
import '../../../../core/helpers/treasury_filters.dart';
import '../../../../core/theme/app_form_fields.dart';
import '../../../../database/lazarus_database.dart';
import '../../../../models/treasury.dart';
import '../../../../providers/wallet_provider.dart';
import '../../../../services/lazarus_database_service.dart';
import '../../domain/entities/report_entities.dart';
import '../providers/monthly_report_provider.dart';

/// Bottom sheet to allocate monthly surplus to a financial goal.
class SurplusAllocationSheet extends StatefulWidget {
  const SurplusAllocationSheet({super.key, required this.report});

  final MonthlyReportSnapshot report;

  @override
  State<SurplusAllocationSheet> createState() => _SurplusAllocationSheetState();
}

class _SurplusAllocationSheetState extends State<SurplusAllocationSheet> {
  final _amountController = TextEditingController();

  List<FinancialGoal> _goals = [];
  List<Treasury> _wallets = [];
  String? _goalId;
  String? _walletId;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.report.availableSurplus.toStringAsFixed(2);
    _load();
  }

  Future<void> _load() async {
    final userId = await LazarusDatabaseService.instance.getActiveUserId();
    if (userId == null) return;

    final goals =
        await LazarusDatabaseService.instance.database.financeDao.getGoals(userId);
    if (!mounted) return;
    final treasuries = context.read<WalletProvider>().treasuries;
    final regular = regularTreasuries(treasuries);

    if (!mounted) return;
    setState(() {
      _goals = goals;
      _wallets = regular;
      _goalId = goals.isNotEmpty ? goals.first.id : null;
      _walletId = regular.isNotEmpty ? regular.first.id : null;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;
    if (_goalId == null || _walletId == null) return;

    setState(() => _saving = true);
    try {
      await context.read<MonthlyReportProvider>().allocateToGoal(
            year: widget.report.year,
            month: widget.report.month,
            goalId: _goalId!,
            sourceWalletId: _walletId!,
            amount: amount,
          );
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: _loading
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.reportTransferToGoal,
                  style: AppFormFields.sectionLabelStyleOf(context),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _goalId,
                  decoration: AppFormFields.decoration(context),
                  items: _goals
                      .map(
                        (g) => DropdownMenuItem(
                          value: g.id,
                          child: Text(g.title),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _goalId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _walletId,
                  decoration: AppFormFields.decoration(
                    context,
                    labelText: l10n.goalSavingsSelectWallet,
                  ),
                  items: _wallets
                      .map(
                        (w) => DropdownMenuItem(
                          value: w.id,
                          child: Text(w.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _walletId = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: AppFormFields.decoration(
                    context,
                    labelText: l10n.goalSavingsAmount,
                    suffixIcon: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 12),
                      child: Center(
                        widthFactor: 1,
                        child: Text(widget.report.baseCurrencyCode),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.commonSave),
                ),
              ],
            ),
    );
  }
}
