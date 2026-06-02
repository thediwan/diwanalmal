import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// Application-wide settings stored locally.
class AppSettings extends HiveObject {
  AppSettings({
    required this.isSetupComplete,
    required this.baseCurrencyCode,
    required this.themeMode,
  });

  final bool isSetupComplete;
  final String baseCurrencyCode;
  final ThemeMode themeMode;

  AppSettings copyWith({
    bool? isSetupComplete,
    String? baseCurrencyCode,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
      baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
      themeMode: themeMode ?? this.themeMode,
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
    return AppSettings(
      isSetupComplete: reader.readBool(),
      baseCurrencyCode: reader.readString(),
      themeMode: ThemeMode.values[reader.readInt()],
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeBool(obj.isSetupComplete)
      ..writeString(obj.baseCurrencyCode)
      ..writeInt(obj.themeMode.index);
  }
}
