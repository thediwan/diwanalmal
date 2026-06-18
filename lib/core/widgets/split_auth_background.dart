import 'package:flutter/material.dart';

import '../extensions/context_theme.dart';

/// Split background for the security code screen.
class SplitAuthBackground extends StatelessWidget {
  const SplitAuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: ColoredBox(color: colors.surface)),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            colors.authGradientTop,
                            colors.authGradientBottom,
                          ]
                        : [
                            const Color(0xFFE8EAED),
                            const Color(0xFFD8DCE3).withValues(alpha: 0.95),
                          ],
                  ),
                ),
                child: CustomPaint(
                  painter: _DiagonalStreaksPainter(isDark: isDark),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }
}

/// Subtle diagonal highlights on the grey panel.
class _DiagonalStreaksPainter extends CustomPainter {
  const _DiagonalStreaksPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final highlight = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.22);
    final mid = isDark
        ? Colors.transparent
        : Colors.transparent;
    final low = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.white.withValues(alpha: 0.08);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [highlight, mid, low],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _DiagonalStreaksPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
