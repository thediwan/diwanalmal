import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/helpers/currency_formatter.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/auth_background.dart';
import '../../l10n/app_localizations.dart';
import 'models/goal_draft.dart';
import 'models/goal_plan_result.dart';

/// Shows alternative savings scenarios side by side.
class GoalPlanCompareScreen extends StatelessWidget {
  const GoalPlanCompareScreen({
    super.key,
    required this.draft,
    required this.plan,
  });

  final GoalDraft draft;
  final GoalPlanResult plan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      body: AuthBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CompareTopBar(
              title: l10n.goalPlanCompareTitle,
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: plan.alternatives.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final alternative = plan.alternatives[index];
                  return _CompareCard(
                    title: _labelForAlternative(l10n, alternative.key),
                    monthlyAmount: CurrencyFormatter.format(
                      alternative.monthlyAmount,
                      symbol: draft.currencySymbol,
                    ),
                    targetDate:
                        DateFormat.yMMMM(locale).format(alternative.targetDate),
                    isRecommended: alternative.isRecommended,
                    monthlyLabel: l10n.goalPlanCompareMonthly,
                    dateLabel: l10n.goalPlanCompareDate,
                    recommendedLabel: l10n.goalPlanCompareRecommended,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelForAlternative(AppLocalizations l10n, String key) {
    return switch (key) {
      'target_date' => l10n.goalPlanCompareTargetDate,
      'comfortable' => l10n.goalPlanCompareComfortable,
      'extended' => l10n.goalPlanCompareExtended,
      _ => l10n.goalPlanCompareTargetDate,
    };
  }
}

class _CompareTopBar extends StatelessWidget {
  const _CompareTopBar({
    required this.title,
    required this.onClose,
  });

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: colors.textPrimary,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headingSmall.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _CompareCard extends StatelessWidget {
  const _CompareCard({
    required this.title,
    required this.monthlyAmount,
    required this.targetDate,
    required this.isRecommended,
    required this.monthlyLabel,
    required this.dateLabel,
    required this.recommendedLabel,
  });

  final String title;
  final String monthlyAmount;
  final String targetDate;
  final bool isRecommended;
  final String monthlyLabel;
  final String dateLabel;
  final String recommendedLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRecommended
              ? Theme.of(context).colorScheme.primary
              : colors.cardBorder,
          width: isRecommended ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isRecommended)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    recommendedLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$monthlyLabel: $monthlyAmount',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$dateLabel: $targetDate',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
