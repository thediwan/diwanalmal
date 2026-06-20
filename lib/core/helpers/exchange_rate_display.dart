import '../../models/currency.dart';
import '../../providers/currency_provider.dart';
import '../../services/transfer_service.dart';
import 'currency_formatter.dart';

/// Unified exchange-rate display for transfers: always `1 {base} = X {currency}`.
abstract final class ExchangeRateDisplay {
  /// The currency whose rate vs base is shown and edited in transfer forms.
  ///
  /// When [source] is base, shows [target]'s rate. Otherwise shows [source]'s rate.
  static Currency ratedCurrency({
    required Currency source,
    required Currency target,
  }) {
    if (source.isBase) return target;
    return source;
  }

  static String formatDisplayRate(double displayRate) {
    return CurrencyFormatter.formatExchangeRate(displayRate);
  }

  static String defaultDisplayRateText(Currency currency) {
    return formatDisplayRate(
      CurrencyFormatter.displayRateFromStored(currency.rateToBase),
    );
  }

  static double? parseDisplayRate(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    final value = double.tryParse(normalized);
    if (value == null || value <= 0) return null;
    return value;
  }

  static bool displayRateChanged(Currency rated, double displayRate) {
    final current = CurrencyFormatter.displayRateFromStored(rated.rateToBase);
    return (displayRate - current).abs() > 1e-9;
  }

  static Currency withDisplayRate(Currency currency, double displayRate) {
    return currency.copyWith(
      rateToBase: CurrencyFormatter.storedRateFromDisplay(displayRate),
    );
  }

  /// Resolves converted target amount using stored rates and an optional edited display rate.
  static double resolveTransferTargetAmount({
    required double sourceAmount,
    required Currency source,
    required Currency target,
    required double displayRate,
  }) {
    final rated = ratedCurrency(source: source, target: target);
    var effectiveSource = source;
    var effectiveTarget = target;

    if (rated.id == source.id) {
      effectiveSource = withDisplayRate(source, displayRate);
    } else if (rated.id == target.id) {
      effectiveTarget = withDisplayRate(target, displayRate);
    }

    return TransferService.resolveTargetAmount(
      sourceAmount: sourceAmount,
      source: effectiveSource,
      target: effectiveTarget,
    );
  }

  /// Persists an edited display rate to the currency table when it changed.
  static Future<void> persistDisplayRateIfChanged({
    required CurrencyProvider provider,
    required Currency source,
    required Currency target,
    required String rateText,
  }) async {
    final displayRate = parseDisplayRate(rateText);
    if (displayRate == null) return;

    final rated = ratedCurrency(source: source, target: target);
    if (rated.isBase) return;
    if (!displayRateChanged(rated, displayRate)) return;

    await provider.updateCurrency(withDisplayRate(rated, displayRate));
  }

  static Currency? findCurrency(CurrencyProvider provider, Currency currency) {
    return provider.currencies.where((c) => c.id == currency.id).firstOrNull;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
