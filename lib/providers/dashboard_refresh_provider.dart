import 'package:flutter/material.dart';

/// Signals the dashboard to reload data after mutations (e.g. new transaction).
class DashboardRefreshProvider extends ChangeNotifier {
  int _version = 0;

  int get version => _version;

  /// Bumps [version] so dashboard listeners can reload snapshot data.
  void notifyRefresh() {
    _version++;
    notifyListeners();
  }
}
