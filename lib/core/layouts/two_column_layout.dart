import 'package:flutter/material.dart';

/// Primary and secondary columns with configurable flex ratios.
class TwoColumnLayout extends StatelessWidget {
  const TwoColumnLayout({
    super.key,
    required this.primary,
    required this.secondary,
    this.primaryFlex = 5,
    this.secondaryFlex = 4,
    this.spacing = 24,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final Widget primary;
  final Widget secondary;
  final int primaryFlex;
  final int secondaryFlex;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Expanded(flex: primaryFlex, child: primary),
        SizedBox(width: spacing),
        Expanded(flex: secondaryFlex, child: secondary),
      ],
    );
  }
}
