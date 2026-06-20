import 'package:flutter/material.dart';

import '../database/daos/finance_dao.dart';
import '../services/budget_service.dart';

/// Exposes monthly budgets with actual spend to the UI.
class BudgetProvider extends ChangeNotifier {
  BudgetProvider(this._budgetService);

  final BudgetService _budgetService;

  int _year = DateTime.now().year;
  int _month = DateTime.now().month;
  List<BudgetWithActual> _items = [];
  bool _isLoading = false;

  int get year => _year;
  int get month => _month;
  List<BudgetWithActual> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  Future<void> load({int? year, int? month}) async {
    if (year != null) _year = year;
    if (month != null) _month = month;

    _isLoading = true;
    notifyListeners();

    try {
      _items = await _budgetService.getBudgetsWithActuals(
        year: _year,
        month: _month,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> copyFromPreviousMonth() async {
    final copied = await _budgetService.copyFromPreviousMonth(
      year: _year,
      month: _month,
    );
    await load();
    return copied;
  }

  Future<void> deleteBudget(String budgetId) async {
    await _budgetService.delete(budgetId);
    await load();
  }
}
