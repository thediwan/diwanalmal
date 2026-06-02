import '../core/helpers/uuid_helper.dart';
import '../models/currency.dart';
import 'hive_service.dart';

/// CRUD operations for currencies.
class CurrencyService {
  CurrencyService(this._hiveService);

  final HiveService _hiveService;

  List<Currency> getAll() {
    return _hiveService.currenciesBox.values.toList()
      ..sort((a, b) {
        if (a.isBase != b.isBase) return a.isBase ? -1 : 1;
        return a.code.compareTo(b.code);
      });
  }

  Currency? getById(String id) => _hiveService.currenciesBox.get(id);

  Currency? getByCode(String code) {
    return getAll().where((c) => c.code == code).firstOrNull;
  }

  Currency? getBaseCurrency() {
    return getAll().where((c) => c.isBase).firstOrNull;
  }

  /// Creates the base currency during first-time setup.
  Future<Currency> createBaseCurrency({
    required String code,
    required String name,
    required String symbol,
  }) async {
    final currency = Currency(
      id: UuidHelper.generate(),
      code: code.toUpperCase(),
      name: name,
      symbol: symbol,
      rateToBase: 1.0,
      isBase: true,
      createdAt: DateTime.now(),
    );

    await _hiveService.currenciesBox.put(currency.id, currency);

    final settings = _hiveService.getSettings().copyWith(
          isSetupComplete: true,
          baseCurrencyCode: currency.code,
        );
    await _hiveService.saveSettings(settings);

    return currency;
  }

  /// Adds a non-base currency with exchange rate to base.
  Future<Currency> addCurrency({
    required String code,
    required String name,
    required String symbol,
    required double rateToBase,
  }) async {
    final existing = getByCode(code);
    if (existing != null) {
      throw Exception('العملة موجودة مسبقاً');
    }

    final currency = Currency(
      id: UuidHelper.generate(),
      code: code.toUpperCase(),
      name: name,
      symbol: symbol,
      rateToBase: rateToBase,
      isBase: false,
      createdAt: DateTime.now(),
    );

    await _hiveService.currenciesBox.put(currency.id, currency);
    return currency;
  }

  Future<Currency> updateCurrency(Currency currency) async {
    await _hiveService.currenciesBox.put(currency.id, currency);
    return currency;
  }

  Future<void> deleteCurrency(String id) async {
    final currency = getById(id);
    if (currency == null) return;

    if (currency.isBase) {
      throw Exception('لا يمكن حذف العملة الرئيسية');
    }

    final walletsUsingCurrency = _hiveService.walletsBox.values
        .where((w) => w.currencyCode == currency.code)
        .toList();

    if (walletsUsingCurrency.isNotEmpty) {
      throw Exception('العملة مستخدمة في محفظة');
    }

    await _hiveService.currenciesBox.delete(id);
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
