import '../logging/app_logger.dart';

class UserProfile {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isKids;
  final bool isAdmin;

  const UserProfile({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.isKids = false,
    this.isAdmin = false,
  });
}

class ProfileService {
  static final List<UserProfile> _profiles = [
    const UserProfile(id: 'p1', name: 'Alexander Vance', avatarUrl: 'person', isAdmin: true),
    const UserProfile(id: 'p2', name: 'Cyber Kids', avatarUrl: 'child_care', isKids: true),
    const UserProfile(id: 'p3', name: 'Guest Viewer', avatarUrl: 'face'),
  ];

  static UserProfile _activeProfile = _profiles[0];

  static UserProfile get activeProfile => _activeProfile;

  static List<UserProfile> get profiles => List.unmodifiable(_profiles);

  static void switchProfile(String profileId) {
    final profile = _profiles.firstWhere((p) => p.id == profileId, orElse: () => _profiles[0]);
    _activeProfile = profile;
    AppLogger.i('ProfileService', 'Switched to profile: ${profile.name}');
  }
}
