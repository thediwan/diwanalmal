import 'package:flutter/material.dart';

import '../models/wallet.dart';
import '../services/wallet_balance_service.dart';
import '../services/wallet_service.dart';

/// Exposes wallet list, balances, and mutations to the UI.
class WalletProvider extends ChangeNotifier {
  WalletProvider(this._walletService, this._balanceService) {
    loadWallets();
  }

  final WalletService _walletService;
  final WalletBalanceService _balanceService;

  List<Wallet> _wallets = [];
  bool _isLoading = false;

  List<Wallet> get wallets => List.unmodifiable(_wallets);
  bool get isLoading => _isLoading;

  double get totalBalanceInBase => _balanceService.getTotalBalanceInBase();

  void loadWallets() {
    _wallets = _walletService.getAll();
    notifyListeners();
  }

  double balanceFor(Wallet wallet) {
    return _balanceService.getBalanceInWalletCurrency(wallet);
  }

  String formattedBalance(Wallet wallet) {
    return _balanceService.formatWalletBalance(wallet, null);
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
      loadWallets();
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
      loadWallets();
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
      loadWallets();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
