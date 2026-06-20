import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/category_icon_styles.dart';
import '../../../../core/constants/goal_icon_styles.dart';
import '../../../../core/charts/models/chart_series.dart';
import '../../../../core/charts/widgets/app_bar_chart.dart';
import '../../../../core/charts/widgets/app_line_chart.dart';
import '../../../../core/charts/widgets/app_pie_chart.dart';
import '../../../../core/extensions/context_feedback.dart';
import '../../../../core/extensions/context_l10n.dart';
import '../../../../core/extensions/context_theme.dart';
import '../../../../core/helpers/category_localization.dart';
import '../../../../core/helpers/currency_formatter.dart';
import '../../../../core/responsive/responsive_content.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/clay_card.dart';
import '../../../../providers/dashboard_refresh_provider.dart';
import '../../../../services/monthly_report_pdf_service.dart';
import '../../domain/entities/report_entities.dart';
import '../helpers/report_insight_localization.dart';
import '../providers/monthly_report_provider.dart';
import '../widgets/surplus_allocation_sheet.dart';

/// Full monthly financial report dashboard for one calendar month.
class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({
    super.key,
    required this.year,
    required this.month,
  });

  final int year;
  final int month;

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  final _pdfService = MonthlyReportPdfService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MonthlyReportProvider>().loadReport(
            year: widget.year,
            month: widget.month,
          );
    });
  }

  Future<void> _exportPdf(MonthlyReportSnapshot report) async {
    final l10n = context.l10n;
    final provider = context.read<MonthlyReportProvider>();
    provider.setExporting(true);
    try {
      await _pdfService.shareReport(report: report, l10n: l10n);
      if (mounted) context.showSuccessFeedback(l10n.reportPdfExportSuccess);
    } catch (_) {
      if (mounted) context.showErrorFeedback(l10n.reportPdfExportError);
    } finally {
      provider.setExporting(false);
    }
  }

  Future<void> _carryForward(MonthlyReportSnapshot report) async {
    await context.read<MonthlyReportProvider>().carryForward(
          year: report.year,
          month: report.month,
        );
    if (mounted) {
      context.showSuccessFeedback(context.l10n.reportSurplusSuccess);
      context.read<DashboardRefreshProvider>().notifyRefresh();
    }
  }

  Future<void> _openSurplusSheet(MonthlyReportSnapshot report) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SurplusAllocationSheet(report: report),
    );
    if (result == true && mounted) {
      context.showSuccessFeedback(context.l10n.reportSurplusSuccess);
      context.read<DashboardRefreshProvider>().notifyRefresh();
      await context.read<MonthlyReportProvider>().loadReport(
            year: widget.year,
            month: widget.month,
            refresh: true,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<MonthlyReportProvider>();
    final report = provider.current;

    if (provider.isLoading && report == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (report == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('—')),
      );
    }

    final monthLabel = DateFormat.yMMMM(l10n.localeName)
        .format(DateTime(report.year, report.month));
    final code = report.baseCurrencyCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(monthLabel),
        actions: [
          IconButton(
            onPressed: provider.isExporting ? null : () => _exportPdf(report),
            icon: provider.isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            tooltip: l10n.reportExportPdf,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadReport(
          year: widget.year,
          month: widget.month,
          refresh: true,
        ),
        child: ResponsiveContent(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _KpiGrid(report: report),
              const SizedBox(height: 16),
              if (report.insights.isNotEmpty) ...[
                _SectionTitle(l10n.reportSectionInsights),
                ...report.insights.map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ClayCard(
                      child: ListTile(
                        leading: Icon(
                          Icons.lightbulb_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          ReportInsightLocalization.text(l10n, insight),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              _SectionTitle(l10n.reportSectionExpenses),
              ClayCard(
                child: Column(
                  children: [
                    AppPieChart(
                      points: report.expenseBreakdown
                          .take(6)
                          .map(
                            (e) => ChartSeriesPoint(
                              label: CategoryLocalization.displayName(
                                l10n,
                                e.categoryId,
                                e.categoryName,
                              ),
                              value: e.totalBase,
                            ),
                          )
                          .toList(),
                      colors: report.expenseBreakdown
                          .take(6)
                          .map(
                            (e) => CategoryIconStyles.colorFor(e.colorHex),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    AppBarChart(
                      points: report.expenseBreakdown
                          .take(5)
                          .map(
                            (e) => ChartSeriesPoint(
                              label: CategoryLocalization.displayName(
                                l10n,
                                e.categoryId,
                                e.categoryName,
                              ),
                              value: e.totalBase,
                              kind: ChartPointKind.normal,
                            ),
                          )
                          .toList(),
                      currencyCode: code,
                      height: 200,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionTitle(l10n.reportSectionIncome),
              ClayCard(
                child: AppBarChart(
                  points: report.incomeBreakdown
                      .map(
                        (e) => ChartSeriesPoint(
                          label: CategoryLocalization.displayName(
                            l10n,
                            e.categoryId,
                            e.categoryName,
                          ),
                          value: e.totalBase,
                        ),
                      )
                      .toList(),
                  currencyCode: code,
                  height: 200,
                ),
              ),
              const SizedBox(height: 16),
              _SectionTitle(l10n.reportSectionSavings),
              ClayCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      CurrencyFormatter.formatWithCode(
                        report.totalGoalSavings,
                        code,
                      ),
                      style: AppTextStyles.headingSmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      l10n.reportInsightSavingsRate(
                        report.savingsRate.toStringAsFixed(0),
                      ),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...report.goalProgress.map(
                      (g) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(GoalIconStyles.iconFor(g.iconKey)),
                        title: Text(g.title),
                        trailing: Text('${g.progressPercent}%'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionTitle(l10n.reportSectionBudgets),
              if (report.budgetPerformance.isEmpty)
                ClayCard(
                  child: ListTile(
                    title: Text(l10n.reportNoBudgets),
                    trailing: TextButton(
                      onPressed: () => context.push('/budgets'),
                      child: Text(l10n.reportManageBudgets),
                    ),
                  ),
                )
              else
                ClayCard(
                  child: Column(
                    children: report.budgetPerformance.map((b) {
                      return ListTile(
                        title: Text(
                          CategoryLocalization.displayName(
                            l10n,
                            b.categoryId,
                            b.categoryName,
                          ),
                        ),
                        subtitle: LinearProgressIndicator(
                          value: (b.percentUsed / 100).clamp(0, 1),
                          color: b.percentUsed > 100
                              ? AppColors.expense
                              : Theme.of(context).colorScheme.primary,
                        ),
                        trailing: Text(
                          '${b.percentUsed.toStringAsFixed(0)}%',
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16),
              _SectionTitle(l10n.reportSectionSurplus),
              ClayCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SurplusRow(
                      label: l10n.reportMonthlySurplus,
                      value: report.surplus,
                      code: code,
                    ),
                    _SurplusRow(
                      label: l10n.reportPreviousCarryover,
                      value: report.previousCarryoverIn,
                      code: code,
                    ),
                    const Divider(),
                    _SurplusRow(
                      label: l10n.reportAvailableSurplus,
                      value: report.availableSurplus,
                      code: code,
                      emphasized: true,
                    ),
                    if (report.hasPendingSurplus) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _carryForward(report),
                              child: Text(l10n.reportCarryForward),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _openSurplusSheet(report),
                              child: Text(l10n.reportTransferToGoal),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionTitle(l10n.reportSectionTrend),
              ClayCard(
                child: AppLineChart(
                  incomePoints: report.trendPoints
                      .map(
                        (p) => ChartSeriesPoint(
                          label: DateFormat.MMM(l10n.localeName)
                              .format(DateTime(p.year, p.month)),
                          value: p.income,
                        ),
                      )
                      .toList(),
                  expensePoints: report.trendPoints
                      .map(
                        (p) => ChartSeriesPoint(
                          label: DateFormat.MMM(l10n.localeName)
                              .format(DateTime(p.year, p.month)),
                          value: p.expense,
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTextStyles.headingSmall),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.report});

  final MonthlyReportSnapshot report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final code = report.baseCurrencyCode;
    final items = <_KpiItem>[
      _KpiItem(l10n.reportKpiIncome, report.totalIncome, AppColors.success),
      _KpiItem(l10n.reportKpiExpense, report.totalExpense, AppColors.expense),
      _KpiItem(
        l10n.reportKpiSurplus,
        report.surplus,
        Theme.of(context).colorScheme.primary,
      ),
      _KpiItem(
        l10n.reportKpiSavingsRate,
        report.savingsRate,
        AppColors.success,
        isPercent: true,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth >= 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: items.map((item) {
            return ClayCard(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.appColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.isPercent
                          ? '${item.value.toStringAsFixed(1)}%'
                          : CurrencyFormatter.formatWithCode(item.value, code),
                      style: AppTextStyles.headingSmall.copyWith(
                        color: item.color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _KpiItem {
  const _KpiItem(this.label, this.value, this.color, {this.isPercent = false});

  final String label;
  final double value;
  final Color color;
  final bool isPercent;
}

class _SurplusRow extends StatelessWidget {
  const _SurplusRow({
    required this.label,
    required this.value,
    required this.code,
    this.emphasized = false,
  });

  final String label;
  final double value;
  final String code;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: emphasized
                ? AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)
                : AppTextStyles.bodyMedium,
          ),
          Text(
            CurrencyFormatter.formatWithCode(value, code),
            style: emphasized
                ? AppTextStyles.headingSmall
                : AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
