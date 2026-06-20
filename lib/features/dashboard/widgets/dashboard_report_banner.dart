import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_l10n.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/clay_card.dart';
import '../../../features/reports/domain/entities/report_entities.dart';
import '../../../features/reports/presentation/providers/monthly_report_provider.dart';

/// Prompts the user when a draft monthly report is available.
class DashboardReportBanner extends StatelessWidget {
  const DashboardReportBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = context.watch<MonthlyReportProvider>();
    final now = DateTime.now();
    MonthlyReportSnapshot? draft;

    for (final report in provider.reports) {
      if (report.year == now.year &&
          report.month == now.month &&
          report.status == MonthlyReportStatus.draft) {
        draft = report;
        break;
      }
    }

    final previous = DateTime(now.year, now.month - 1);
    draft ??= provider.reports
        .where(
          (r) =>
              r.year == previous.year &&
              r.month == previous.month &&
              r.status == MonthlyReportStatus.draft,
        )
        .firstOrNull;

    if (draft == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClayCard(
        child: ListTile(
          leading: Icon(
            Icons.insights_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            l10n.reportBannerReady,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing: TextButton(
            onPressed: () =>
                context.push('/reports/${draft!.year}/${draft.month}'),
            child: Text(l10n.reportBannerOpen),
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
