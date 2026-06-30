import 'package:diwanalmal/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const locale = String.fromEnvironment('SCREENSHOT_LOCALE', defaultValue: 'en');
  final metadataDir =
      locale == 'ar' ? '../metadata/ar' : '../metadata/en-US';

  testWidgets('capture F-Droid store screenshots ($locale)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1080, 1920));

    await app.bootstrapAppForIntegrationTests();
    await tester.pumpAndSettle(const Duration(seconds: 10));

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final router = materialApp.routerConfig! as GoRouter;

    final shots = <({String file, String route})>[
      (file: '01_dashboard', route: '/'),
      (file: '02_transactions', route: '/transactions'),
      (file: '03_wallets', route: '/wallets'),
      (file: '04_reports', route: '/reports'),
      (file: '05_settings_backup', route: '/settings/backup'),
    ];

    for (final shot in shots) {
      router.go(shot.route);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile(
          '$metadataDir/images/phoneScreenshots/${shot.file}.png',
        ),
      );
    }
  });
}
