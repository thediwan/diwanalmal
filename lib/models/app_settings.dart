import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../core/constants/transaction_policy.dart';
import '../core/theme/palettes/app_color_palette.dart';
import 'amount_format_style.dart';
import 'font_size_preference.dart';

/// Application-wide settings stored locally.
class AppSettings extends HiveObject {
  AppSettings({
    required this.isSetupComplete,
    required this.baseCurrencyCode,
    required this.themeMode,
    this.hasAccount = false,
    this.username = '',
    this.password = '',
    this.securityCode = '',
    this.pinCode = '',
    this.biometricEnabled = false,
    this.isSecuritySetupComplete = false,
    this.securityCodeAcknowledged = false,
    int? transactionDeleteWindowHours,
    int? transactionEditWindowDays,
    int? amountFormatStyleIndex,
    int? fontSizePreferenceIndex,
    this.localeCode = 'ar',
    this.colorPaletteKey,
    this.backupHour = 2,
    this.backupMinute = 0,
    this.backupEnabled = true,
    this.lastBackupAt,
  })  : _transactionDeleteWindowHours = transactionDeleteWindowHours,
        _transactionEditWindowDays = transactionEditWindowDays,
        _amountFormatStyleIndex = amountFormatStyleIndex,
        _fontSizePreferenceIndex = fontSizePreferenceIndex;

  final bool isSetupComplete;
  final String baseCurrencyCode;
  final ThemeMode themeMode;
  final bool hasAccount;
  final String username;
  final String password;
  final String securityCode;
  final String pinCode;
  final bool biometricEnabled;
  final bool isSecuritySetupComplete;
  final bool securityCodeAcknowledged;
  final String localeCode;

  /// Storage key for the chosen color palette (null → default = original).
  final String? colorPaletteKey;

  /// Daily automatic backup hour (0–23).
  final int backupHour;

  /// Daily automatic backup minute (0–59).
  final int backupMinute;

  /// When false, scheduled backups are skipped.
  final bool backupEnabled;

  /// Timestamp of the last successful backup (local device time).
  final DateTime? lastBackupAt;

  TimeOfDay get backupTime => TimeOfDay(hour: backupHour, minute: backupMinute);

  AppColorPaletteId get colorPaletteId =>
      AppColorPaletteId.fromStorageKey(colorPaletteKey);

  final int? _transactionDeleteWindowHours;
  final int? _transactionEditWindowDays;
  final int? _amountFormatStyleIndex;
  final int? _fontSizePreferenceIndex;

  /// Never null — safe after Hive migrations or hot reload.
  int get transactionDeleteWindowHours =>
      _transactionDeleteWindowHours ??
      TransactionPolicyDefaults.deleteWindowHours;

  /// Never null — safe after Hive migrations or hot reload.
  int get transactionEditWindowDays =>
      _transactionEditWindowDays ?? TransactionPolicyDefaults.editWindowDays;

  /// Number grouping / decimal separator for amounts (settings UI later).
  AmountFormatStyle get amountFormatStyle =>
      AmountFormatStyle.fromStorageIndex(_amountFormatStyleIndex);

  FontSizePreference get fontSizePreference =>
      FontSizePreference.fromStorageIndex(_fontSizePreferenceIndex);

  AppSettings copyWith({
    bool? isSetupComplete,
    String? baseCurrencyCode,
    ThemeMode? themeMode,
    bool? hasAccount,
    String? username,
    String? password,
    String? securityCode,
    String? pinCode,
    bool? biometricEnabled,
    bool? isSecuritySetupComplete,
    bool? securityCodeAcknowledged,
    int? transactionDeleteWindowHours,
    int? transactionEditWindowDays,
    int? amountFormatStyleIndex,
    int? fontSizePreferenceIndex,
    String? localeCode,
    String? colorPaletteKey,
    int? backupHour,
    int? backupMinute,
    bool? backupEnabled,
    DateTime? lastBackupAt,
    bool clearLastBackupAt = false,
  }) {
    return AppSettings(
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
      baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
      themeMode: themeMode ?? this.themeMode,
      hasAccount: hasAccount ?? this.hasAccount,
      username: username ?? this.username,
      password: password ?? this.password,
      securityCode: securityCode ?? this.securityCode,
      pinCode: pinCode ?? this.pinCode,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      isSecuritySetupComplete:
          isSecuritySetupComplete ?? this.isSecuritySetupComplete,
      securityCodeAcknowledged:
          securityCodeAcknowledged ?? this.securityCodeAcknowledged,
      transactionDeleteWindowHours: transactionDeleteWindowHours ??
          _transactionDeleteWindowHours,
      transactionEditWindowDays:
          transactionEditWindowDays ?? _transactionEditWindowDays,
      amountFormatStyleIndex:
          amountFormatStyleIndex ?? _amountFormatStyleIndex,
      fontSizePreferenceIndex:
          fontSizePreferenceIndex ?? _fontSizePreferenceIndex,
      localeCode: localeCode ?? this.localeCode,
      colorPaletteKey: colorPaletteKey ?? this.colorPaletteKey,
      backupHour: backupHour ?? this.backupHour,
      backupMinute: backupMinute ?? this.backupMinute,
      backupEnabled: backupEnabled ?? this.backupEnabled,
      lastBackupAt:
          clearLastBackupAt ? null : (lastBackupAt ?? this.lastBackupAt),
    );
  }

  static AppSettings initial() {
    return AppSettings(
      isSetupComplete: false,
      baseCurrencyCode: '',
      themeMode: ThemeMode.system,
    );
  }
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 2;

  @override
  AppSettings read(BinaryReader reader) {
    final isSetupComplete = reader.readBool();
    final baseCurrencyCode = reader.readString();
    final themeModeIndex = reader.readInt();
    final themeMode = themeModeIndex >= 0 && themeModeIndex < ThemeMode.values.length
        ? ThemeMode.values[themeModeIndex]
        : ThemeMode.system;

    if (reader.availableBytes == 0) {
      return AppSettings(
        isSetupComplete: isSetupComplete,
        baseCurrencyCode: baseCurrencyCode,
        themeMode: themeMode,
      );
    }

    return AppSettings(
      isSetupComplete: isSetupComplete,
      baseCurrencyCode: baseCurrencyCode,
      themeMode: themeMode,
      hasAccount: reader.readBool(),
      username: reader.readString(),
      password: reader.readString(),
      securityCode: reader.readString(),
      pinCode: reader.readString(),
      biometricEnabled: reader.readBool(),
      isSecuritySetupComplete: reader.readBool(),
      securityCodeAcknowledged: _readOptionalBool(reader),
      transactionDeleteWindowHours: _readOptionalInt(reader),
      transactionEditWindowDays: _readOptionalInt(reader),
      amountFormatStyleIndex: _readOptionalInt(reader),
      localeCode: _readOptionalString(reader) ?? 'ar',
      colorPaletteKey: _readOptionalString(reader),
      fontSizePreferenceIndex: _readOptionalInt(reader),
      backupHour: _readOptionalInt(reader) ?? 2,
      backupMinute: _readOptionalInt(reader) ?? 0,
      backupEnabled: _readOptionalBool(reader, defaultValue: true),
      lastBackupAt: _readOptionalDateTime(reader),
    );
  }

  /// Reads a string when bytes remain (Hive locale migration).
  static String? _readOptionalString(BinaryReader reader) {
    if (reader.availableBytes == 0) return null;
    return reader.readString();
  }

  /// Reads a bool only when at least one byte remains.
  static bool _readOptionalBool(
    BinaryReader reader, {
    bool defaultValue = false,
  }) {
    return reader.availableBytes > 0 ? reader.readBool() : defaultValue;
  }

  /// Reads a Hive-encoded int when any bytes remain.
  static int? _readOptionalInt(BinaryReader reader) {
    if (reader.availableBytes == 0) return null;
    return reader.readInt();
  }

  /// Reads an ISO-8601 timestamp when bytes remain.
  static DateTime? _readOptionalDateTime(BinaryReader reader) {
    final raw = _readOptionalString(reader);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeBool(obj.isSetupComplete)
      ..writeString(obj.baseCurrencyCode)
      ..writeInt(obj.themeMode.index)
      ..writeBool(obj.hasAccount)
      ..writeString(obj.username)
      ..writeString(obj.password)
      ..writeString(obj.securityCode)
      ..writeString(obj.pinCode)
      ..writeBool(obj.biometricEnabled)
      ..writeBool(obj.isSecuritySetupComplete)
      ..writeBool(obj.securityCodeAcknowledged)
      ..writeInt(obj.transactionDeleteWindowHours)
      ..writeInt(obj.transactionEditWindowDays)
      ..writeInt(obj.amountFormatStyle.storageIndex)
      ..writeString(obj.localeCode)
      ..writeString(obj.colorPaletteKey ?? '')
      ..writeInt(obj.fontSizePreference.storageIndex)
      ..writeInt(obj.backupHour)
      ..writeInt(obj.backupMinute)
      ..writeBool(obj.backupEnabled)
      ..writeString(obj.lastBackupAt?.toIso8601String() ?? '');
  }
}
