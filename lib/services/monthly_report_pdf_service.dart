import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../features/reports/domain/entities/report_entities.dart';
import '../features/reports/presentation/helpers/report_insight_localization.dart';
import '../l10n/app_localizations.dart';

/// Builds and shares multi-page PDF documents from frozen report snapshots.
class MonthlyReportPdfService {
  Future<File> exportReport({
    required MonthlyReportSnapshot report,
    required AppLocalizations l10n,
  }) async {
    final doc = pw.Document();
    final monthLabel = DateFormat.yMMMM(l10n.localeName)
        .format(DateTime(report.year, report.month));
    final currency = report.baseCurrencyCode;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              l10n.reportPdfCoverTitle,
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(monthLabel, style: const pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 32),
            pw.Text(l10n.reportPdfSummary,
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            _row(l10n.reportKpiIncome, _money(report.totalIncome, currency)),
            _row(l10n.reportKpiExpense, _money(report.totalExpense, currency)),
            _row(l10n.reportKpiSurplus, _money(report.surplus, currency)),
            _row(l10n.reportKpiSavingsRate, '${report.savingsRate.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );

    if (report.expenseBreakdown.isNotEmpty) {
      doc.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(l10n.reportPdfExpenses,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              ...report.expenseBreakdown.map(
                (e) => _row(
                  e.categoryName,
                  '${_money(e.totalBase, currency)} (${e.percentOfTotal.toStringAsFixed(0)}%)',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (report.incomeBreakdown.isNotEmpty) {
      doc.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(l10n.reportPdfIncome,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              ...report.incomeBreakdown.map(
                (e) => _row(e.categoryName, _money(e.totalBase, currency)),
              ),
            ],
          ),
        ),
      );
    }

    if (report.budgetPerformance.isNotEmpty) {
      doc.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(l10n.reportPdfBudgets,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              ...report.budgetPerformance.map(
                (b) => _row(
                  b.categoryName,
                  '${_money(b.actualBase, currency)} / ${_money(b.budgetAmount, currency)}',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (report.goalProgress.isNotEmpty) {
      doc.addPage(
        pw.Page(
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(l10n.reportPdfGoals,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              ...report.goalProgress.map(
                (g) => _row(
                  g.title,
                  '${g.progressPercent}% (${_money(g.savedAmount, currency)} / ${_money(g.targetAmount, currency)})',
                ),
              ),
            ],
          ),
        ),
      );
    }

    doc.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(l10n.reportPdfSurplus,
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            _row(l10n.reportMonthlySurplus, _money(report.surplus, currency)),
            _row(l10n.reportPreviousCarryover,
                _money(report.previousCarryoverIn, currency)),
            _row(l10n.reportAvailableSurplus,
                _money(report.availableSurplus, currency)),
            if (report.insights.isNotEmpty) ...[
              pw.SizedBox(height: 24),
              pw.Text(l10n.reportPdfInsights,
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              ...report.insights.map(
                (i) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: pw.Text('• ${ReportInsightLocalization.text(l10n, i)}'),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final fileName =
        'DewanAlmal_Report_${report.year}_${report.month.toString().padLeft(2, '0')}.pdf';
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> shareReport({
    required MonthlyReportSnapshot report,
    required AppLocalizations l10n,
  }) async {
    final file = await exportReport(report: report, l10n: l10n);
    await Share.shareXFiles([XFile(file.path)], subject: l10n.reportPdfCoverTitle);
  }

  pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(child: pw.Text(label)),
          pw.Text(value),
        ],
      ),
    );
  }

  String _money(double amount, String code) =>
      '$code ${amount.toStringAsFixed(2)}';
}
