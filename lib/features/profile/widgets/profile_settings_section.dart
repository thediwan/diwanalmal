import 'package:flutter/material.dart';

import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/clay_card.dart';

/// Section title + clay card container for profile settings rows.
class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
          child: Text(
            title,
            style: AppTextStyles.label.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        ClayCard(
          elevation: ClayElevation.standard,
          padding: EdgeInsets.zero,
          child: Column(
            children: _withDividers(children, colors.divider),
          ),
        ),
      ],
    );
  }

  List<Widget> _withDividers(List<Widget> items, Color dividerColor) {
    if (items.isEmpty) return items;
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(Divider(height: 1, color: dividerColor, indent: 56));
      }
    }
    return result;
  }
}
