import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool canCreateContent() =>
      this == AdminRole.superAdmin ||
      this == AdminRole.admin ||
      this == AdminRole.editor;
  bool canEditContent() =>
      this == AdminRole.superAdmin ||
      this == AdminRole.admin ||
      this == AdminRole.editor;
  bool canDeleteContent() =>
      this == AdminRole.superAdmin || this == AdminRole.admin;
  bool canManageUsers() =>
      this == AdminRole.superAdmin || this == AdminRole.admin;
  bool canBroadcastNotifications() =>
      this == AdminRole.superAdmin ||
      this == AdminRole.admin ||
      this == AdminRole.moderator;
  bool canManageRemoteConfig() => this == AdminRole.superAdmin;
  bool canUploadMedia() =>
      this != AdminRole.viewer && this != AdminRole.support;
  bool canViewAuditLogs() =>
      this == AdminRole.superAdmin ||
      this == AdminRole.admin ||
      this == AdminRole.support;
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
      createdAt: _adminDate(data['createdAt']),
      lastLoginAt: _adminDate(data['lastLoginAt']),
    );
  }
}

DateTime _adminDate(Object? value) => value is Timestamp
    ? value.toDate()
    : DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();

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

  bool get isAuthorized =>
      status == AuthStatus.authorized &&
      user != null &&
      user!.role.isAuthorized;
}

/// Enterprise IAM & Auth Service
class AdminAuthService extends ChangeNotifier {
  static final AdminAuthService _instance = AdminAuthService._internal();
  factory AdminAuthService() => _instance;
  static AdminAuthService get instance => _instance;

  AdminAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminAuthState _state = AdminAuthState.initial();
  AdminAuthState get state => _state;

  Future<void> initialize() async {
    _state = AdminAuthState.authenticating();
    notifyListeners();
    final user = _auth.currentUser;
    if (user == null) {
      _state = AdminAuthState.unauthenticated();
      notifyListeners();
      return;
    }
    await _authorize(user);
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _state = AdminAuthState.authenticating();
    notifyListeners();

    if (email.trim().isEmpty || password.isEmpty) {
      _state =
          AdminAuthState.unauthenticated('Email and password cannot be empty.');
      notifyListeners();
      return false;
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      if (credential.user == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }
      return _authorize(credential.user!);
    } on FirebaseAuthException catch (error) {
      _state =
          AdminAuthState.unauthenticated(error.message ?? 'Unable to sign in.');
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _state = AdminAuthState.authenticating();
    notifyListeners();
    try {
      final result = await _auth.signInWithPopup(GoogleAuthProvider());
      if (result.user == null) return false;
      return _authorize(result.user!);
    } on FirebaseAuthException catch (error) {
      _state = AdminAuthState.unauthenticated(
          error.message ?? 'Google sign-in failed.');
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithFacebook() async {
    _state = AdminAuthState.authenticating();
    notifyListeners();
    try {
      final result = await _auth.signInWithPopup(FacebookAuthProvider());
      if (result.user == null) return false;
      return _authorize(result.user!);
    } on FirebaseAuthException catch (error) {
      _state = AdminAuthState.unauthenticated(
          error.message ?? 'Facebook sign-in failed.');
      notifyListeners();
      return false;
    }
  }

  Future<bool> _authorize(User user) async {
    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    if (!snapshot.exists) {
      _state = AdminAuthState.unauthenticated(
          'This account has no admin role assigned.');
      notifyListeners();
      return false;
    }
    final data = snapshot.data()!;
    final adminUser = AdminUser.fromFirestore(data, user.uid);

    if (adminUser.role.isAuthorized) {
      _state = AdminAuthState.authorized(adminUser);
      notifyListeners();
      await snapshot.reference
          .update({'lastLoginAt': FieldValue.serverTimestamp()});
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

  Future<void> signOut() async {
    _state = AdminAuthState.authenticating();
    notifyListeners();
    await _auth.signOut();
    _state = AdminAuthState.unauthenticated();
    notifyListeners();
  }
}
