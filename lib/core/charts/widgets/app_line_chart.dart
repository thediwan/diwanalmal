import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../extensions/context_theme.dart';
import '../../theme/app_motion.dart';
import '../app_chart_theme.dart';
import '../models/chart_series.dart';
import 'chart_empty_placeholder.dart';

/// Multi-series line chart for monthly income/expense trends.
class AppLineChart extends StatelessWidget {
  const AppLineChart({
    super.key,
    required this.incomePoints,
    required this.expensePoints,
    this.height = 220,
  });

  final List<ChartSeriesPoint> incomePoints;
  final List<ChartSeriesPoint> expensePoints;
  final double height;

  @override
  Widget build(BuildContext context) {
    final incomeValues = incomePoints.map((p) => p.value).toList();
    final expenseValues = expensePoints.map((p) => p.value).toList();
    if (isChartSeriesEmpty(incomeValues) && isChartSeriesEmpty(expenseValues)) {
      return ChartEmptyPlaceholder(height: height);
    }

    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;
    final maxVal = [
      ...incomeValues,
      ...expenseValues,
    ].fold(0.0, (m, v) => v > m ? v : m);
    final safeMax = maxVal > 0 ? maxVal : 1.0;

    LineChartBarData buildLine(List<ChartSeriesPoint> points, Color color) {
      return LineChartBarData(
        spots: List.generate(
          points.length,
          (i) => FlSpot(i.toDouble(), points[i].value),
        ),
        isCurved: true,
        color: color,
        barWidth: 3,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      );
    }

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: safeMax * 1.15,
          gridData: AppChartTheme.gridData(colors),
          borderData: AppChartTheme.borderData(),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= incomePoints.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      incomePoints[i].label,
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.textMuted,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            buildLine(incomePoints, primary),
            buildLine(expensePoints, AppColors.expense),
          ],
        ),
        duration: AppChartTheme.animationDuration(context),
        curve: AppMotion.easeEmphasized,
      ),
    );
  }
}
