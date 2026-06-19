import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/brand_logo_assets.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/helpers/currency_formatter.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/widgets/clay_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/profile_provider.dart';

/// Card proportions (40 × 22) — slightly taller than 40:21 so hero content fits
/// without vertical overflow on compact widths.
const double _kCardAspectRatio = 40 / 22;

/// Caps card width on large screens so typography and layout stay crisp.
const double _kCardMaxWidth = 440.0;

const double _kCardRadius = 12.0;

const String _kCardBgLight = 'assets/images/card-bg-light.jpg';
const String _kCardBgDark = 'assets/images/card-bg-dark.jpg';

/// Hero balance card — realistic credit-card layout with theme backgrounds.
/// Tap anywhere on the card to open quick actions.
class DashboardBalanceHeroCard extends StatefulWidget {
  const DashboardBalanceHeroCard({
    super.key,
    required this.label,
    required this.amount,
    required this.currencyCode,
    required this.monthlyIncome,
    required this.monthlyExpense,
    this.isLoading = false,
  });

  final String label;
  final double amount;
  final String currencyCode;
  final double monthlyIncome;
  final double monthlyExpense;
  final bool isLoading;

  @override
  State<DashboardBalanceHeroCard> createState() =>
      _DashboardBalanceHeroCardState();
}

class _DashboardBalanceHeroCardState extends State<DashboardBalanceHeroCard>
    with TickerProviderStateMixin {
  AnimationController? _countController;
  Animation<double>? _countUpAnimation;
  AnimationController? _pressController;

  double _previousAmount = 0;
  double _tiltX = 0;
  double _tiltY = 0;
  bool _countStarted = false;

  @override
  void initState() {
    super.initState();
    _ensureAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startCountAnimationIfNeeded();
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    _ensureAnimations();
  }

  void _ensureAnimations() {
    _countController ??= AnimationController(
      vsync: this,
      duration: AppMotion.emphasized,
    );
    _countUpAnimation ??= Tween<double>(begin: 0, end: widget.amount).animate(
      CurvedAnimation(
        parent: _countController!,
        curve: AppMotion.easeEmphasized,
      ),
    );

    _pressController ??= AnimationController(
      vsync: this,
      duration: AppMotion.micro,
      reverseDuration: const Duration(milliseconds: 220),
    );
  }

  void _startCountAnimationIfNeeded() {
    if (_countStarted || _countController == null) return;
    _countStarted = true;
    if (AppMotion.shouldAnimate(context)) {
      _countController!.forward();
    }
  }

  @override
  void didUpdateWidget(DashboardBalanceHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount && _countController != null) {
      _previousAmount = oldWidget.amount;
      _countUpAnimation = Tween<double>(
        begin: _previousAmount,
        end: widget.amount,
      ).animate(
        CurvedAnimation(
          parent: _countController!,
          curve: AppMotion.easeEmphasized,
        ),
      );
      _countController!
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _countController?.dispose();
    _pressController?.dispose();
    super.dispose();
  }

  double get _pressScaleValue {
    final controller = _pressController;
    if (controller == null) return 1.0;
    return lerpDouble(1.0, AppMotion.pressScale, controller.value) ?? 1.0;
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (!AppMotion.shouldAnimate(context)) return;
    setState(() {
      _tiltY = (_tiltY + details.delta.dx / size.width * 0.35)
          .clamp(-0.06, 0.06);
      _tiltX = (_tiltX - details.delta.dy / size.height * 0.35)
          .clamp(-0.06, 0.06);
    });
  }

  void _onPanEnd(DragEndDetails _) {
    if (!AppMotion.shouldAnimate(context)) return;
    setState(() {
      _tiltX = 0;
      _tiltY = 0;
    });
  }

  void _onTapDown(TapDownDetails _) {
    if (!AppMotion.shouldAnimate(context)) return;
    _pressController?.forward();
  }

  void _onTapUp(TapUpDetails _) {
    if (!AppMotion.shouldAnimate(context)) return;
    _pressController?.reverse();
  }

  void _onTapCancel() {
    if (!AppMotion.shouldAnimate(context)) return;
    _pressController?.reverse();
  }

  void _showCardOptions(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CardActionSheet(
        l10n: l10n,
        colors: colors,
        currencyCode: widget.currencyCode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _ensureAnimations();

    if (widget.isLoading) {
      return const _BalanceHeroSkeleton();
    }

    final l10n = context.l10n;
    final palette = _CreditCardPalette.of(context);
    final holderName = context.watch<ProfileProvider>().profile?.displayName ??
        AppConstants.appName;
    final expLabel = DateFormat('MM/yy').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kCardMaxWidth),
          child: AspectRatio(
            aspectRatio: _kCardAspectRatio,
            child: LayoutBuilder(
          builder: (context, constraints) {
            final cardSize = Size(constraints.maxWidth, constraints.maxHeight);

            return Semantics(
              label: widget.label,
              button: true,
              child: GestureDetector(
                onTap: () => _showCardOptions(context),
                onPanUpdate: (d) => _onPanUpdate(d, cardSize),
                onPanEnd: _onPanEnd,
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                child: AnimatedBuilder(
                  animation: _pressController!,
                  builder: (context, child) {
                    final scale = _pressScaleValue;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_tiltX)
                        ..rotateY(_tiltY)
                        ..scaleByDouble(scale, scale, scale, 1.0),
                      child: child,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_kCardRadius),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Theme background image
                        Image.asset(
                          palette.backgroundAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => ColoredBox(
                            color: palette.fallbackColor,
                          ),
                        ),
                        // Subtle scrim for text legibility
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: palette.scrimGradient,
                          ),
                        ),
                        // Card content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Top row: chip + contactless | brand
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _EmvChip(),
                                  const SizedBox(width: 10),
                                  Icon(
                                    Icons.contactless_rounded,
                                    size: 26,
                                    color: palette.primaryText
                                        .withValues(alpha: 0.85),
                                  ),
                                  const Spacer(),
                                  _BrandMark(palette: palette),
                                ],
                              ),
                              Expanded(
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: AnimatedBuilder(
                                      animation: _countUpAnimation!,
                                      builder: (context, _) {
                                        final displayAmount =
                                            AppMotion.shouldAnimate(context)
                                                ? _countUpAnimation!.value
                                                : widget.amount;
                                        return _BalanceHeroCenter(
                                          amount: displayAmount,
                                          currencyCode: widget.currencyCode,
                                          monthlyIncome: widget.monthlyIncome,
                                          monthlyExpense: widget.monthlyExpense,
                                          palette: palette,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              // Footer: holder | expiry
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: _CardMetaColumn(
                                      label: l10n.dashboardBalanceCardHolder,
                                      value: holderName,
                                      palette: palette,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  _CardMetaColumn(
                                    label: l10n.dashboardBalanceCardExpDate,
                                    value: expLabel,
                                    palette: palette,
                                    alignEnd: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Soft edge highlight
                        IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(_kCardRadius),
                              border: Border.all(
                                color: palette.borderColor,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Theme-aware palette (text + scrim over background images)
// ---------------------------------------------------------------------------

class _CreditCardPalette {
  const _CreditCardPalette({
    required this.isDark,
    required this.backgroundAsset,
    required this.fallbackColor,
    required this.scrimGradient,
    required this.primaryText,
    required this.labelText,
    required this.brandTextColor,
    required this.borderColor,
    required this.chipColors,
  });

  final bool isDark;
  final String backgroundAsset;
  final Color fallbackColor;
  final Gradient scrimGradient;
  final Color primaryText;
  final Color labelText;
  final Color brandTextColor;
  final Color borderColor;
  final List<Color> chipColors;

  factory _CreditCardPalette.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return _CreditCardPalette(
        isDark: true,
        backgroundAsset: _kCardBgDark,
        fallbackColor: const Color(0xFF1A1035),
        scrimGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withValues(alpha: 0.08),
            Colors.black.withValues(alpha: 0.22),
            Colors.black.withValues(alpha: 0.35),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        primaryText: Colors.white.withValues(alpha: 0.96),
        labelText: Colors.white.withValues(alpha: 0.62),
        brandTextColor: Colors.white.withValues(alpha: 0.92),
        borderColor: Colors.white.withValues(alpha: 0.14),
        chipColors: const [
          Color(0xFFE8C872),
          Color(0xFFD4AF37),
          Color(0xFFC9A227),
        ],
      );
    }

    return _CreditCardPalette(
      isDark: false,
      backgroundAsset: _kCardBgLight,
      fallbackColor: Theme.of(context).colorScheme.primaryContainer,
      scrimGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.28),
          Colors.black.withValues(alpha: 0.10),
        ],
        stops: const [0.0, 0.45, 1.0],
      ),
      primaryText: const Color(0xFF0A1220),
      labelText: const Color(0xFF1E293B),
      brandTextColor: const Color(0xFF051018),
      borderColor: Colors.white.withValues(alpha: 0.45),
      chipColors: const [
        Color(0xFFE8C872),
        Color(0xFFD4AF37),
        Color(0xFFC9A227),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// EMV chip decoration
// ---------------------------------------------------------------------------

class _EmvChip extends StatelessWidget {
  const _EmvChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8C872),
            Color(0xFFD4AF37),
            Color(0xFFC9A227),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _ChipLinesPainter(),
      ),
    );
  }
}

class _ChipLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..strokeWidth = 0.8;

    final midY = size.height * 0.5;
    canvas.drawLine(Offset(size.width * 0.15, midY),
        Offset(size.width * 0.85, midY), paint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.2),
        Offset(size.width * 0.5, size.height * 0.8), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Brand mark
// ---------------------------------------------------------------------------

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.palette});

  final _CreditCardPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            'DIWAN',
            style: AppTextStyles.labelSmall.copyWith(
              color: palette.brandTextColor,
              fontWeight: FontWeight.w900,
              fontSize: 17,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            palette.isDark
                ? BrandLogoAssets.darkTheme
                : BrandLogoAssets.lightTheme,
            width: 36,
            height: 36,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.account_balance,
              size: 32,
              color: palette.brandTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Center balance + cashflow percentages
// ---------------------------------------------------------------------------

/// Monthly income/expense share of total cashflow (0–100 each, sums to 100).
(int?, int?) _cashflowMixPercents(double income, double expense) {
  final total = income + expense;
  if (total <= 0) return (null, null);
  final incomePct = (income / total * 100).round().clamp(0, 100);
  return (incomePct, 100 - incomePct);
}

class _BalanceHeroCenter extends StatelessWidget {
  const _BalanceHeroCenter({
    required this.amount,
    required this.currencyCode,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.palette,
  });

  final double amount;
  final String currencyCode;
  final double monthlyIncome;
  final double monthlyExpense;
  final _CreditCardPalette palette;

  @override
  Widget build(BuildContext context) {
    final (incomePct, expensePct) =
        _cashflowMixPercents(monthlyIncome, monthlyExpense);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          currencyCode,
          style: AppTextStyles.labelSmall.copyWith(
            color: palette.labelText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            CurrencyFormatter.formatAmountOnly(amount),
            textAlign: TextAlign.center,
            style: AppTextStyles.balanceDisplay.copyWith(
              color: palette.primaryText,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              height: 1.05,
            ),
          ),
        ),
        if (incomePct != null && expensePct != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _CashflowPercentBadge(
                icon: Icons.arrow_upward_rounded,
                percent: incomePct,
                color: AppColors.success,
                palette: palette,
              ),
              const SizedBox(width: 20),
              _CashflowPercentBadge(
                icon: Icons.arrow_downward_rounded,
                percent: expensePct,
                color: AppColors.expense,
                palette: palette,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CashflowPercentBadge extends StatelessWidget {
  const _CashflowPercentBadge({
    required this.icon,
    required this.percent,
    required this.color,
    required this.palette,
  });

  final IconData icon;
  final int percent;
  final Color color;
  final _CreditCardPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$percent%',
          style: AppTextStyles.labelSmall.copyWith(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Footer meta column
// ---------------------------------------------------------------------------

class _CardMetaColumn extends StatelessWidget {
  const _CardMetaColumn({
    required this.label,
    required this.value,
    required this.palette,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final _CreditCardPalette palette;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: palette.labelText,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMedium.copyWith(
            color: palette.primaryText,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Card quick-actions bottom sheet
// ---------------------------------------------------------------------------

class _CardActionSheet extends StatelessWidget {
  const _CardActionSheet({
    required this.l10n,
    required this.colors,
    required this.currencyCode,
  });

  final AppLocalizations l10n;
  final AppThemeColors colors;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                l10n.dashboardCardMenuTitle,
                style: AppTextStyles.headingSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _ActionTile(
              icon: Icons.account_balance_wallet_outlined,
              label: l10n.dashboardCardMenuViewWallets,
              colors: colors,
              onTap: () {
                Navigator.of(context).pop();
                GoRouter.of(context).go('/wallets');
              },
            ),
            _ActionTile(
              icon: Icons.add_circle_outline_rounded,
              label: l10n.dashboardCardMenuAddTransaction,
              colors: colors,
              onTap: () {
                Navigator.of(context).pop();
                GoRouter.of(context).push('/transactions/add?type=expense');
              },
            ),
            _ActionTile(
              icon: Icons.swap_horiz_rounded,
              label: l10n.dashboardCardMenuTransfer,
              colors: colors,
              onTap: () {
                Navigator.of(context).pop();
                GoRouter.of(context).push('/transactions/add?type=transfer');
              },
            ),
            _ActionTile(
              icon: Icons.bar_chart_rounded,
              label: l10n.dashboardCardMenuViewStats,
              colors: colors,
              isLast: true,
              onTap: () {
                Navigator.of(context).pop();
                GoRouter.of(context).go('/transactions');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.colors,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final AppThemeColors colors;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: colors.divider.withValues(alpha: 0.5)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Loading skeleton
// ---------------------------------------------------------------------------

class _BalanceHeroSkeleton extends StatelessWidget {
  const _BalanceHeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kCardMaxWidth),
          child: AspectRatio(
            aspectRatio: _kCardAspectRatio,
            child: ClayCardSkeleton(
              borderRadius: BorderRadius.circular(_kCardRadius),
            ),
          ),
        ),
      ),
    );
  }
}
