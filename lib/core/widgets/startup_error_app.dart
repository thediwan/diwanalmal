import 'package:flutter/material.dart';

import '../helpers/hive_lock_helper.dart';

/// Minimal shell shown when [main] fails before the real app can start.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.error});

  final Object error;

  bool get _isLockError =>
      error is AppStorageLockException ||
      error.toString().contains('lock failed') ||
      error.toString().contains('settings.lock') ||
      error.toString().contains('another instance');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Icon(
                    Icons.error_outline_rounded,
                    size: 56,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'تعذّر تشغيل التطبيق',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isLockError
                        ? 'ملف الإعدادات مقفول. أغلق أي نافذة أخرى للتطبيق ثم أعد التشغيل. '
                          'إذا استمرت المشكلة، أعد تشغيل الجهاز.'
                        : 'حدث خطأ أثناء تحميل البيانات المحلية. أعد تشغيل التطبيق.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isLockError
                        ? 'Could not start: settings storage is locked. '
                          'Close any other app window and try again.'
                        : 'Could not load local data. Please restart the app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
