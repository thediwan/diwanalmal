import 'package:flutter/material.dart';

import '../models/wallet.dart';
import '../services/wallet_balance_service.dart';
import '../services/wallet_service.dart';

/// Exposes wallet list, balances, and mutations to the UI.
class WalletProvider extends ChangeNotifier {
  WalletProvider(this._walletService, this._balanceService);

  final WalletService _walletService;
  final WalletBalanceService _balanceService;

  List<Wallet> _wallets = [];
  final Map<String, double> _balances = {};
  double _totalBalanceInBase = 0;
  bool _isLoading = false;

  List<Wallet> get wallets => List.unmodifiable(_wallets);
  bool get isLoading => _isLoading;
  double get totalBalanceInBase => _totalBalanceInBase;

  Future<void> loadWallets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _wallets = await _walletService.getAll();
      _balances.clear();

      for (final wallet in _wallets) {
        final balance = await _balanceService.getBalanceInWalletCurrency(wallet);
        _balances[wallet.id] = balance;
      }

      _totalBalanceInBase = await _balanceService.getTotalBalanceInBase();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double balanceFor(Wallet wallet) => _balances[wallet.id] ?? 0;

  String formattedBalance(Wallet wallet) {
    final balance = balanceFor(wallet);
    return _balanceService.formatWalletBalanceSync(wallet, balance);
  }

  Future<Wallet> createWallet({
    required String name,
    required String currencyCode,
    required double initialBalance,
    required String icon,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final wallet = await _walletService.create(
        name: name,
        currencyCode: currencyCode,
        initialBalance: initialBalance,
        icon: icon,
      );
      await loadWallets();
      return wallet;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateWallet(Wallet wallet) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _walletService.update(wallet);
      await loadWallets();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteWallet(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _walletService.delete(id);
      await loadWallets();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
