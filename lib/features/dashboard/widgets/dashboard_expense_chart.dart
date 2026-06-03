import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/dashboard_models.dart';

/// Expense analysis: header row + area spline chart (custom painter).
class DashboardExpenseChart extends StatefulWidget {
  const DashboardExpenseChart({
    super.key,
    required this.dailyPoints,
    required this.weeklyPoints,
  });

  final List<DashboardChartPoint> dailyPoints;
  final List<DashboardChartPoint> weeklyPoints;

  @override
  State<DashboardExpenseChart> createState() => _DashboardExpenseChartState();
}

class _DashboardExpenseChartState extends State<DashboardExpenseChart> {
  bool _isDaily = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final points = _isDaily ? widget.dailyPoints : widget.weeklyPoints;

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
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.dashboardLast30Days,
                      style: AppTextStyles.labelOnLight.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF9CA3AF),
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
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _SplineAreaChartPainter(points: points),
              child: Padding(
                padding: const EdgeInsets.only(top: 148),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: points
                      .map(
                        (p) => Text(
                          p.label,
                          style: AppTextStyles.captionOnLight.copyWith(
                            fontSize: 11,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({
    required this.isDaily,
    required this.dailyLabel,
    required this.weeklyLabel,
    required this.onChanged,
  });

  final bool isDaily;
  final String dailyLabel;
  final String weeklyLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleChip(
              label: dailyLabel,
              selected: isDaily,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _ToggleChip(
              label: weeklyLabel,
              selected: !isDaily,
              onTap: () => onChanged(false),
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
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
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
              color: selected
                  ? AppColors.textPrimaryLight
                  : const Color(0xFF9CA3AF),
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// Spline line with light blue gradient fill under the curve.
class _SplineAreaChartPainter extends CustomPainter {
  _SplineAreaChartPainter({required this.points});

  final List<DashboardChartPoint> points;

  Path _buildCurvePath(List<Offset> coords) {
    final path = Path()..moveTo(coords.first.dx, coords.first.dy);
    for (var i = 0; i < coords.length - 1; i++) {
      final current = coords[i];
      final next = coords[i + 1];
      final controlX = (current.dx + next.dx) / 2;
      path.cubicTo(
        controlX,
        current.dy,
        controlX,
        next.dy,
        next.dx,
        next.dy,
      );
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    const topPadding = 16.0;
    const bottomPadding = 32.0;
    final chartHeight = size.height - topPadding - bottomPadding;
    final chartWidth = size.width;
    final baseline = size.height - bottomPadding;

    final coords = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final x = chartWidth * i / (points.length - 1);
      final y = topPadding + chartHeight * (1 - points[i].value);
      coords.add(Offset(x, y));
    }

    final curve = _buildCurvePath(coords);
    final fillPath = Path.from(curve)
      ..lineTo(coords.last.dx, baseline)
      ..lineTo(coords.first.dx, baseline)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.dashboardPrimary.withValues(alpha: 0.25),
          AppColors.dashboardPrimary.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, topPadding, chartWidth, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = AppColors.dashboardPrimary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(curve, linePaint);

    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotPaint = Paint()
      ..color = AppColors.dashboardPrimary
      ..style = PaintingStyle.fill;
    final dotBorder = Paint()
      ..color = AppColors.dashboardPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final point in coords) {
      canvas.drawCircle(point, 6, ringPaint);
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 4, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _SplineAreaChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
