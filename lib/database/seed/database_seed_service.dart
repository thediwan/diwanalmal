import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/database_constants.dart';
import '../../core/helpers/currency_uniqueness.dart';
import '../lazarus_database.dart';
import 'category_seed_service.dart';

/// Demo data aligned with dashboard and wallets screen mockups.
///
/// Runs only after the user selects a base currency — never on cold start.
class DatabaseSeedService {
  DatabaseSeedService(this._db);

  final LazarusDatabase _db;
  final _uuid = const Uuid();

  static const _mockupMarkerTitle = 'بقالة المجد';

  static const _walCashId = 'wal-cash';
  static const _walBankId = 'wal-bank';
  static const _walCryptoId = 'wal-crypto';
  static const _walTravelId = 'wal-travel';

  static const _catFoodId = 'cat-food';
  static const _catSalaryId = 'cat-salary';
  static const _goalCarId = 'goal-car-01';
  static const _debtAhmedId = 'debt-ahmed-01';

  /// Reference value of 1 unit in USD (for cross-rate calculation).
  static const Map<String, double> _usdReferenceRates = {
    'USD': 1.0,
    'SYP': 0.0000666667,
    'EUR': 1.0869565,
    'USDT': 1.0,
  };

  static const List<String> _demoCurrencyCodes = [
    'USD',
    'SYP',
    'EUR',
    'USDT',
  ];

  static const Map<String, ({String name, String symbol})> _currencyMeta = {
    'USD': (name: 'دولار أمريكي', symbol: r'$'),
    'SYP': (name: 'الليرة السورية', symbol: 'ل.س'),
    'EUR': (name: 'اليورو', symbol: '€'),
    'USDT': (name: 'تيثر', symbol: 'USDT'),
  };

  /// Inserts demo wallets, transactions, and secondary currencies once.
  ///
  /// [baseCurrencyId] is the row created during onboarding (not a preset id).
  Future<void> seedDemoDataAfterBaseCurrencySelection({
    required String userId,
    required String baseCurrencyId,
    required String baseCode,
  }) async {
    final normalizedBase = normalizeCurrencyCode(baseCode);

    final hasMockup = await (_db.select(_db.transactions)
          ..where((t) => t.userId.equals(userId))
          ..where((t) => t.title.equals(_mockupMarkerTitle))
          ..limit(1))
        .getSingleOrNull();

    if (hasMockup != null) return;

    await _insertMockupFinancialData(
      userId: userId,
      baseCurrencyId: baseCurrencyId,
      baseCode: normalizedBase,
    );
  }

  Future<void> _insertMockupFinancialData({
    required String userId,
    required String baseCurrencyId,
    required String baseCode,
  }) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final yesterday9am = DateTime(now.year, now.month, now.day - 1, 9);

    String currencyId(String code) {
      final normalized = normalizeCurrencyCode(code);
      if (normalized == baseCode) return baseCurrencyId;
      return 'cur-${normalized.toLowerCase()}-0001';
    }

    double rateToBase(String code) {
      final normalized = normalizeCurrencyCode(code);
      final codeUsd = _usdReferenceRates[normalized] ?? 1.0;
      final baseUsd = _usdReferenceRates[baseCode] ?? 1.0;
      return codeUsd / baseUsd;
    }

    await _db.transaction(() async {
      for (final code in _demoCurrencyCodes) {
        final normalized = normalizeCurrencyCode(code);
        if (normalized == baseCode) continue;

        final meta = _currencyMeta[normalized]!;
        await _insertCurrency(
          userId: userId,
          id: currencyId(normalized),
          code: normalized,
          name: meta.name,
          symbol: meta.symbol,
          rate: rateToBase(normalized),
          isBase: false,
          now: now,
        );
      }

      await _insertTreasury(
        userId: userId,
        id: _walCashId,
        name: 'الخزنة الرئيسية',
        subtitle: 'نقد شخصي',
        iconStyle: 'cash',
        icon: '💵',
        now: now,
        accounts: [
          (
            accountId: 'acc-cash-syp',
            currencyId: currencyId('SYP'),
            opening: 7500000.0,
          ),
          (
            accountId: 'acc-cash-usd',
            currencyId: currencyId('USD'),
            opening: 3500.0,
          ),
        ],
      );

      await _insertTreasury(
        userId: userId,
        id: _walBankId,
        name: 'الحساب البنكي (زراعات)',
        subtitle: 'حساب جاري',
        iconStyle: 'bank',
        icon: '🏦',
        now: now,
        accounts: [
          (
            accountId: 'acc-bank-usd',
            currencyId: currencyId('USD'),
            opening: 6000.0,
          ),
          (
            accountId: 'acc-bank-eur',
            currencyId: currencyId('EUR'),
            opening: 800.0,
          ),
        ],
      );

      await _insertTreasury(
        userId: userId,
        id: _walCryptoId,
        name: 'المحفظة الرقمية',
        subtitle: 'تداول أصول رقمية',
        iconStyle: 'crypto',
        icon: '₿',
        now: now,
        accounts: [
          (
            accountId: 'acc-crypto-usdt',
            currencyId: currencyId('USDT'),
            opening: 1449.0,
          ),
        ],
      );

      await _insertTreasury(
        userId: userId,
        id: _walTravelId,
        name: 'ميزانية السفر',
        subtitle: 'ديون مستحقة',
        iconStyle: 'travel',
        icon: '✈️',
        now: now,
        accounts: [
          (
            accountId: 'acc-travel-usd',
            currencyId: currencyId('USD'),
            opening: 500.0,
          ),
        ],
      );

      await CategorySeedService(_db).ensureDefaultCategories(userId);

      final sypRate = rateToBase('SYP');
      final usdRate = rateToBase('USD');

      await _insertTransaction(
        userId: userId,
        id: 'tx-grocery-01',
        walletId: _walCashId,
        categoryId: _catFoodId,
        type: DatabaseConstants.txExpense,
        title: _mockupMarkerTitle,
        amount: 225000,
        currencyId: currencyId('SYP'),
        rate: sypRate,
        baseAmount: 225000 * sypRate,
        transactionDate: now.subtract(const Duration(hours: 2)),
        createdAt: now,
      );

      await _insertTransaction(
        userId: userId,
        id: 'tx-salary-01',
        walletId: _walBankId,
        categoryId: _catSalaryId,
        type: DatabaseConstants.txIncome,
        title: 'راتب الشهر',
        amount: 1500,
        currencyId: currencyId('USD'),
        rate: usdRate,
        baseAmount: 1500 * usdRate,
        transactionDate: yesterday9am,
        createdAt: now,
      );

      await _insertTransaction(
        userId: userId,
        id: 'tx-misc-expense',
        walletId: _walBankId,
        categoryId: _catFoodId,
        type: DatabaseConstants.txExpense,
        title: 'مصروف متفرق',
        amount: 235,
        currencyId: currencyId('USD'),
        rate: usdRate,
        baseAmount: 235 * usdRate,
        transactionDate: monthStart.add(const Duration(days: 5)),
        createdAt: now,
      );

      await _insertTransaction(
        userId: userId,
        id: 'tx-travel-overdraft',
        walletId: _walTravelId,
        categoryId: _catFoodId,
        type: DatabaseConstants.txExpense,
        title: 'مصروف سفر',
        amount: 750,
        currencyId: currencyId('USD'),
        rate: usdRate,
        baseAmount: 750 * usdRate,
        transactionDate: monthStart.add(const Duration(days: 2)),
        createdAt: now,
      );

      for (final entry in [
        (id: 'tx-chart-1', days: 28, base: 40.0),
        (id: 'tx-chart-2', days: 20, base: 120.0),
        (id: 'tx-chart-3', days: 12, base: 80.0),
        (id: 'tx-chart-4', days: 4, base: 60.0),
      ]) {
        await _insertTransaction(
          userId: userId,
          id: entry.id,
          walletId: _walBankId,
          categoryId: _catFoodId,
          type: DatabaseConstants.txExpense,
          title: 'مصروف',
          amount: entry.base,
          currencyId: currencyId('USD'),
          rate: usdRate,
          baseAmount: entry.base * usdRate,
          transactionDate: now.subtract(Duration(days: entry.days)),
          createdAt: now,
        );
      }

      await _db.into(_db.debts).insert(
            DebtsCompanion.insert(
              id: _debtAhmedId,
              userId: userId,
              walletId: _walBankId,
              personName: 'أحمد',
              type: DatabaseConstants.debtIOwe,
              amount: 100,
              currencyId: currencyId('USD'),
              exchangeRate: usdRate,
              baseAmount: 100 * usdRate,
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );

      await _db.into(_db.debtPayments).insert(
            DebtPaymentsCompanion.insert(
              id: _uuid.v4(),
              debtId: _debtAhmedId,
              amount: 50,
              currencyId: currencyId('USD'),
              exchangeRate: usdRate,
              baseAmount: 50 * usdRate,
              paymentDate: now.subtract(const Duration(days: 3)),
              createdAt: now,
            ),
          );

      await _db.into(_db.goals).insert(
            GoalsCompanion.insert(
              id: _goalCarId,
              userId: userId,
              title: 'شراء سيارة',
              targetAmount: 15000,
              savedAmount: const Value(3600),
              currencyId: currencyId('USD'),
              icon: const Value('car'),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
    });
  }

  Future<void> _insertTreasury({
    required String userId,
    required String id,
    required String name,
    required String icon,
    required DateTime now,
    String? subtitle,
    String? iconStyle,
    required List<({
      String accountId,
      String currencyId,
      double opening,
    })> accounts,
  }) async {
    await _db.into(_db.wallets).insert(
          WalletsCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            icon: Value(icon),
            subtitle: Value(subtitle),
            iconStyle: Value(iconStyle),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );

    for (final account in accounts) {
      await _db.into(_db.walletCurrencyAccounts).insert(
            WalletCurrencyAccountsCompanion.insert(
              id: account.accountId,
              walletId: id,
              currencyId: account.currencyId,
              openingBalance: Value(account.opening),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  Future<void> _insertCurrency({
    required String userId,
    required String id,
    required String code,
    required String name,
    required String symbol,
    required double rate,
    required bool isBase,
    required DateTime now,
  }) {
    return _db.into(_db.currencies).insert(
          CurrenciesCompanion.insert(
            id: id,
            userId: userId,
            code: normalizeCurrencyCode(code),
            name: name,
            symbol: symbol,
            rateToBase: rate,
            isBase: Value(isBase),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> _insertTransaction({
    required String userId,
    required String id,
    required String walletId,
    required String categoryId,
    required String type,
    required String title,
    required double amount,
    required String currencyId,
    required double rate,
    required double baseAmount,
    required DateTime transactionDate,
    required DateTime createdAt,
  }) {
    return _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            id: id,
            userId: userId,
            walletId: Value(walletId),
            categoryId: Value(categoryId),
            type: type,
            title: title,
            amount: amount,
            currencyId: currencyId,
            exchangeRate: rate,
            baseAmount: baseAmount,
            transactionDate: transactionDate,
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
  }
}
