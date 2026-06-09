import 'package:flutter/material.dart';

import '../extensions/context_theme.dart';

/// Shared gradient background for authentication screens.
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.authGradientTop, colors.authGradientBottom],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
