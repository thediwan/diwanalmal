import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

typedef ResponsiveWidgetBuilder = Widget Function(
  BuildContext context,
  WindowSizeClass sizeClass,
);

/// Classifies available width via [LayoutBuilder] and exposes [WindowSizeClass].
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.builder,
  });

  final ResponsiveWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sizeClass = windowSizeClassFor(constraints.maxWidth);
        return builder(context, sizeClass);
      },
    );
  }
}
