import 'package:flutter/foundation.dart';

/// Granular Enterprise IAM Roles for Ether Cinema Admin Platform
enum AdminRole {
  superAdmin,
  admin,
  editor,
  moderator,
  support,
  viewer,
}

extension AdminRoleExtension on AdminRole {
  String toValue() {
    switch (this) {
      case AdminRole.superAdmin:
        return 'super_admin';
      case AdminRole.admin:
        return 'admin';
      case AdminRole.editor:
        return 'editor';
      case AdminRole.moderator:
        return 'moderator';
      case AdminRole.support:
        return 'support';
      case AdminRole.viewer:
        return 'viewer';
    }
  }

  static AdminRole fromValue(String? value) {
    switch (value?.toLowerCase()) {
      case 'super_admin':
      case 'superadmin':
        return AdminRole.superAdmin;
      case 'admin':
        return AdminRole.admin;
      case 'editor':
        return AdminRole.editor;
      case 'moderator':
        return AdminRole.moderator;
      case 'support':
        return AdminRole.support;
      case 'viewer':
        return AdminRole.viewer;
      default:
        return AdminRole.viewer;
    }
  }

  bool get isAuthorized => this != AdminRole.viewer;

  /// Granular Enterprise Permission Matrix
  bool canCreateContent() => this == AdminRole.superAdmin || this == AdminRole.admin || this == AdminRole.editor;
  bool canEditContent() => this == AdminRole.superAdmin || this == AdminRole.admin || this == AdminRole.editor;
  bool canDeleteContent() => this == AdminRole.superAdmin || this == AdminRole.admin;
  bool canManageUsers() => this == AdminRole.superAdmin || this == AdminRole.admin;
  bool canBroadcastNotifications() => this == AdminRole.superAdmin || this == AdminRole.admin || this == AdminRole.moderator;
  bool canManageRemoteConfig() => this == AdminRole.superAdmin;
  bool canUploadMedia() => this != AdminRole.viewer && this != AdminRole.support;
  bool canViewAuditLogs() => this == AdminRole.superAdmin || this == AdminRole.admin || this == AdminRole.support;
}

/// Admin User Entity
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

/// Auth State Status
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

/// Enterprise IAM & Auth Service
class AdminAuthService extends ChangeNotifier {
  static final AdminAuthService _instance = AdminAuthService._internal();
  factory AdminAuthService() => _instance;
  static AdminAuthService get instance => _instance;

  AdminAuthService._internal();

  AdminAuthState _state = AdminAuthState.initial();
  AdminAuthState get state => _state;

  static const List<String> configuredAdminEmails = [
    'admin@ethercinema.app',
    'owner@ethercinema.app',
    'admin@example.com',
    'owner@example.com',
  ];

  final Map<String, Map<String, dynamic>> _mockFirestoreUsers = {
    'uid_super_admin': {
      'uid': 'uid_super_admin',
      'email': 'admin@ethercinema.app',
      'displayName': 'Super Admin',
      'role': 'super_admin',
      'createdAt': '2024-01-01T00:00:00.000Z',
      'lastLoginAt': '2026-07-23T12:00:00.000Z',
    },
    'uid_editor': {
      'uid': 'uid_editor',
      'email': 'editor@ethercinema.app',
      'displayName': 'Content Editor',
      'role': 'editor',
      'createdAt': '2024-02-01T00:00:00.000Z',
      'lastLoginAt': '2026-07-23T12:00:00.000Z',
    },
  };

  Future<void> initialize() async {
    _state = AdminAuthState.authenticating();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 200));
    _state = AdminAuthState.unauthenticated();
    notifyListeners();
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _state = AdminAuthState.authenticating();
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || password.isEmpty) {
      _state = AdminAuthState.unauthenticated('Email and password cannot be empty.');
      notifyListeners();
      return false;
    }

    return _processUserAuthorization(cleanEmail, 'Email Admin');
  }

  Future<bool> signInWithGoogle() async {
    _state = AdminAuthState.authenticating();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    return _processUserAuthorization('admin@ethercinema.app', 'Google Admin');
  }

  Future<bool> signInWithFacebook() async {
    _state = AdminAuthState.authenticating();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    return _processUserAuthorization('owner@ethercinema.app', 'Facebook Admin');
  }

  bool _processUserAuthorization(String email, String defaultName) {
    final isAdminEmail = configuredAdminEmails.contains(email.toLowerCase());
    Map<String, dynamic>? userDoc;
    String? foundUid;

    for (final entry in _mockFirestoreUsers.entries) {
      if (entry.value['email'].toString().toLowerCase() == email.toLowerCase()) {
        userDoc = entry.value;
        foundUid = entry.key;
        break;
      }
    }

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
      foundUid = 'uid_${DateTime.now().millisecondsSinceEpoch}';
      userDoc = {
        'uid': foundUid,
        'email': email,
        'displayName': defaultName,
        'role': 'viewer',
        'createdAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
      };
      _mockFirestoreUsers[foundUid] = userDoc;
    }

    userDoc['lastLoginAt'] = DateTime.now().toIso8601String();
    final adminUser = AdminUser.fromFirestore(userDoc, foundUid!);

    if (adminUser.role.isAuthorized) {
      _state = AdminAuthState.authorized(adminUser);
      notifyListeners();
      return true;
    } else {
      _state = AdminAuthState.denied(
        adminUser,
        'Access Denied: Role "${adminUser.role.toValue()}" does not have access permissions.',
      );
      notifyListeners();
      return false;
    }
  }

  void setAuthStateForTesting(AdminAuthState testState) {
    _state = testState;
    notifyListeners();
  }

  Future<void> signOut() async {
    _state = AdminAuthState.authenticating();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 200));
    _state = AdminAuthState.unauthenticated();
    notifyListeners();
  }
}
