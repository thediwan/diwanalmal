import 'package:flutter/material.dart';

import '../models/opening_balance_input.dart';
import '../models/treasury.dart';
import '../models/wallet.dart';
import '../services/currency_service.dart';
import '../services/treasury_service.dart';
import '../services/wallet_balance_service.dart';
import '../services/wallet_service.dart';
import '../services/wallets_display_service.dart';

/// Exposes treasuries, balances, and mutations to the UI.
class WalletProvider extends ChangeNotifier {
  WalletProvider(
    this._walletService,
    this._treasuryService,
    this._balanceService,
    this._displayService,
    this._currencyService,
  );

  final WalletService _walletService;
  final TreasuryService _treasuryService;
  final WalletBalanceService _balanceService;
  final WalletsDisplayService _displayService;
  final CurrencyService _currencyService;

  List<Treasury> _treasuries = [];
  List<Wallet> _wallets = [];
  WalletsSummary? _summary;
  double _totalBalanceInBase = 0;
  bool _isLoading = false;

  List<Treasury> get treasuries => List.unmodifiable(_treasuries);
  List<Wallet> get wallets => List.unmodifiable(_wallets);
  WalletsSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  double get totalBalanceInBase => _totalBalanceInBase;

  Future<void> loadWallets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _treasuries = await _treasuryService.getAll();
      _wallets = await _walletService.getAllFlattened();
      _totalBalanceInBase = await _balanceService.getTotalBalanceInBase();

      final monthlyNet = await _balanceService.getMonthlyNetChangeInBase();
      final baseCurrency = await _currencyService.getBaseCurrency();
      final baseCode = baseCurrency?.code ?? 'USD';

      _summary = _displayService.buildSummary(
        treasuries: _treasuries,
        baseCode: baseCode,
        monthlyNetChangeInBase: monthlyNet,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Treasury> filterTreasuries(String query) {
    return _displayService.filterTreasuries(_treasuries, query);
  }

  double balanceFor(Wallet wallet) => wallet.initialBalance;

  String formattedBalance(Wallet wallet) {
    return _balanceService.formatWalletBalanceSync(wallet, wallet.initialBalance);
  }

  Future<Treasury> createWallet({
    required String name,
    required String icon,
    required String iconStyle,
    required List<OpeningBalanceInput> openingBalances,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final treasury = await _treasuryService.createWithAccounts(
        name: name,
        icon: icon,
        iconStyle: iconStyle,
        openingBalances: openingBalances,
      );
      await loadWallets();
      return treasury;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Treasury> updateWallet({
    required String id,
    required String name,
    required String icon,
    required String iconStyle,
    required List<OpeningBalanceInput> openingBalances,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final treasury = await _treasuryService.updateWithAccounts(
        id: id,
        name: name,
        icon: icon,
        iconStyle: iconStyle,
        openingBalances: openingBalances,
      );
      await loadWallets();
      return treasury;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteWallet(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _treasuryService.delete(id);
      await loadWallets();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
