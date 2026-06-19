import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../helpers/currency_formatter.dart';
import '../theme/app_motion.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme_colors.dart';
import 'models/chart_series.dart';

/// Centralized fl_chart styling for ديوان المال.
///
/// All colors, typography, and animation durations are sourced exclusively
/// from existing design tokens — no values are hardcoded here.
///
/// Feature widgets never import fl_chart types directly; they call these
/// factories and pass the resulting data objects to [AppBarChart].
abstract final class AppChartTheme {
  // ---------------------------------------------------------------------------
  // Animation
  // ---------------------------------------------------------------------------

  /// Swap animation duration, respecting prefers-reduced-motion.
  static Duration animationDuration(BuildContext context) =>
      AppMotion.guardedDuration(context, AppMotion.emphasized);

  /// Easing to match emphasized financial moments.
  static const Curve animationCurve = AppMotion.easeEmphasized;

  // ---------------------------------------------------------------------------
  // Grid
  // ---------------------------------------------------------------------------

  /// Horizontal-only grid lines — vertical would add noise on a bar chart.
  static FlGridData gridData(AppThemeColors colors) => FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: null, // fl_chart auto-calculates
        getDrawingHorizontalLine: (_) => FlLine(
          color: colors.divider.withValues(alpha: 0.4),
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      );

  /// Hide the default chart border — the ClayCard container replaces it.
  static FlBorderData borderData() => FlBorderData(show: false);

  // ---------------------------------------------------------------------------
  // Axis titles
  // ---------------------------------------------------------------------------

  /// Y-axis (currency amounts).
  ///
  /// [isRtl] controls which side the axis labels appear on so they always
  /// sit on the leading edge in both LTR and RTL layouts.
  static SideTitles yTitles({
    required List<ChartSeriesPoint> points,
    required String currencyCode,
    required bool isRtl,
    required AppThemeColors colors,
  }) {
    final maxVal = points.fold(0.0, (m, p) => p.value > m ? p.value : m);

    String formatTick(double v) {
      if (v <= 0) return '0';
      return CurrencyFormatter.formatAmountOnly(v, decimals: 0);
    }

    return SideTitles(
      showTitles: true,
      reservedSize: 64,
      interval: maxVal > 0 ? maxVal / 3 : 1,
      getTitlesWidget: (value, meta) {
        if (value < 0) return const SizedBox.shrink();
        return SideTitleWidget(
          meta: meta,
          space: 4,
          child: Text(
            formatTick(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.captionOnSurface(colors).copyWith(
              fontSize: 10,
              fontWeight: value == maxVal ? FontWeight.w700 : FontWeight.w500,
              color: value == maxVal
                  ? AppColors.expense
                  : colors.textMuted,
            ),
          ),
        );
      },
    );
  }

  /// X-axis (date / week labels).
  static SideTitles xTitles({
    required List<ChartSeriesPoint> points,
    required AppThemeColors colors,
  }) {
    return SideTitles(
      showTitles: true,
      reservedSize: 36,
      getTitlesWidget: (value, meta) {
        final idx = value.toInt();
        if (idx < 0 || idx >= points.length) return const SizedBox.shrink();
        final point = points[idx];
        return SideTitleWidget(
          meta: meta,
          space: 4,
          child: Text(
            point.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.captionOnSurface(colors).copyWith(
              fontSize: 10,
              fontWeight: (point.isMax || point.isMin)
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: point.isMax
                  ? AppColors.expense
                  : point.isMin
                      ? colors.textSecondary
                      : colors.textMuted,
            ),
          ),
        );
      },
    );
  }

  /// Builds [FlTitlesData] with RTL-aware Y-axis side placement.
  static FlTitlesData titlesData({
    required List<ChartSeriesPoint> points,
    required String currencyCode,
    required bool isRtl,
    required AppThemeColors colors,
  }) {
    final ySide = yTitles(
      points: points,
      currencyCode: currencyCode,
      isRtl: isRtl,
      colors: colors,
    );
    final xSide = xTitles(points: points, colors: colors);

    return FlTitlesData(
      show: true,
      // Y-axis on leading edge for both directions
      leftTitles: AxisTitles(
        sideTitles: isRtl ? const SideTitles(showTitles: false) : ySide,
      ),
      rightTitles: AxisTitles(
        sideTitles: isRtl ? ySide : const SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(sideTitles: xSide),
    );
  }

  // ---------------------------------------------------------------------------
  // Bar rod color / gradient
  // ---------------------------------------------------------------------------

  /// Returns a [BarChartRodData] with correct semantic color and gradient.
  ///
  /// - Max bar → AppColors.expense (risk/highest spend signal)
  /// - Min positive bar → [primary] at 85% alpha
  /// - Others → [primary] at 45% alpha (muted)
  static BarChartRodData buildRod({
    required ChartSeriesPoint point,
    required double rodWidth,
    required Color primary,
  }) {
    final Color topColor;
    if (point.isMax) {
      topColor = AppColors.expense;
    } else if (point.isMin) {
      topColor = primary.withValues(alpha: 0.85);
    } else {
      topColor = primary.withValues(alpha: 0.45);
    }

    final bottomColor = topColor.withValues(alpha: topColor.a * 0.55);

    return BarChartRodData(
      toY: point.value,
      width: rodWidth,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(6),
        topRight: Radius.circular(6),
      ),
      gradient: LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [bottomColor, topColor],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Touch / tooltip
  // ---------------------------------------------------------------------------

  /// Touch data — shows a formatted tooltip on bar tap.
  static BarTouchData touchData({
    required String currencyCode,
    required AppThemeColors colors,
  }) =>
      BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => colors.surfaceElevated,
          tooltipBorderRadius: BorderRadius.circular(10),
          tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final amount = rod.toY;
            if (amount <= 0) return null;
            return BarTooltipItem(
              CurrencyFormatter.formatCodeFirst(amount, currencyCode),
              AppTextStyles.bodySmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            );
          },
        ),
      );
}
