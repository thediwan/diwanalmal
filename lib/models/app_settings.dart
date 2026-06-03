import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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
  });

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
    final themeMode = ThemeMode.values[reader.readInt()];

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
      securityCodeAcknowledged: reader.availableBytes > 0
          ? reader.readBool()
          : false,
    );
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
      ..writeBool(obj.securityCodeAcknowledged);
  }
}
