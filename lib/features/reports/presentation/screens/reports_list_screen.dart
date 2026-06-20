import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_l10n.dart';
import '../../../../core/extensions/context_theme.dart';
import '../../../../core/helpers/currency_formatter.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/clay_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/report_entities.dart';
import '../providers/monthly_report_provider.dart';

/// Chronological list of monthly financial reports.
class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MonthlyReportProvider>().loadList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<MonthlyReportProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: l10n.reportCompareTitle,
            onPressed: () => context.push('/reports/compare'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadList(),
        child: provider.isLoading && provider.reports.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : provider.reports.isEmpty
                ? ListView(
                    children: [
                      EmptyState(
                        message:
                            '${l10n.reportsEmpty}\n${l10n.reportsEmptySubtitle}',
                        icon: Icons.description_outlined,
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.reports.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final report = provider.reports[index];
                      return _ReportListCard(report: report);
                    },
                  ),
      ),
    );
  }
}

class _ReportListCard extends StatelessWidget {
  const _ReportListCard({required this.report});

  final MonthlyReportSnapshot report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = DateFormat.yMMMM(l10n.localeName)
        .format(DateTime(report.year, report.month));
    final isDraft = report.status == MonthlyReportStatus.draft;

    return ClayCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/reports/${report.year}/${report.month}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(label, style: AppTextStyles.headingSmall),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isDraft ? AppColors.warning : AppColors.success)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isDraft ? l10n.reportStatusDraft : l10n.reportStatusFinalized,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDraft ? AppColors.warning : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MetricChip(
                    label: l10n.reportKpiIncome,
                    value: CurrencyFormatter.formatWithCode(
                      report.totalIncome,
                      report.baseCurrencyCode,
                    ),
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  _MetricChip(
                    label: l10n.reportKpiExpense,
                    value: CurrencyFormatter.formatWithCode(
                      report.totalExpense,
                      report.baseCurrencyCode,
                    ),
                    color: AppColors.expense,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.appColors.textMuted,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
