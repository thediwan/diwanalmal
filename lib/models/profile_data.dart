/// View model for the profile settings hub and personal info screens.
class ProfileData {
  const ProfileData({
    required this.userId,
    required this.displayName,
    required this.username,
    this.email,
    this.phone,
    this.avatarPath,
  });

  final String userId;
  final String displayName;
  final String username;
  final String? email;
  final String? phone;
  final String? avatarPath;

  String get subtitleEmail {
    if (email != null && email!.trim().isNotEmpty) return email!.trim();
    if (username.isNotEmpty) return username;
    return '';
  }

  ProfileData copyWith({
    String? displayName,
    String? email,
    String? phone,
    String? avatarPath,
  }) {
    return ProfileData(
      userId: userId,
      displayName: displayName ?? this.displayName,
      username: username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
