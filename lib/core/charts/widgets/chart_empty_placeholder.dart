import 'package:flutter/material.dart';

import '../../extensions/context_theme.dart';
import '../../theme/app_text_styles.dart';

/// Shown when all chart values are zero or the series is empty.
class ChartEmptyPlaceholder extends StatelessWidget {
  const ChartEmptyPlaceholder({
    super.key,
    this.height = 248,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SizedBox(
      height: height,
      child: Center(
        child: Text(
          '—',
          style: AppTextStyles.captionOnSurface(colors).copyWith(
            fontSize: 22,
            color: colors.textMuted,
          ),
        ),
      ),
    );
  }
}

/// Internal helper — returns true when the series has no meaningful data.
bool isChartSeriesEmpty(List<double> values) =>
    values.isEmpty || values.every((v) => v <= 0);
