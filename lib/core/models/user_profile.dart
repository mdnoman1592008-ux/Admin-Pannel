class UserProfile {
  final String id;
  final String displayName;
  final String avatarUrl;
  final bool isKids;
  final bool isLocked;
  final String pinCode;
  final List<String> favorites;
  final Map<String, int> watchHistory;

  UserProfile({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    this.isKids = false,
    this.isLocked = false,
    this.pinCode = '',
    this.favorites = const [],
    this.watchHistory = const {},
  });

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? avatarUrl,
    bool? isKids,
    bool? isLocked,
    String? pinCode,
    List<String>? favorites,
    Map<String, int>? watchHistory,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isKids: isKids ?? this.isKids,
      isLocked: isLocked ?? this.isLocked,
      pinCode: pinCode ?? this.pinCode,
      favorites: favorites ?? this.favorites,
      watchHistory: watchHistory ?? this.watchHistory,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'id': id,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'isKids': isKids,
      'isLocked': isLocked,
      'pinCode': pinCode,
      'favorites': favorites,
      'watchHistory': watchHistory,
    };
  }

  factory UserProfile.fromFirestoreMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      displayName: map['displayName'] ?? 'Viewer',
      avatarUrl: map['avatarUrl'] ?? '',
      isKids: map['isKids'] ?? false,
      isLocked: map['isLocked'] ?? false,
      pinCode: map['pinCode'] ?? '',
      favorites: List<String>.from(map['favorites'] ?? []),
      watchHistory: Map<String, int>.from(map['watchHistory'] ?? {}),
    );
  }
}
