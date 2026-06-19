import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/palettes/app_color_palette.dart';
import 'l10n/app_localizations.dart';
import 'core/widgets/app_lifecycle_observer.dart';
import 'providers/dashboard_refresh_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/wallet_provider.dart';
import 'router/app_router.dart';
import 'services/auth_service.dart';
import 'services/biometric_service.dart';
import 'services/backup_notification_service.dart';
import 'services/backup_scheduler_service.dart';
import 'services/backup_service.dart';
import 'services/currency_deduplication_service.dart';
import 'services/currency_service.dart';
import 'services/hive_service.dart';
import 'services/lazarus_database_service.dart';
import 'services/profile_service.dart';
import 'services/treasury_service.dart';
import 'services/wallet_balance_service.dart';
import 'services/wallet_service.dart';
import 'services/wallets_display_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final hiveService = HiveService();
  await hiveService.init();

  final lazarusService = await LazarusDatabaseService.initialize(hiveService);

  final authService = AuthService(hiveService);
  final biometricService = BiometricService();
  final deduplicationService = CurrencyDeduplicationService(lazarusService);
  final currencyService = CurrencyService(
    lazarusService,
    hiveService,
    deduplicationService,
  );
  await currencyService.ensureUniqueCurrencies();
  final walletService = WalletService(lazarusService);
  final treasuryService = TreasuryService(lazarusService);
  final walletBalanceService = WalletBalanceService(lazarusService);
  final walletsDisplayService = WalletsDisplayService();

  final profileService = ProfileService(lazarusService, hiveService);

  final backupService = BackupService(
    hiveService,
    database: lazarusService.database,
  );
  await backupService.mergeBackgroundBackupMarker();
  await BackupNotificationService.initialize();
  await BackupSchedulerService.register();
  final backupScheduler = BackupSchedulerService(hiveService, backupService);

  final settingsProvider = SettingsProvider(
    hiveService,
    authService,
    biometricService,
    profileService,
  );
  final profileProvider = ProfileProvider(profileService);
  final currencyProvider = CurrencyProvider(currencyService);
  final walletProvider = WalletProvider(
    walletService,
    treasuryService,
    walletBalanceService,
    walletsDisplayService,
    currencyService,
  );

  final dashboardRefreshProvider = DashboardRefreshProvider();

  await Future.wait([
    walletProvider.loadWallets(),
    currencyProvider.loadCurrencies(),
    profileProvider.load(),
  ]);

  await backupScheduler.scheduleFromSettings();
  if (settingsProvider.hasAccount && settingsProvider.isSecuritySetupComplete) {
    await backupScheduler.runCatchUpIfDue(
      onSettingsChanged: () => settingsProvider.reloadFromStorage(),
    );
  }

  final appRouter = AppRouter(settingsProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: profileProvider),
        ChangeNotifierProvider.value(value: currencyProvider),
        ChangeNotifierProvider.value(value: walletProvider),
        ChangeNotifierProvider.value(value: dashboardRefreshProvider),
        Provider<BackupService>.value(value: backupService),
        Provider<BackupSchedulerService>.value(value: backupScheduler),
      ],
      child: BaytAlmalApp(router: appRouter.router),
    ),
  );
}

class BaytAlmalApp extends StatelessWidget {
  const BaytAlmalApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    // Rebuild only when theme/palette changes — not on every auth state update.
    // Watching the whole provider here caused a white screen after PIN save.
    final themeMode = context.select<SettingsProvider, ThemeMode>(
      (settings) => settings.themeMode,
    );
    final paletteId = context.select<SettingsProvider, AppColorPaletteId>(
      (settings) => settings.colorPaletteId,
    );
    final locale = context.select<SettingsProvider, Locale>(
      (settings) => settings.locale,
    );
    final fontScaleFactor = context.select<SettingsProvider, double>(
      (settings) => settings.fontSizePreference.scaleFactor,
    );

    return AppLifecycleObserver(
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(palette: paletteId, brightness: Brightness.light),
        darkTheme: AppTheme.build(palette: paletteId, brightness: Brightness.dark),
        themeMode: themeMode,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(fontScaleFactor),
            ),
            child: child!,
          );
        },
        routerConfig: router,
      ),
    );
  }
}
