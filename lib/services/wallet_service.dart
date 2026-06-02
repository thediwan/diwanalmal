import '../core/helpers/uuid_helper.dart';
import '../models/wallet.dart';
import 'hive_service.dart';

/// CRUD operations for wallets.
class WalletService {
  WalletService(this._hiveService);

  final HiveService _hiveService;

  List<Wallet> getAll() {
    return _hiveService.walletsBox.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Wallet? getById(String id) => _hiveService.walletsBox.get(id);

  Future<Wallet> create({
    required String name,
    required String currencyCode,
    required double initialBalance,
    required String icon,
  }) async {
    final wallet = Wallet(
      id: UuidHelper.generate(),
      name: name,
      currencyCode: currencyCode.toUpperCase(),
      initialBalance: initialBalance,
      icon: icon,
      createdAt: DateTime.now(),
    );

    await _hiveService.walletsBox.put(wallet.id, wallet);
    return wallet;
  }

  Future<Wallet> update(Wallet wallet) async {
    await _hiveService.walletsBox.put(wallet.id, wallet);
    return wallet;
  }

  Future<void> delete(String id) async {
    await _hiveService.walletsBox.delete(id);
  }
}
