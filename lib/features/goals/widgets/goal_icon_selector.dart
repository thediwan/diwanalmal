import 'package:flutter/material.dart';

import '../../../core/constants/goal_icon_styles.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_text_styles.dart';

/// Horizontal icon picker for financial goals.
class GoalIconSelector extends StatelessWidget {
  const GoalIconSelector({
    super.key,
    required this.selectedStyle,
    required this.onStyleSelected,
  });

  final String selectedStyle;
  final ValueChanged<String> onStyleSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: GoalIconStyles.selectable.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final style = GoalIconStyles.selectable[index];
          final isSelected = style == selectedStyle;

          return InkWell(
            onTap: () => onStyleSelected(style),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colors.inputFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : colors.inputBorder,
                  width: isSelected ? 2.5 : 1,
                ),
              ),
              child: Icon(
                GoalIconStyles.iconFor(style),
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : colors.textMuted,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Blue section label used on the add-goal form.
class GoalFormLabel extends StatelessWidget {
  const GoalFormLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.label.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
    );
  }
}
