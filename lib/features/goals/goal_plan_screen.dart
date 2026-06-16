import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/goal_icon_styles.dart';
import '../../core/extensions/context_feedback.dart';
import '../../core/extensions/context_l10n.dart';
import '../../core/extensions/context_theme.dart';
import '../../core/helpers/currency_formatter.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/widgets/auth_background.dart';
import '../../l10n/app_localizations.dart';
import '../../services/goal_planning_service.dart';
import '../../services/goal_service.dart';
import '../../services/lazarus_database_service.dart';
import 'goal_plan_compare_screen.dart';
import 'models/goal_draft.dart';
import 'models/goal_plan_result.dart';

/// Phase 3 — show the computed savings plan after the user saves the draft.
class GoalPlanScreen extends StatefulWidget {
  const GoalPlanScreen({super.key, required this.draft});

  final GoalDraft draft;

  @override
  State<GoalPlanScreen> createState() => _GoalPlanScreenState();
}

class _GoalPlanScreenState extends State<GoalPlanScreen> {
  GoalPlanResult? _plan;
  bool _loading = true;
  bool _accepting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final plan = await GoalPlanningService(LazarusDatabaseService.instance)
          .buildPlan(widget.draft);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _acceptPlan() async {
    setState(() => _accepting = true);
    try {
      await GoalService(LazarusDatabaseService.instance)
          .createFromDraft(widget.draft);
      if (!mounted) return;
      context.showSuccessFeedback(context.l10n.goalPlanSaveSuccess);
      context.pop();
      if (mounted) context.pop('saved');
    } catch (e) {
      if (!mounted) return;
      context.showOperationError(e);
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  void _editGoal() {
    context.pop(widget.draft);
  }

  void _comparePlans() {
    final plan = _plan;
    if (plan == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GoalPlanCompareScreen(
          draft: widget.draft,
          plan: plan,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final locale = Localizations.localeOf(context).toString();

    return AuthBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PlanTopBar(
            title: l10n.goalPlanTitle,
            onClose: () => context.pop(),
          ),
          Expanded(
            child: _buildBody(colors, l10n, locale),
          ),
          if (_plan != null) _buildActions(colors, l10n),
        ],
      ),
    );
  }

  Widget _buildBody(AppThemeColors colors, AppLocalizations l10n, String locale) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadPlan,
                child: Text(l10n.dashboardRetry),
              ),
            ],
          ),
        ),
      );
    }

    final plan = _plan!;
    final draft = widget.draft;
    final monthlyLabel = l10n.goalPlanMonthlyAmount(
      CurrencyFormatter.format(
        plan.monthlyRequired,
        symbol: draft.currencySymbol,
      ),
    );
    final dateLabel = l10n.goalPlanReachDate(
      DateFormat.yMMMM(locale).format(draft.targetDate),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        children: [
          Icon(
            GoalIconStyles.iconFor(draft.iconStyle),
            size: 48,
            color: AppColors.dashboardPrimary,
          ),
          const SizedBox(height: 12),
          Text(
            draft.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headingSmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.goalPlanIntro,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PlanRow(
                  icon: Icons.savings_outlined,
                  text: monthlyLabel,
                ),
                const SizedBox(height: 14),
                _PlanRow(
                  icon: Icons.event_outlined,
                  text: dateLabel,
                ),
                if (plan.isLargeAmountWarning) ...[
                  const SizedBox(height: 16),
                  _WarningBanner(
                    text: l10n.goalPlanWarningLargeAmount,
                  ),
                ],
                if (plan.isUnrealisticDateWarning) ...[
                  const SizedBox(height: 12),
                  _WarningBanner(
                    text: l10n.goalPlanWarningUnrealisticDate,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(AppThemeColors colors, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          FilledButton(
            onPressed: _accepting ? null : _acceptPlan,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.dashboardPrimary,
              foregroundColor: colors.onPrimary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: _accepting
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onPrimary,
                    ),
                  )
                : Text(
                    l10n.goalPlanAccept,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onPrimary,
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _editGoal,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: BorderSide(color: colors.cardBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(l10n.goalPlanEdit),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: _comparePlans,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppColors.dashboardPrimary),
                    foregroundColor: AppColors.dashboardPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(l10n.goalPlanCompare),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanTopBar extends StatelessWidget {
  const _PlanTopBar({
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
                color: AppColors.dashboardPrimary,
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

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        Icon(icon, color: AppColors.dashboardPrimary, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyLarge.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warning,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
