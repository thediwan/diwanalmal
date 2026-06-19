import 'package:flutter/material.dart';

import '../responsive/app_breakpoints.dart';
import '../responsive/responsive_content.dart';

/// Centers form content with a readable max width on all screen sizes.
class FormPageLayout extends StatelessWidget {
  const FormPageLayout({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.formMaxWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsDirectional? padding;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContent(
      maxWidth: maxWidth,
      padding: padding ??
          const EdgeInsetsDirectional.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
      alignment: AlignmentDirectional.topCenter,
      child: child,
    );
  }
}
