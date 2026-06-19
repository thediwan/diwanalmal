import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../services/backup_scheduler_service.dart';

/// Locks the app when it goes to background.
class AppLifecycleObserver extends StatefulWidget {
  const AppLifecycleObserver({super.key, required this.child});

  final Widget child;

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only lock when app is backgrounded — not on `inactive` (biometric dialog).
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      context.read<SettingsProvider>().lockSession();
    }

    if (state == AppLifecycleState.resumed) {
      _runBackupCatchUp();
    }
  }

  Future<void> _runBackupCatchUp() async {
    try {
      final scheduler = context.read<BackupSchedulerService>();
      await scheduler.runCatchUpIfDue(
        onSettingsChanged: () =>
            context.read<SettingsProvider>().reloadFromStorage(),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
