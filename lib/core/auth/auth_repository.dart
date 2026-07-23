import 'package:flutter/foundation.dart';

enum UserRole {
  user,
  moderator,
  admin,
  superAdmin,
}

enum AuthErrorCode {
  cancelled,
  invalidCredentials,
  networkError,
  accountExistsWithDifferentCredential,
  unknown,
}

class AuthException implements Exception {
  final String message;
  final AuthErrorCode code;

  AuthException(this.message, {this.code = AuthErrorCode.unknown});

  @override
  String toString() => 'AuthException: $message (Code: ${code.name})';
}

class UserDocument {
  final String uid;
  final String email;
  final String displayName;
  final String photoURL;
  final UserRole role;
  final String provider;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastLogin;

  const UserDocument({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoURL,
    required this.role,
    this.provider = 'email',
    required this.isActive,
    required this.createdAt,
    required this.lastLogin,
  });

  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;
  bool get isSuperAdmin => role == UserRole.superAdmin;
}

class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  UserDocument? _currentUser;
  final Map<String, UserDocument> _firestoreUsers = {};

  UserDocument? get currentUser => _currentUser;
  Map<String, UserDocument> get firestoreUsers => Map.unmodifiable(_firestoreUsers);

  Future<UserDocument> signInWithEmail(String email, String password) async {
    final role = (email == 'admin@ethercinema.com') ? UserRole.superAdmin : UserRole.user;
    final uid = 'user_${email.replaceAll('@', '_').replaceAll('.', '_')}';
    final now = DateTime.now();

    final existingDoc = _firestoreUsers[uid];
    final doc = UserDocument(
      uid: uid,
      email: email,
      displayName: email.split('@').first,
      photoURL:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDzKwJZepW88E0hJiIBM4Vxba1Rpq3U50h9tkiPvp7xZJQK-mO2jMmpBbUeSRQbi8RFiA4qI7p9OGX6D5KDd63ubsU9_i6fdkW6RC-mW64KoyzIwowoe6zwbzI62x9DLZTHlWO0eABkKj5stmyuXQDPc12JQywmKdc1yNjmFOwic1xpNRC0aXvh3z81Pg_DP6CVgOLwf9QQzDXP88WrgFJo4NERkeXKJgYInTZCxEoQaioAg0i_neIHlapRuo2-ngOhlcuZFphmeA',
      role: role,
      provider: 'email',
      isActive: true,
      createdAt: existingDoc?.createdAt ?? now,
      lastLogin: now,
    );

    _firestoreUsers[uid] = doc;
    _currentUser = doc;
    debugPrint('[AuthRepository] Authenticated ${email} with role: ${role.name}');
    return _currentUser!;
  }

  Future<UserDocument> signInWithGoogle({String? mockEmail, String? mockDisplayName}) async {
    final email = mockEmail ?? 'google_user@gmail.com';
    final displayName = mockDisplayName ?? 'Google User';
    final uid = 'google_${email.replaceAll('@', '_').replaceAll('.', '_')}';
    final role = (email == 'admin@ethercinema.com') ? UserRole.superAdmin : UserRole.user;
    final now = DateTime.now();

    final existingDoc = _firestoreUsers[uid];
    final doc = UserDocument(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDzKwJZepW88E0hJiIBM4Vxba1Rpq3U50h9tkiPvp7xZJQK-mO2jMmpBbUeSRQbi8RFiA4qI7p9OGX6D5KDd63ubsU9_i6fdkW6RC-mW64KoyzIwowoe6zwbzI62x9DLZTHlWO0eABkKj5stmyuXQDPc12JQywmKdc1yNjmFOwic1xpNRC0aXvh3z81Pg_DP6CVgOLwf9QQzDXP88WrgFJo4NERkeXKJgYInTZCxEoQaioAg0i_neIHlapRuo2-ngOhlcuZFphmeA',
      role: role,
      provider: 'google',
      isActive: true,
      createdAt: existingDoc?.createdAt ?? now,
      lastLogin: now,
    );

    _firestoreUsers[uid] = doc;
    _currentUser = doc;
    debugPrint('[AuthRepository] Authenticated with Google: $email');
    return _currentUser!;
  }

  Future<UserDocument> signInWithFacebook({
    String? mockEmail,
    String? mockDisplayName,
    bool simulateUserCancel = false,
    bool simulateNetworkError = false,
    bool simulateAccountConflict = false,
  }) async {
    if (simulateUserCancel) {
      throw AuthException('User cancelled Facebook login flow.', code: AuthErrorCode.cancelled);
    }
    if (simulateNetworkError) {
      throw AuthException('Network error during Facebook authentication.', code: AuthErrorCode.networkError);
    }
    if (simulateAccountConflict) {
      throw AuthException(
        'An account already exists with the same email address but different sign-in credentials.',
        code: AuthErrorCode.accountExistsWithDifferentCredential,
      );
    }

    final email = mockEmail ?? 'facebook_user@ethercinema.com';
    final displayName = mockDisplayName ?? 'Facebook User';
    final uid = 'fb_${email.replaceAll('@', '_').replaceAll('.', '_')}';
    final role = (email == 'admin@ethercinema.com') ? UserRole.superAdmin : UserRole.user;
    final now = DateTime.now();

    final existingDoc = _firestoreUsers[uid];

    if (existingDoc == null) {
      // First Facebook login -> create user document
      final newDoc = UserDocument(
        uid: uid,
        email: email,
        displayName: displayName,
        photoURL: 'https://graph.facebook.com/$uid/picture?type=large',
        role: role,
        provider: 'facebook',
        isActive: true,
        createdAt: now,
        lastLogin: now,
      );
      _firestoreUsers[uid] = newDoc;
      _currentUser = newDoc;
      debugPrint('[AuthRepository] Created new Firestore User Document for Facebook user: ${newDoc.email}');
    } else {
      // Existing user -> update lastLogin
      final updatedDoc = UserDocument(
        uid: existingDoc.uid,
        email: existingDoc.email,
        displayName: existingDoc.displayName,
        photoURL: existingDoc.photoURL,
        role: existingDoc.role,
        provider: 'facebook',
        isActive: existingDoc.isActive,
        createdAt: existingDoc.createdAt,
        lastLogin: now,
      );
      _firestoreUsers[uid] = updatedDoc;
      _currentUser = updatedDoc;
      debugPrint('[AuthRepository] Updated lastLogin for existing Facebook user: ${updatedDoc.email}');
    }

    return _currentUser!;
  }

  Future<UserDocument> signInAsGuest() async {
    _currentUser = UserDocument(
      uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@ethercinema.local',
      displayName: 'Guest Viewer',
      photoURL: '',
      role: UserRole.user,
      provider: 'guest',
      isActive: true,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    debugPrint('[AuthRepository] Signed in as Anonymous Guest');
    return _currentUser!;
  }

  void signOut() {
    _currentUser = null;
    debugPrint('[AuthRepository] User signed out');
  }
}

class RoleGuard {
  static bool canAccessAdminPortal(UserDocument? user) {
    if (user == null) return false;
    return user.isAdmin;
  }

  static bool canManageAdmins(UserDocument? user) {
    if (user == null) return false;
    return user.isSuperAdmin;
  }
}
