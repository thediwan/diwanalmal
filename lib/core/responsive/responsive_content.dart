import 'package:flutter/material.dart';

import 'app_breakpoints.dart';
import 'responsive_layout.dart';
import 'responsive_spacing.dart';

/// Centers page content and applies horizontal padding with a max width on wider screens.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = AlignmentDirectional.topCenter,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsDirectional? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      builder: (context, sizeClass) {
        final resolvedMaxWidth = maxWidth ?? contentMaxWidthFor(sizeClass);
        final resolvedPadding =
            padding ?? ResponsiveSpacing.pageInsets(sizeClass);

        Widget content = Padding(
          padding: resolvedPadding,
          child: child,
        );

        if (resolvedMaxWidth.isFinite) {
          content = Align(
            alignment: alignment,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: resolvedMaxWidth),
              child: content,
            ),
          );
        }

        return content;
      },
    );
  }
}
