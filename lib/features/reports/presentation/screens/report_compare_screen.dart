import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/extensions/context_l10n.dart';
import '../../../../core/helpers/currency_formatter.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/clay_card.dart';
import '../../domain/entities/report_entities.dart';
import '../providers/monthly_report_provider.dart';

/// Side-by-side comparison of two monthly reports.
class ReportCompareScreen extends StatefulWidget {
  const ReportCompareScreen({super.key});

  @override
  State<ReportCompareScreen> createState() => _ReportCompareScreenState();
}

class _ReportCompareScreenState extends State<ReportCompareScreen> {
  MonthlyReportSnapshot? _reportA;
  MonthlyReportSnapshot? _reportB;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<MonthlyReportProvider>().loadList();
    });
  }

  Future<void> _pickReport(bool isA) async {
    final provider = context.read<MonthlyReportProvider>();
    if (provider.reports.isEmpty) return;

    final picked = await showModalBottomSheet<MonthlyReportSnapshot>(
      context: context,
      builder: (context) => ListView(
        children: provider.reports
            .map(
              (r) => ListTile(
                title: Text(
                  DateFormat.yMMMM(context.l10n.localeName)
                      .format(DateTime(r.year, r.month)),
                ),
                onTap: () => Navigator.pop(context, r),
              ),
            )
            .toList(),
      ),
    );

    if (picked == null || !mounted) return;
    setState(() {
      if (isA) {
        _reportA = picked;
      } else {
        _reportB = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportCompareTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClayCard(
            child: ListTile(
              title: Text(l10n.reportSelectMonthA),
              subtitle: Text(_label(context, _reportA)),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => _pickReport(true),
            ),
          ),
          const SizedBox(height: 12),
          ClayCard(
            child: ListTile(
              title: Text(l10n.reportSelectMonthB),
              subtitle: Text(_label(context, _reportB)),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => _pickReport(false),
            ),
          ),
          if (_reportA != null && _reportB != null) ...[
            const SizedBox(height: 24),
            _CompareTable(reportA: _reportA!, reportB: _reportB!),
          ],
        ],
      ),
    );
  }

  String _label(BuildContext context, MonthlyReportSnapshot? report) {
    if (report == null) return '—';
    return DateFormat.yMMMM(context.l10n.localeName)
        .format(DateTime(report.year, report.month));
  }
}

class _CompareTable extends StatelessWidget {
  const _CompareTable({required this.reportA, required this.reportB});

  final MonthlyReportSnapshot reportA;
  final MonthlyReportSnapshot reportB;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final code = reportA.baseCurrencyCode;

    return ClayCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row(
              l10n.reportKpiIncome,
              reportA.totalIncome,
              reportB.totalIncome,
              code,
            ),
            _row(
              l10n.reportKpiExpense,
              reportA.totalExpense,
              reportB.totalExpense,
              code,
            ),
            _row(
              l10n.reportKpiSurplus,
              reportA.surplus,
              reportB.surplus,
              code,
            ),
            _row(
              l10n.reportKpiSavingsRate,
              reportA.savingsRate,
              reportB.savingsRate,
              code,
              isPercent: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String label,
    double a,
    double b,
    String code, {
    bool isPercent = false,
  }) {
    String fmt(double v) =>
        isPercent ? '${v.toStringAsFixed(1)}%' : CurrencyFormatter.formatWithCode(v, code);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: AppTextStyles.bodyMedium),
          ),
          Expanded(child: Text(fmt(a), textAlign: TextAlign.center)),
          Expanded(child: Text(fmt(b), textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
