import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme_colors.dart';
import '../app_chart_theme.dart';
import '../models/chart_series.dart';

/// Converts [ChartSeriesPoint] list into a fully themed [BarChartData].
///
/// All styling decisions are delegated to [AppChartTheme] — this class
/// only handles data structure mapping.
abstract final class BarChartMapper {
  /// Maps a series of points to [BarChartData] ready for [BarChart].
  ///
  /// [rodWidthFraction] controls the bar width relative to each group slot
  /// (0.0–1.0). Default 0.55 matches the previous custom implementation.
  static BarChartData build({
    required List<ChartSeriesPoint> points,
    required String currencyCode,
    required bool isRtl,
    required AppThemeColors colors,
    required Color primary,
    double rodWidthFraction = 0.55,
  }) {
    final maxVal = points.fold(0.0, (m, p) => p.value > m ? p.value : m);
    final safeMax = maxVal > 0 ? maxVal : 1.0;

    // Rod pixel width is resolved at build time — fl_chart normalises group
    // slots across available width, so we use a logical pixel value that
    // scales reasonably. The LayoutBuilder in AppBarChart can override this.
    const double baseRodWidth = 18.0;

    final barGroups = List.generate(points.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          AppChartTheme.buildRod(
            point: points[i],
            rodWidth: baseRodWidth,
            primary: primary,
          ),
        ],
        showingTooltipIndicators: const [],
      );
    });

    return BarChartData(
      maxY: safeMax * 1.15, // 15% headroom so tallest bar is not flush to top
      minY: 0,
      barGroups: barGroups,
      groupsSpace: 4,
      gridData: AppChartTheme.gridData(colors),
      borderData: AppChartTheme.borderData(),
      titlesData: AppChartTheme.titlesData(
        points: points,
        currencyCode: currencyCode,
        isRtl: isRtl,
        colors: colors,
      ),
      barTouchData: AppChartTheme.touchData(
        currencyCode: currencyCode,
        colors: colors,
      ),
      alignment: BarChartAlignment.spaceEvenly,
    );
  }
}
