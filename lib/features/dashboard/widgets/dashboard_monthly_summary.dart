import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/helpers/currency_formatter.dart';
import '../../../core/theme/app_text_styles.dart';

/// Three-column monthly income, expense, and debts row (RTL: income → expense → debts).
class DashboardMonthlySummary extends StatelessWidget {
  const DashboardMonthlySummary({
    super.key,
    required this.baseCode,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.debts,
  });

  final String baseCode;
  final double monthlyIncome;
  final double monthlyExpense;
  final double debts;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _SummaryCell(
                title: l10n.dashboardMonthlyIncome,
                value: CurrencyFormatter.formatCodeFirst(
                  monthlyIncome,
                  baseCode,
                ),
                valueColor: AppColors.success,
                changeText: l10n.dashboardIncomeChange(12),
                changeColor: AppColors.success,
              ),
            ),
            const _SectionDivider(),
            Expanded(
              child: _SummaryCell(
                title: l10n.dashboardMonthlyExpense,
                value: CurrencyFormatter.formatCodeFirst(
                  monthlyExpense,
                  baseCode,
                ),
                valueColor: AppColors.expense,
                changeText: monthlyExpense > 0
                    ? l10n.dashboardExpenseChange(5)
                    : null,
                changeColor: AppColors.expense,
              ),
            ),
            const _SectionDivider(),
            Expanded(
              child: _SummaryCell(
                title: l10n.dashboardDebts,
                value: CurrencyFormatter.formatCodeFirst(
                  debts,
                  baseCode,
                ),
                valueColor: AppColors.debtAccent,
                subtitle: l10n.dashboardDebtsOwedToOthers,
                subtitleColor: AppColors.debtAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: 1,
      thickness: 1,
      color: context.appColors.divider,
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.title,
    required this.value,
    required this.valueColor,
    this.subtitle,
    this.subtitleColor,
    this.changeText,
    this.changeColor,
  });

  final String title;
  final String value;
  final Color valueColor;
  final String? subtitle;
  final Color? subtitleColor;
  final String? changeText;
  final Color? changeColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelOnSurface(colors).copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: valueColor,
                fontSize: 15,
              ),
            ),
          ),
          if (changeText != null) ...[
            const SizedBox(height: 6),
            Text(
              changeText!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: changeColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: subtitleColor ?? AppColors.debtAccent,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
