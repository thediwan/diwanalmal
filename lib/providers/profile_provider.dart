import 'package:flutter/material.dart';

import '../models/profile_data.dart';
import '../services/profile_service.dart';

/// Profile hub state — name, avatar, and personal info from Lazarus.
class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._profileService);

  final ProfileService _profileService;

  ProfileData? _profile;
  bool _isLoading = false;
  String? _error;

  ProfileData? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _profileService.load();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePersonalInfo({
    required String fullName,
    String? email,
    String? phone,
  }) async {
    await _profileService.updatePersonalInfo(
      fullName: fullName,
      email: email,
      phone: phone,
    );
    await load();
  }

  Future<void> updateAvatar(String sourcePath) async {
    final path = await _profileService.updateAvatar(sourcePath);
    if (_profile != null) {
      _profile = _profile!.copyWith(avatarPath: path);
      notifyListeners();
    } else {
      await load();
    }
  }
}
