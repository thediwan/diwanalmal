import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/app_motion.dart';
import '../app_chart_theme.dart';
import '../models/chart_series.dart';
import 'chart_empty_placeholder.dart';

/// Pie chart for category distribution (expense/income breakdown).
class AppPieChart extends StatelessWidget {
  const AppPieChart({
    super.key,
    required this.points,
    required this.colors,
    this.height = 220,
  });

  final List<ChartSeriesPoint> points;
  final List<Color> colors;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (isChartSeriesEmpty(points.map((p) => p.value).toList())) {
      return ChartEmptyPlaceholder(height: height);
    }

    final total = points.fold<double>(0, (s, p) => s + p.value);
    final sections = List.generate(points.length, (i) {
      final color =
          colors.length > i ? colors[i] : Theme.of(context).colorScheme.primary;
      return PieChartSectionData(
        value: points[i].value,
        title: total <= 0
            ? ''
            : '${((points[i].value / total) * 100).round()}%',
        color: color,
        radius: 56,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );
    });

    return SizedBox(
      height: height,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 2,
          centerSpaceRadius: 36,
          borderData: FlBorderData(show: false),
        ),
        duration: AppChartTheme.animationDuration(context),
        curve: AppMotion.easeEmphasized,
      ),
    );
  }
}
