import 'package:flutter/material.dart';

/// Split background for the security code screen (white + grey panels).
class SplitAuthBackground extends StatelessWidget {
  const SplitAuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(child: ColoredBox(color: Colors.white)),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFE8EAED),
                      const Color(0xFFD8DCE3).withValues(alpha: 0.95),
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: _DiagonalStreaksPainter(),
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.white.withValues(alpha: 0.22),
          Colors.transparent,
          Colors.white.withValues(alpha: 0.08),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
