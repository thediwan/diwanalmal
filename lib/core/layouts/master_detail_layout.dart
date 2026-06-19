import 'package:flutter/material.dart';

import '../extensions/context_theme.dart';
import '../responsive/app_breakpoints.dart';

/// List pane with a flexible detail pane for wide layouts.
class MasterDetailLayout extends StatelessWidget {
  const MasterDetailLayout({
    super.key,
    required this.master,
    required this.detail,
    this.masterWidth = AppBreakpoints.masterPaneWidth,
    this.showDivider = true,
  });

  final Widget master;
  final Widget detail;
  final double masterWidth;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: masterWidth,
          child: master,
        ),
        if (showDivider)
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: colors.divider,
          ),
        Expanded(child: detail),
      ],
    );
  }
}
