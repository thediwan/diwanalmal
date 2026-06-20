import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/context_feedback.dart';
import '../../../core/extensions/context_l10n.dart';
import '../../../core/extensions/context_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/currency_provider.dart';
import '../../../providers/dashboard_refresh_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/wallet_provider.dart';
import '../../../services/backup_notification_service.dart';
import '../../../services/backup_scheduler_service.dart';
import '../../../services/backup_service.dart';

/// Backup settings: schedule, export, import.
class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  BackupStatus? _status;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStatus();
      BackupNotificationService.requestPermission();
    });
  }

  Future<void> _loadStatus() async {
    final status = await context.read<BackupService>().getStatus();
    if (mounted) setState(() => _status = status);
  }

  Future<void> _pickBackupDirectory() async {
    final l10n = context.l10n;
    final picked = await FilePicker.platform.getDirectoryPath();
    if (picked == null || !mounted) return;

    try {
      final settings = context.read<SettingsProvider>();
      final backupService = context.read<BackupService>();
      await settings.setBackupDirectory(picked);
      await backupService.syncBackupLocationConfig();
      await _loadStatus();
      if (!mounted) return;
      context.showSuccessFeedback(l10n.backupLocationUpdated);
    } catch (_) {
      if (!mounted) return;
      context.showErrorFeedback(l10n.backupLocationPickFailed);
    }
  }

  Future<void> _resetBackupDirectory() async {
    final l10n = context.l10n;
    final settings = context.read<SettingsProvider>();
    final backupService = context.read<BackupService>();
    await settings.setBackupDirectory(null);
    await backupService.syncBackupLocationConfig();
    await _loadStatus();
    if (!mounted) return;
    context.showSuccessFeedback(l10n.backupLocationUpdated);
  }

  Future<void> _pickBackupTime() async {
    final settings = context.read<SettingsProvider>();
    final picked = await showTimePicker(
      context: context,
      initialTime: settings.backupTime,
    );
    if (picked == null || !mounted) return;

    await settings.setBackupTime(picked);
    await context.read<BackupSchedulerService>().reschedule();
    await _loadStatus();
  }

  Future<void> _toggleAuto(bool enabled) async {
    await context.read<SettingsProvider>().setBackupEnabled(enabled);
    await context.read<BackupSchedulerService>().reschedule();
    await _loadStatus();
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    final l10n = context.l10n;
    final result = await context.read<BackupService>().exportBackup();
    if (!mounted) return;
    setState(() => _busy = false);

    if (result.success) {
      context.showSuccessFeedback(l10n.backupExportSuccess);
    } else {
      context.showErrorFeedback(l10n.backupExportFailed);
    }
  }

  Future<void> _import() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.backupImportConfirmTitle),
        content: Text(l10n.backupImportConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.backupImportConfirmAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final pick = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['dmbackup', 'zip'],
    );
    if (pick == null || pick.files.single.path == null || !mounted) return;

    setState(() => _busy = true);
    final result = await context.read<BackupService>().importBackup(
          File(pick.files.single.path!),
        );
    if (!mounted) return;
    setState(() => _busy = false);

    if (result.success) {
      context.read<SettingsProvider>().reloadFromStorage();
      await context.read<WalletProvider>().loadWallets();
      await context.read<CurrencyProvider>().loadCurrencies();
      await context.read<ProfileProvider>().load();
      context.read<DashboardRefreshProvider>().notifyRefresh();
      await _loadStatus();
      context.showSuccessFeedback(l10n.backupImportSuccess);
    } else {
      final message = switch (result.errorKey) {
        'invalid_archive' => l10n.backupInvalidArchive,
        'unsupported_schema' => l10n.backupUnsupportedSchema,
        _ => l10n.backupImportFailed,
      };
      context.showErrorFeedback(message);
    }
  }

  String _formatLastBackup(BuildContext context, DateTime? at) {
    if (at == null) return context.l10n.backupNever;
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).add_jm().format(at);
  }

  String _formatTime(BuildContext context, TimeOfDay time) {
    final locale = Localizations.localeOf(context).toString();
    final dt = DateTime(2020, 1, 1, time.hour, time.minute);
    return DateFormat.jm(locale).format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.backupLastRun,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatLastBackup(context, _status?.lastBackupAt),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.folder_outlined, color: colors.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.backupStoragePath,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _status?.isCustomLocation ?? false
                              ? l10n.backupStoragePathCustom
                              : l10n.backupStoragePathDefault,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          _status?.archivePath ?? '—',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickBackupDirectory,
                                icon: const Icon(Icons.drive_folder_upload_outlined),
                                label: Text(l10n.backupChangeLocation),
                              ),
                            ),
                            if (_status?.isCustomLocation ?? false) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: _resetBackupDirectory,
                                tooltip: l10n.backupResetLocation,
                                icon: const Icon(Icons.restore),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Text(l10n.backupAutoEnabled),
                  subtitle: Text(l10n.backupAutoEnabledSubtitle),
                  value: settings.backupEnabled,
                  onChanged: _toggleAuto,
                ),
                ListTile(
                  title: Text(l10n.backupScheduleTime),
                  subtitle: Text(_formatTime(context, settings.backupTime)),
                  trailing: const Icon(Icons.schedule),
                  onTap: settings.backupEnabled ? _pickBackupTime : null,
                  enabled: settings.backupEnabled,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.upload_outlined),
                  title: Text(l10n.backupExportNow),
                  onTap: _export,
                ),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: Text(l10n.backupImport),
                  onTap: _import,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: colors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.backupSecurityWarning,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
