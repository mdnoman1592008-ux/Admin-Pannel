import 'package:flutter/foundation.dart';

/// Role enum for Ether Cinema Web Admin Panel
enum AdminRole {
  superAdmin,
  admin,
  user,
  guest,
}

extension AdminRoleExtension on AdminRole {
  String toValue() {
    switch (this) {
      case AdminRole.superAdmin:
        return 'super_admin';
      case AdminRole.admin:
        return 'admin';
      case AdminRole.user:
        return 'user';
      case AdminRole.guest:
        return 'guest';
    }
  }

  static AdminRole fromValue(String? value) {
    switch (value) {
      case 'super_admin':
      case 'superAdmin':
        return AdminRole.superAdmin;
      case 'admin':
        return AdminRole.admin;
      case 'user':
        return AdminRole.user;
      default:
        return AdminRole.guest;
    }
  }

  bool get isAuthorized => this == AdminRole.admin || this == AdminRole.superAdmin;
}

/// Admin User Profile
class AdminUser {
  final String uid;
  final String email;
  final String displayName;
  final AdminRole role;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const AdminUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.createdAt,
    required this.lastLoginAt,
  });

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'role': role.toValue(),
        'createdAt': createdAt.toIso8601String(),
        'lastLoginAt': lastLoginAt.toIso8601String(),
      };

  factory AdminUser.fromFirestore(Map<String, dynamic> data, String uid) {
    return AdminUser(
      uid: uid,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'Admin User',
      role: AdminRoleExtension.fromValue(data['role'] as String?),
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastLoginAt: data['lastLoginAt'] != null
          ? DateTime.tryParse(data['lastLoginAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Authentication State Status
enum AuthStatus {
  initial,
  authenticating,
  authorized,
  denied,
  unauthenticated,
}

class AdminAuthState {
  final AuthStatus status;
  final AdminUser? user;
  final String? errorMessage;

  const AdminAuthState._({
    required this.status,
    this.user,
    this.errorMessage,
  });

  factory AdminAuthState.initial() =>
      const AdminAuthState._(status: AuthStatus.initial);

  factory AdminAuthState.authenticating() =>
      const AdminAuthState._(status: AuthStatus.authenticating);

  factory AdminAuthState.authorized(AdminUser user) =>
      AdminAuthState._(status: AuthStatus.authorized, user: user);

  factory AdminAuthState.denied(AdminUser user, String reason) =>
      AdminAuthState._(
        status: AuthStatus.denied,
        user: user,
        errorMessage: reason,
      );

  factory AdminAuthState.unauthenticated([String? error]) =>
      AdminAuthState._(status: AuthStatus.unauthenticated, errorMessage: error);

  bool get isAuthorized => status == AuthStatus.authorized && user != null && user!.role.isAuthorized;
}

/// Enterprise Admin Auth & Authorization Service
class AdminAuthService extends ChangeNotifier {
  static final AdminAuthService _instance = AdminAuthService._internal();
  factory AdminAuthService() => _instance;
  static AdminAuthService get instance => _instance;

  AdminAuthService._internal();

  AdminAuthState _state = AdminAuthState.initial();
  AdminAuthState get state => _state;

  /// Configurable List of Administrator Email Addresses
  static const List<String> configuredAdminEmails = [
    'admin@ethercinema.app',
    'owner@ethercinema.app',
    'admin@example.com',
    'owner@example.com',
  ];

  /// In-memory mock Firestore user collection for robust cross-platform validation
  final Map<String, Map<String, dynamic>> _mockFirestoreUsers = {
    'uid_super_admin': {
      'uid': 'uid_super_admin',
      'email': 'admin@ethercinema.app',
      'displayName': 'Super Admin',
      'role': 'super_admin',
      'createdAt': '2024-01-01T00:00:00.000Z',
      'lastLoginAt': '2026-07-23T12:00:00.000Z',
    },
    'uid_admin': {
      'uid': 'uid_admin',
      'email': 'manager@ethercinema.app',
      'displayName': 'Admin Manager',
      'role': 'admin',
      'createdAt': '2024-02-01T00:00:00.000Z',
      'lastLoginAt': '2026-07-23T12:00:00.000Z',
    },
    'uid_regular_user': {
      'uid': 'uid_regular_user',
      'email': 'user@example.com',
      'displayName': 'Standard Customer',
      'role': 'user',
      'createdAt': '2024-03-01T00:00:00.000Z',
      'lastLoginAt': '2026-07-23T12:00:00.000Z',
    },
  };

  /// Initialize and restore existing session
  Future<void> initialize() async {
    _state = AdminAuthState.authenticating();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _state = AdminAuthState.unauthenticated();
    notifyListeners();
  }

  /// Sign In with Email & Password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _state = AdminAuthState.authenticating();
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || password.isEmpty) {
      _state = AdminAuthState.unauthenticated('Email and password cannot be empty.');
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _state = AdminAuthState.unauthenticated('Invalid credentials provided.');
      notifyListeners();
      return false;
    }

    return _processUserAuthorization(cleanEmail, 'Email Admin');
  }

  /// Sign In with Google Provider
  Future<bool> signInWithGoogle() async {
    _state = AdminAuthState.authenticating();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    return _processUserAuthorization('admin@ethercinema.app', 'Google Admin');
  }

  /// Sign In with Facebook Provider
  Future<bool> signInWithFacebook() async {
    _state = AdminAuthState.authenticating();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    return _processUserAuthorization('owner@ethercinema.app', 'Facebook Admin');
  }

  /// Process User Document & Enforce RBAC
  bool _processUserAuthorization(String email, String defaultName) {
    // 1. Check if email is in configured admin list
    final isAdminEmail = configuredAdminEmails.contains(email.toLowerCase());

    // 2. Search existing Firestore document
    Map<String, dynamic>? userDoc;
    String? foundUid;

    for (final entry in _mockFirestoreUsers.entries) {
      if (entry.value['email'].toString().toLowerCase() == email.toLowerCase()) {
        userDoc = entry.value;
        foundUid = entry.key;
        break;
      }
    }

    // 3. Auto-bootstrap if email is in admin list but doc doesn't exist
    if (userDoc == null && isAdminEmail) {
      foundUid = 'uid_${DateTime.now().millisecondsSinceEpoch}';
      userDoc = {
        'uid': foundUid,
        'email': email,
        'displayName': defaultName,
        'role': 'super_admin',
        'createdAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
      };
      _mockFirestoreUsers[foundUid] = userDoc;
    }

    if (userDoc == null) {
      // Document missing and not an admin email -> Default guest/user doc created for simulation
      foundUid = 'uid_${DateTime.now().millisecondsSinceEpoch}';
      userDoc = {
        'uid': foundUid,
        'email': email,
        'displayName': defaultName,
        'role': 'user',
        'createdAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
      };
      _mockFirestoreUsers[foundUid] = userDoc;
    }

    // Update lastLoginAt
    userDoc['lastLoginAt'] = DateTime.now().toIso8601String();
    final adminUser = AdminUser.fromFirestore(userDoc, foundUid!);

    // 4. Strictly evaluate Role-Based Access Control
    if (adminUser.role.isAuthorized) {
      _state = AdminAuthState.authorized(adminUser);
      notifyListeners();
      return true;
    } else {
      _state = AdminAuthState.denied(
        adminUser,
        'Access Denied: Your account role "${adminUser.role.toValue()}" does not have administrator privileges.',
      );
      notifyListeners();
      return false;
    }
  }

  /// Direct override method for unit & widget tests
  void setAuthStateForTesting(AdminAuthState testState) {
    _state = testState;
    notifyListeners();
  }

  /// Sign Out and purge credentials
  Future<void> signOut() async {
    _state = AdminAuthState.authenticating();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _state = AdminAuthState.unauthenticated();
    notifyListeners();
  }
}
