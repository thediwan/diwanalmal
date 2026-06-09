import 'package:flutter/material.dart';

import '../../../core/extensions/context_theme.dart';

/// Subtle horizontal rule between dashboard sections.
class DashboardSectionDivider extends StatelessWidget {
  const DashboardSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Divider(
        height: 1,
        thickness: 1,
        color: context.appColors.divider,
      ),
    );
  }
}
