import '../../models/currency.dart';

/// Normalizes currency codes to uppercase ISO-style tokens.
String normalizeCurrencyCode(String code) => code.trim().toUpperCase();

/// Returns one [Currency] per normalized code.
/// Prefers base currency, then earliest [createdAt].
List<Currency> uniqueCurrenciesByCode(List<Currency> currencies) {
  final byCode = <String, Currency>{};

  for (final currency in currencies) {
    final code = normalizeCurrencyCode(currency.code);
    final existing = byCode[code];

    if (existing == null) {
      byCode[code] = currency.copyWith(code: code);
      continue;
    }

    if (!existing.isBase && currency.isBase) {
      byCode[code] = currency.copyWith(code: code);
      continue;
    }

    if (existing.isBase == currency.isBase &&
        currency.createdAt.isBefore(existing.createdAt)) {
      byCode[code] = currency.copyWith(code: code);
    }
  }

  final unique = byCode.values.toList()
    ..sort((a, b) {
      if (a.isBase != b.isBase) return a.isBase ? -1 : 1;
      return a.code.compareTo(b.code);
    });

  return unique;
}

/// Whether [code] already exists in [currencies] (case-insensitive).
bool currencyCodeExists(List<Currency> currencies, String code) {
  final normalized = normalizeCurrencyCode(code);
  return currencies.any((c) => normalizeCurrencyCode(c.code) == normalized);
}
