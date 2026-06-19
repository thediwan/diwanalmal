/// Local backup archive layout and file names.
abstract final class BackupConstants {
  static const String archiveFileName = 'dewanalmal_backup.dmbackup';
  static const String backupsSubdir = 'backups';
  static const String manifestFileName = 'manifest.json';
  static const int manifestVersion = 1;
  static const int maxSupportedSchemaVersion = 11;

  static const String lazarusDbFileName = 'lazarus.db';

  /// Hive box file names on disk (without path).
  static const List<String> hiveBoxFileNames = [
    'settings.hive',
    'currencies.hive',
    'wallets.hive',
  ];

  static const String workmanagerTaskName = 'dewanalmal_daily_backup';
  static const String notificationChannelId = 'backup_channel';
}
