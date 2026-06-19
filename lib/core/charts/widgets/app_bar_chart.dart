import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../extensions/context_theme.dart';
import '../../theme/app_motion.dart';
import '../app_chart_theme.dart';
import '../mappers/bar_chart_mapper.dart';
import '../models/chart_series.dart';
import 'chart_empty_placeholder.dart';

/// A themed, reusable bar chart widget.
///
/// Accepts pre-tagged [ChartSeriesPoint] list and a [currencyCode] for axis
/// and tooltip formatting. All fl_chart configuration is handled internally
/// via [BarChartMapper] and [AppChartTheme].
///
/// Feature widgets should NOT import fl_chart directly — consume this widget.
///
/// Empty or all-zero series renders [ChartEmptyPlaceholder] without crashing.
///
/// RTL support: Y-axis labels move to the right (leading edge) automatically
/// when [Directionality] is [TextDirection.rtl].
///
/// Reduced motion: The swap animation duration is [Duration.zero] when
/// [MediaQueryData.disableAnimations] is set.
///
/// Usage:
/// ```dart
/// AppBarChart(
///   points: mappedPoints,
///   currencyCode: 'SAR',
/// )
/// ```
class AppBarChart extends StatelessWidget {
  const AppBarChart({
    super.key,
    required this.points,
    required this.currencyCode,
    this.height = 248,
  });

  final List<ChartSeriesPoint> points;
  final String currencyCode;

  /// Fixed height in logical pixels. Matches previous custom chart height.
  final double height;

  @override
  Widget build(BuildContext context) {
    // Empty / all-zero → show placeholder
    if (isChartSeriesEmpty(points.map((p) => p.value).toList())) {
      return ChartEmptyPlaceholder(height: height);
    }

    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final duration = AppChartTheme.animationDuration(context);

    final data = BarChartMapper.build(
      points: points,
      currencyCode: currencyCode,
      isRtl: isRtl,
      colors: colors,
      primary: primary,
    );

    return SizedBox(
      height: height,
      child: BarChart(
        data,
        duration: duration,
        curve: AppMotion.easeEmphasized,
      ),
    );
  }
}
