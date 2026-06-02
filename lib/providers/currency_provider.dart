import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../services/currency_service.dart';

/// Exposes currency list and mutations to the UI.
class CurrencyProvider extends ChangeNotifier {
  CurrencyProvider(this._currencyService) {
    loadCurrencies();
  }

  final CurrencyService _currencyService;

  List<Currency> _currencies = [];
  bool _isLoading = false;
  String? _error;

  List<Currency> get currencies => List.unmodifiable(_currencies);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Currency? get baseCurrency => _currencyService.getBaseCurrency();

  void loadCurrencies() {
    _currencies = _currencyService.getAll();
    notifyListeners();
  }

  Future<Currency> createBaseCurrency({
    required String code,
    required String name,
    required String symbol,
  }) async {
    _setLoading(true);
    try {
      final currency = await _currencyService.createBaseCurrency(
        code: code,
        name: name,
        symbol: symbol,
      );
      loadCurrencies();
      return currency;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCurrency({
    required String code,
    required String name,
    required String symbol,
    required double rateToBase,
  }) async {
    _setLoading(true);
    try {
      await _currencyService.addCurrency(
        code: code,
        name: name,
        symbol: symbol,
        rateToBase: rateToBase,
      );
      loadCurrencies();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateCurrency(Currency currency) async {
    _setLoading(true);
    try {
      await _currencyService.updateCurrency(currency);
      loadCurrencies();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteCurrency(String id) async {
    _setLoading(true);
    try {
      await _currencyService.deleteCurrency(id);
      loadCurrencies();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
