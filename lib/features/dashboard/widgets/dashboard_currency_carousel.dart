import 'package:flutter/material.dart';

import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/helpers/currency_formatter.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/dashboard_currency_balances.dart';

/// Non-base currency balances in a three-column row with vertical dividers.
class DashboardCurrencyBalancesRow extends StatelessWidget {
  const DashboardCurrencyBalancesRow({
    super.key,
    required this.balances,
    required this.baseCode,
  });

  final List<DashboardCurrencyBalance> balances;
  final String baseCode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (balances.isEmpty) {
      return const SizedBox.shrink();
    }

    final visible = balances.length > 3 ? balances.take(3).toList() : balances;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < visible.length; i++) ...[
              if (i > 0) const _CurrencyDivider(),
              Expanded(
                child: _CurrencyCell(
                  balance: visible[i],
                  baseCode: baseCode,
                  approxLabel: l10n.dashboardApproxBase(
                    CurrencyFormatter.formatCodeFirst(
                      visible[i].balanceInBase,
                      baseCode,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CurrencyDivider extends StatelessWidget {
  const _CurrencyDivider();

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: 1,
      thickness: 1,
      color: context.appColors.divider,
    );
  }
}

class _CurrencyCell extends StatelessWidget {
  const _CurrencyCell({
    required this.balance,
    required this.baseCode,
    required this.approxLabel,
  });

  final DashboardCurrencyBalance balance;
  final String baseCode;
  final String approxLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final currency = balance.currency;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currency.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
              CurrencyFormatter.formatCodeFirst(
                balance.balanceInCurrency,
                currency.code,
              ),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              approxLabel,
              textAlign: TextAlign.center,
              style: AppTextStyles.captionOnSurface(colors).copyWith(
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
