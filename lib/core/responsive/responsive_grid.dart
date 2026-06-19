import 'package:flutter/material.dart';

import 'app_breakpoints.dart';
import 'responsive_layout.dart';

/// Builds a grid whose column count adapts to available width.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = 16,
    this.runSpacing = 16,
    this.columnCountOverride,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double spacing;
  final double runSpacing;
  final int? columnCountOverride;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      builder: (context, sizeClass) {
        final columns = columnCountOverride ?? gridColumnCountFor(sizeClass);

        if (columns <= 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < itemCount; i++) ...[
                if (i > 0) SizedBox(height: runSpacing),
                itemBuilder(context, i),
              ],
            ],
          );
        }

        final rows = (itemCount / columns).ceil();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var row = 0; row < rows; row++) ...[
              if (row > 0) SizedBox(height: runSpacing),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var col = 0; col < columns; col++) ...[
                    if (col > 0) SizedBox(width: spacing),
                    Expanded(
                      child: _cellForRowColumn(row, col, columns),
                    ),
                  ],
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _cellForRowColumn(int row, int col, int columns) {
    final index = row * columns + col;
    if (index >= itemCount) {
      return const SizedBox.shrink();
    }
    return Builder(
      builder: (context) => itemBuilder(context, index),
    );
  }
}
