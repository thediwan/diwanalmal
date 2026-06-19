import 'package:flutter/material.dart';

import '../extensions/context_theme.dart';
import '../responsive/responsive_content.dart';

/// Standard page scaffold with optional app bar and responsive body padding.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.useResponsiveContent = true,
    this.maxContentWidth,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool useResponsiveContent;
  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final resolvedBody = useResponsiveContent
        ? ResponsiveContent(maxWidth: maxContentWidth, child: body)
        : body;

    return Scaffold(
      backgroundColor: backgroundColor ?? colors.scaffoldBackground,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: resolvedBody,
    );
  }
}
