import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../core/helpers/uuid_helper.dart';
import '../database/lazarus_database.dart';
import '../models/profile_data.dart';
import '../core/helpers/app_storage_paths.dart';
import 'hive_service.dart';
import 'lazarus_database_service.dart';

/// Loads and updates profile data in Lazarus [app_users].
class ProfileService {
  ProfileService(this._lazarus, this._hiveService);

  final LazarusDatabaseService _lazarus;
  final HiveService _hiveService;

  LazarusDatabase get _db => _lazarus.database;

  Future<ProfileData> load() async {
    final hiveSettings = _hiveService.getSettings();
    final userId = await _ensureUserId();
    final user = await (_db.select(_db.appUsers)
          ..where((u) => u.id.equals(userId)))
        .getSingleOrNull();

    if (user == null) {
      return ProfileData(
        userId: userId,
        displayName: hiveSettings.username.isNotEmpty
            ? hiveSettings.username
            : 'مستخدم',
        username: hiveSettings.username,
      );
    }

    return ProfileData(
      userId: user.id,
      displayName: user.fullName,
      username: hiveSettings.username,
      email: user.email,
      phone: user.phone,
      avatarPath: user.avatarPath,
    );
  }

  Future<void> updatePersonalInfo({
    required String fullName,
    String? email,
    String? phone,
  }) async {
    final userId = await _ensureUserId();
    final now = DateTime.now();
    final trimmedName = fullName.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('fullName cannot be empty');
    }

    final normalizedEmail = email?.trim();
    final normalizedPhone = phone?.trim();

    await (_db.update(_db.appUsers)..where((u) => u.id.equals(userId))).write(
      AppUsersCompanion(
        fullName: Value(trimmedName),
        email: normalizedEmail == null || normalizedEmail.isEmpty
            ? const Value.absent()
            : Value(normalizedEmail),
        phone: normalizedPhone == null || normalizedPhone.isEmpty
            ? const Value.absent()
            : Value(normalizedPhone),
        updatedAt: Value(now),
      ),
    );
  }

  Future<String> updateAvatar(String sourcePath) async {
    final userId = await _ensureUserId();
    final appDir = await AppStoragePaths.ensureDataDirectory();
    final avatarsDir = Directory(p.join(appDir, 'avatars'));
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }

    final destPath = p.join(avatarsDir.path, 'avatar_$userId.jpg');
    await File(sourcePath).copy(destPath);

    final now = DateTime.now();
    await (_db.update(_db.appUsers)..where((u) => u.id.equals(userId))).write(
      AppUsersCompanion(
        avatarPath: Value(destPath),
        updatedAt: Value(now),
      ),
    );

    return destPath;
  }

  Future<void> syncLanguage(String localeCode) async {
    final userId = await _lazarus.getActiveUserId();
    if (userId == null) return;

    final now = DateTime.now();
    await (_db.update(_db.userSettings)..where((s) => s.userId.equals(userId)))
        .write(
      UserSettingsCompanion(
        language: Value(localeCode),
        updatedAt: Value(now),
      ),
    );
  }

  Future<String> _ensureUserId() async {
    final existing = await _lazarus.getActiveUserId();
    if (existing != null) return existing;

    final settings = _hiveService.getSettings();
    final now = DateTime.now();
    final userId = UuidHelper.generate();

    await _db.into(_db.appUsers).insert(
          AppUsersCompanion.insert(
            id: userId,
            fullName: settings.username.isNotEmpty
                ? settings.username
                : 'مستخدم',
            createdAt: now,
            updatedAt: now,
          ),
        );

    await _lazarus.ensureSystemCategories(userId);
    return userId;
  }
}
