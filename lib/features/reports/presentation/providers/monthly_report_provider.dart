import 'package:flutter/material.dart';

import '../../../../services/monthly_report_service.dart';
import '../../domain/entities/report_entities.dart';

/// Loads and mutates monthly financial reports for the UI.
class MonthlyReportProvider extends ChangeNotifier {
  MonthlyReportProvider(this._service);

  final MonthlyReportService _service;

  List<MonthlyReportSnapshot> _reports = [];
  MonthlyReportSnapshot? _current;
  bool _isLoading = false;
  bool _isExporting = false;

  List<MonthlyReportSnapshot> get reports => List.unmodifiable(_reports);
  MonthlyReportSnapshot? get current => _current;
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;

  Future<void> loadList() async {
    _isLoading = true;
    notifyListeners();
    try {
      _reports = await _service.listReports();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<MonthlyReportSnapshot?> loadReport({
    required int year,
    required int month,
    bool refresh = false,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _current = refresh
          ? await _service.refreshReport(year: year, month: month)
          : await _service.ensureReport(year: year, month: month);
      return _current;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> carryForward({
    required int year,
    required int month,
    double? amount,
  }) async {
    _current = await _service.carrySurplusForward(
      year: year,
      month: month,
      amount: amount,
    );
    await loadList();
    notifyListeners();
  }

  Future<void> allocateToGoal({
    required int year,
    required int month,
    required String goalId,
    required String sourceWalletId,
    required double amount,
  }) async {
    _current = await _service.allocateSurplusToGoal(
      year: year,
      month: month,
      goalId: goalId,
      sourceWalletId: sourceWalletId,
      amount: amount,
    );
    await loadList();
    notifyListeners();
  }

  Future<void> ensurePreviousMonth() async {
    await _service.ensurePreviousMonthReport();
    await _service.autoFinalizeStaleDrafts();
    await loadList();
  }

  void setExporting(bool value) {
    _isExporting = value;
    notifyListeners();
  }
}
