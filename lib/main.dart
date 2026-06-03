import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_lifecycle_observer.dart';
import 'providers/currency_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/wallet_provider.dart';
import 'router/app_router.dart';
import 'services/auth_service.dart';
import 'services/biometric_service.dart';
import 'services/currency_service.dart';
import 'services/hive_service.dart';
import 'services/wallet_balance_service.dart';
import 'services/wallet_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preload fonts so auth screens do not hang on first paint (emulator/offline).
  await GoogleFonts.pendingFonts([
    GoogleFonts.almarai(fontWeight: FontWeight.w700),
    GoogleFonts.cairo(),
  ]);

  final hiveService = HiveService();
  await hiveService.init();

  final authService = AuthService(hiveService);
  final biometricService = BiometricService();
  final currencyService = CurrencyService(hiveService);
  final walletService = WalletService(hiveService);
  final walletBalanceService = WalletBalanceService(hiveService, currencyService);

  final settingsProvider = SettingsProvider(
    hiveService,
    authService,
    biometricService,
  );
  final currencyProvider = CurrencyProvider(currencyService);
  final walletProvider = WalletProvider(walletService, walletBalanceService);

  final appRouter = AppRouter(settingsProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider.value(value: currencyProvider),
        ChangeNotifierProvider.value(value: walletProvider),
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
    // Rebuild only when theme changes — not on every auth state update.
    // Watching the whole provider here caused a white screen after PIN save.
    final themeMode = context.select<SettingsProvider, ThemeMode>(
      (settings) => settings.themeMode,
    );

    return AppLifecycleObserver(
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    );
  }
}
