import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/helpers/currency_formatter.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../models/dashboard_models.dart';

/// Expense analysis: vertical bar chart with daily / weekly toggle.
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
    final points = _isDaily ? widget.dailyPoints : widget.weeklyPoints;
    final periodLabel =
        _isDaily ? l10n.dashboardLast7Days : l10n.dashboardLast4Weeks;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          _ExpenseBarChart(
            points: points,
            currencyCode: widget.currencyCode,
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _ExpenseBarChart extends StatelessWidget {
  const _ExpenseBarChart({
    required this.points,
    required this.currencyCode,
    required this.colors,
  });

  final List<DashboardChartPoint> points;
  final String currencyCode;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '—',
            style: AppTextStyles.captionOnSurface(colors),
          ),
        ),
      );
    }

    final amounts = points.map((p) => p.amount).toList();
    final positiveAmounts = amounts.where((a) => a > 0).toList();
    final maxAmount = amounts.reduce((a, b) => a > b ? a : b);
    final minAmount = positiveAmounts.isEmpty
        ? 0.0
        : positiveAmounts.reduce((a, b) => a < b ? a : b);
    final maxIndex = amounts.indexOf(maxAmount);
    final minIndex = positiveAmounts.isEmpty
        ? -1
        : amounts.indexOf(minAmount);
    final scaleMax = maxAmount <= 0 ? 1.0 : maxAmount;
    final scaleTicks = _buildScaleTicks(minAmount, scaleMax);

    double normalizeAmount(double amount) {
      if (scaleMax <= 0 || amount <= 0) return 0;
      return (amount / scaleMax).clamp(0.0, 1.0);
    }

    return SizedBox(
      height: 248,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 72,
            child: LayoutBuilder(
              builder: (context, constraints) {
                const bottomLabelReserve = 36.0;
                const topPadding = 8.0;
                final plotHeight =
                    constraints.maxHeight - bottomLabelReserve - topPadding;

                return Padding(
                  padding: const EdgeInsets.only(top: topPadding, bottom: bottomLabelReserve),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      for (final tick in scaleTicks)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: _tickTopForAmount(
                            amount: tick,
                            scaleMax: scaleMax,
                            plotHeight: plotHeight,
                          ),
                          child: Transform.translate(
                            offset: const Offset(0, -8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  CurrencyFormatter.formatCodeFirst(
                                    tick,
                                    currencyCode,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.captionOnSurface(colors)
                                      .copyWith(
                                    fontSize: 10,
                                    fontWeight: tick == scaleMax
                                        ? FontWeight.w800
                                        : tick == minAmount && tick > 0
                                            ? FontWeight.w700
                                            : tick == 0
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                    color: tick == scaleMax
                                        ? AppColors.expense
                                        : tick == minAmount && tick > 0
                                            ? colors.textSecondary
                                            : colors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 8,
                  bottom: 36,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          for (final tick in scaleTicks)
                            Positioned(
                              left: 0,
                              right: 0,
                              top: _tickTopForAmount(
                                amount: tick,
                                scaleMax: scaleMax,
                                plotHeight: constraints.maxHeight,
                              ),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color: colors.divider.withValues(
                                  alpha: tick == scaleMax ||
                                          tick == 0 ||
                                          (tick == minAmount && tick > 0)
                                      ? 0.55
                                      : 0.28,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < points.length; i++)
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 4,
                                ),
                                child: _ChartBarSlot(
                                  amount: points[i].amount,
                                  normalizedHeight: normalizeAmount(
                                    points[i].amount,
                                  ),
                                  isMax: i == maxIndex && points[i].amount > 0,
                                  isMin: i == minIndex && minIndex >= 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              points[i].label,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.captionOnSurface(colors)
                                  .copyWith(
                                fontSize: 10,
                                fontWeight: i == maxIndex || i == minIndex
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: i == maxIndex
                                    ? AppColors.expense
                                    : i == minIndex
                                        ? colors.textSecondary
                                        : colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Y-axis ticks: starts at 0, first step is [minPositive], up to [max].
  static List<double> _buildScaleTicks(double minPositive, double max) {
    if (max <= 0) return [0];
    if (minPositive <= 0 || minPositive >= max) {
      return [0, max];
    }

    final mid = minPositive + (max - minPositive) / 2;
    return [0, minPositive, mid, max];
  }

  /// Maps an amount to a vertical offset within the plot (0 = top/max).
  static double _tickTopForAmount({
    required double amount,
    required double scaleMax,
    required double plotHeight,
  }) {
    if (plotHeight <= 0 || scaleMax <= 0) return 0;
    final ratio = (amount / scaleMax).clamp(0.0, 1.0);
    return plotHeight * (1 - ratio);
  }
}

/// Single bar column — shares the same [Expanded] slot as its date label below.
class _ChartBarSlot extends StatelessWidget {
  const _ChartBarSlot({
    required this.amount,
    required this.normalizedHeight,
    required this.isMax,
    required this.isMin,
  });

  final double amount;
  final double normalizedHeight;
  final bool isMax;
  final bool isMin;

  @override
  Widget build(BuildContext context) {
    final baseColor = isMax
        ? AppColors.expense
        : isMin
            ? AppColors.dashboardPrimary.withValues(alpha: 0.85)
            : AppColors.dashboardPrimary.withValues(alpha: 0.45);

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth * 0.55;
        final barHeight = constraints.maxHeight * normalizedHeight;

        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  baseColor.withValues(alpha: 0.55),
                  baseColor,
                ],
              ),
              borderRadius: BorderRadius.circular(6),
              border: amount > 0 && barHeight >= 4
                  ? Border.all(color: baseColor.withValues(alpha: 0.2))
                  : null,
            ),
          ),
        );
      },
    );
  }
}

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
        borderRadius: BorderRadius.circular(999),
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
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
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
