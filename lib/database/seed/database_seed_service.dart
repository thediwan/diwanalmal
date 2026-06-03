import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/database_constants.dart';
import '../lazarus_database.dart';

/// Demo data aligned with the client dashboard mockup image.
class DatabaseSeedService {
  DatabaseSeedService(this._db);

  final LazarusDatabase _db;
  final _uuid = const Uuid();

  static const _mockupMarkerTitle = 'بقالة المجد';

  static const _usdId = 'cur-usd-0001';
  static const _tryId = 'cur-try-0001';
  static const _sypId = 'cur-syp-0001';
  static const _eurId = 'cur-eur-0001';
  static const _walletUsdId = 'wal-usd-cash';
  static const _walletTryId = 'wal-try-cash';
  static const _walletSypId = 'wal-syp-cash';
  static const _walletEurId = 'wal-eur-cash';
  static const _catFoodId = 'cat-food';
  static const _catSalaryId = 'cat-salary';
  static const _goalCarId = 'goal-car-01';
  static const _debtAhmedId = 'debt-ahmed-01';

  static const _rateUsd = 1.0;
  static const _rateTry = 0.031003968;
  static const _rateSyp = 0.0000666667;
  static const _rateEur = 1.0869565;

  /// Returns true if initial seed ran (no user existed).
  Future<bool> seedIfEmpty() async {
    final existing = await _db.getActiveUserId();
    if (existing != null) return false;
    await _insertDemoUserShell();
    await _insertMockupFinancialData(DatabaseConstants.seedUserId);
    return true;
  }

  /// Ensures mockup dashboard rows exist for whoever is the active SQL user
  /// (including `hive-migrated-user` after registration).
  Future<void> ensureDashboardMockupData() async {
    final existingId = await _db.getActiveUserId();
    final String userId;
    if (existingId == null) {
      await _insertDemoUserShell();
      userId = DatabaseConstants.seedUserId;
    } else {
      userId = existingId;
    }

    final hasMockup = await (_db.select(_db.transactions)
          ..where((t) => t.userId.equals(userId))
          ..where((t) => t.title.equals(_mockupMarkerTitle))
          ..limit(1))
        .getSingleOrNull();
    if (hasMockup != null) return;

    await _clearDemoFinancialData(userId);
    await _insertMockupFinancialData(userId);
  }

  Future<void> _insertDemoUserShell() async {
    final now = DateTime.now();
    await _db.into(_db.appUsers).insert(
          AppUsersCompanion.insert(
            id: DatabaseConstants.seedUserId,
            fullName: 'مستخدم تجريبي',
            email: const Value('demo@baytalmal.app'),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await _db.into(_db.authLocal).insert(
          AuthLocalCompanion.insert(
            id: _uuid.v4(),
            userId: DatabaseConstants.seedUserId,
            username: 'demo',
            passwordHash: 'local:demo123',
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await _db.into(_db.securitySettings).insert(
          SecuritySettingsCompanion.insert(
            id: _uuid.v4(),
            userId: DatabaseConstants.seedUserId,
            pinEnabled: const Value(true),
            pinHash: const Value('local:1234'),
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> _clearDemoFinancialData(String userId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.debtPayments)).go();
      await (_db.delete(_db.debts)..where((d) => d.userId.equals(userId))).go();
      await (_db.delete(_db.transactions)..where((t) => t.userId.equals(userId)))
          .go();
      await (_db.delete(_db.goals)..where((g) => g.userId.equals(userId))).go();
      await (_db.delete(_db.wallets)..where((w) => w.userId.equals(userId))).go();
      await (_db.delete(_db.categories)..where((c) => c.userId.equals(userId)))
          .go();
      await (_db.delete(_db.currencies)..where((c) => c.userId.equals(userId)))
          .go();
      await (_db.delete(_db.userSettings)..where((s) => s.userId.equals(userId)))
          .go();
    });
  }

  Future<void> _insertMockupFinancialData(String userId) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final yesterday9am = DateTime(now.year, now.month, now.day - 1, 9);

    await _db.transaction(() async {
      await _insertCurrency(
        userId: userId,
        id: _usdId,
        code: 'USD',
        name: 'دولار أمريكي',
        symbol: r'$',
        rate: _rateUsd,
        isBase: true,
        now: now,
      );
      await _insertCurrency(
        userId: userId,
        id: _tryId,
        code: 'TRY',
        name: 'الليرة التركية',
        symbol: '₺',
        rate: _rateTry,
        isBase: false,
        now: now,
      );
      await _insertCurrency(
        userId: userId,
        id: _sypId,
        code: 'SYP',
        name: 'الليرة السورية',
        symbol: 'ل.س',
        rate: _rateSyp,
        isBase: false,
        now: now,
      );
      await _insertCurrency(
        userId: userId,
        id: _eurId,
        code: 'EUR',
        name: 'اليورو',
        symbol: '€',
        rate: _rateEur,
        isBase: false,
        now: now,
      );

      await _db.into(_db.userSettings).insert(
            UserSettingsCompanion.insert(
              id: 'settings-$userId',
              userId: userId,
              baseCurrencyId: _usdId,
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );

      await _db.into(_db.wallets).insert(
            WalletsCompanion.insert(
              id: _walletUsdId,
              userId: userId,
              currencyId: _usdId,
              name: 'محفظة نقدية',
              icon: const Value('💵'),
              openingBalance: const Value(0),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
      await _db.into(_db.wallets).insert(
            WalletsCompanion.insert(
              id: _walletTryId,
              userId: userId,
              currencyId: _tryId,
              name: 'محفظة تركيا',
              icon: const Value('🇹🇷'),
              openingBalance: const Value(40800),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
      await _db.into(_db.wallets).insert(
            WalletsCompanion.insert(
              id: _walletSypId,
              userId: userId,
              currencyId: _sypId,
              name: 'محفظة سوريا',
              icon: const Value('🇸🇾'),
              openingBalance: const Value(18750000),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
      await _db.into(_db.wallets).insert(
            WalletsCompanion.insert(
              id: _walletEurId,
              userId: userId,
              currencyId: _eurId,
              name: 'محفظة يورو',
              icon: const Value('🇪🇺'),
              openingBalance: const Value(1150),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );

      await _db.into(_db.categories).insert(
            CategoriesCompanion.insert(
              id: _catFoodId,
              userId: userId,
              name: 'طعام',
              type: DatabaseConstants.categoryExpense,
              icon: const Value('🛒'),
              color: const Value('#EA580C'),
              isDefault: const Value(true),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
      await _db.into(_db.categories).insert(
            CategoriesCompanion.insert(
              id: _catSalaryId,
              userId: userId,
              name: 'راتب',
              type: DatabaseConstants.categoryIncome,
              icon: const Value('💰'),
              color: const Value('#16A34A'),
              isDefault: const Value(true),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );

      await _insertTransaction(
        userId: userId,
        id: 'tx-grocery-01',
        walletId: _walletTryId,
        categoryId: _catFoodId,
        type: DatabaseConstants.txExpense,
        title: _mockupMarkerTitle,
        amount: 480,
        currencyId: _tryId,
        rate: _rateTry,
        baseAmount: 15,
        transactionDate: now.subtract(const Duration(hours: 2)),
        createdAt: now,
      );

      await _insertTransaction(
        userId: userId,
        id: 'tx-salary-01',
        walletId: _walletUsdId,
        categoryId: _catSalaryId,
        type: DatabaseConstants.txIncome,
        title: 'راتب الشهر',
        amount: 1500,
        currencyId: _usdId,
        rate: _rateUsd,
        baseAmount: 1500,
        transactionDate: yesterday9am,
        createdAt: now,
      );

      await _insertTransaction(
        userId: userId,
        id: 'tx-misc-expense',
        walletId: _walletUsdId,
        categoryId: _catFoodId,
        type: DatabaseConstants.txExpense,
        title: 'مصروف متفرق',
        amount: 235,
        currencyId: _usdId,
        rate: _rateUsd,
        baseAmount: 235,
        transactionDate: monthStart.add(const Duration(days: 5)),
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
          walletId: _walletUsdId,
          categoryId: _catFoodId,
          type: DatabaseConstants.txExpense,
          title: 'مصروف',
          amount: entry.base,
          currencyId: _usdId,
          rate: _rateUsd,
          baseAmount: entry.base,
          transactionDate: now.subtract(Duration(days: entry.days)),
          createdAt: now,
        );
      }

      await _db.into(_db.debts).insert(
            DebtsCompanion.insert(
              id: _debtAhmedId,
              userId: userId,
              personName: 'أحمد',
              type: DatabaseConstants.debtIOwe,
              amount: 100,
              currencyId: _usdId,
              exchangeRate: _rateUsd,
              baseAmount: 100,
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
              currencyId: _usdId,
              exchangeRate: _rateUsd,
              baseAmount: 50,
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
              currencyId: _usdId,
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrReplace,
          );
    });
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
            code: code,
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
            walletId: walletId,
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
