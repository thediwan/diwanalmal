import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../core/constants/transaction_policy.dart';
import 'amount_format_style.dart';

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
  })  : _transactionDeleteWindowHours = transactionDeleteWindowHours,
        _transactionEditWindowDays = transactionEditWindowDays,
        _amountFormatStyleIndex = amountFormatStyleIndex;

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

  final int? _transactionDeleteWindowHours;
  final int? _transactionEditWindowDays;
  final int? _amountFormatStyleIndex;

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
    );
  }

  /// Reads a bool only when at least one byte remains.
  static bool _readOptionalBool(BinaryReader reader) {
    return reader.availableBytes > 0 ? reader.readBool() : false;
  }

  /// Reads a Hive-encoded int when any bytes remain.
  static int? _readOptionalInt(BinaryReader reader) {
    if (reader.availableBytes == 0) return null;
    return reader.readInt();
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
      ..writeInt(obj.amountFormatStyle.storageIndex);
  }
}
