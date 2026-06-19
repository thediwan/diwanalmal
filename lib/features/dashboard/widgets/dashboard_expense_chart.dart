import 'package:flutter/material.dart';

import '../../../core/charts/models/chart_series.dart';
import '../../../core/charts/widgets/app_bar_chart.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/widgets/clay_card.dart';
import '../models/dashboard_models.dart';

/// Expense analysis section — daily / weekly bar chart with period toggle.
///
/// Section header and [_PeriodToggle] are retained from the original design.
/// The custom bar rendering is replaced by [AppBarChart] (backed by fl_chart),
/// wrapped in a [ClayCard] for consistent Claymorphism styling.
class DashboardExpenseChart extends StatefulWidget {
  const DashboardExpenseChart({
    super.key,
    required this.dailyPoints,
    required this.weeklyPoints,
    required this.currencyCode,
  });

  final List<DashboardChartPoint> dailyPoints;
  final List<DashboardChartPoint> weeklyPoints;
  final String currencyCode;

  @override
  State<DashboardExpenseChart> createState() => _DashboardExpenseChartState();
}

class _DashboardExpenseChartState extends State<DashboardExpenseChart> {
  bool _isDaily = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final rawPoints = _isDaily ? widget.dailyPoints : widget.weeklyPoints;
    final periodLabel =
        _isDaily ? l10n.dashboardLast7Days : l10n.dashboardLast4Weeks;

    // Convert DashboardChartPoint list to tagged ChartSeriesPoint list.
    final seriesPoints = ChartSeriesPoint.fromValues(
      labels: rawPoints.map((p) => p.label).toList(),
      values: rawPoints.map((p) => p.amount).toList(),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dashboardExpenseAnalysis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      periodLabel,
                      style: AppTextStyles.captionOnSurface(colors).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _PeriodToggle(
                isDaily: _isDaily,
                dailyLabel: l10n.dashboardDaily,
                weeklyLabel: l10n.dashboardWeekly,
                onChanged: (daily) => setState(() => _isDaily = daily),
                colors: colors,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart wrapped in clay card for consistent surface language
          ClayCard(
            elevation: ClayElevation.standard,
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
            child: AppBarChart(
              points: seriesPoints,
              currencyCode: widget.currencyCode,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Period toggle — retained unchanged from original implementation
// ---------------------------------------------------------------------------

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({
    required this.isDaily,
    required this.dailyLabel,
    required this.weeklyLabel,
    required this.onChanged,
    required this.colors,
  });

  final bool isDaily;
  final String dailyLabel;
  final String weeklyLabel;
  final ValueChanged<bool> onChanged;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleChip(
              label: dailyLabel,
              selected: isDaily,
              onTap: () => onChanged(true),
              colors: colors,
            ),
          ),
          Expanded(
            child: _ToggleChip(
              label: weeklyLabel,
              selected: !isDaily,
              onTap: () => onChanged(false),
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? colors.surface : Colors.transparent,
      elevation: selected ? 1 : 0,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: selected ? colors.textPrimary : colors.textMuted,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
