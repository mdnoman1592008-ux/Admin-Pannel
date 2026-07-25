import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_profile.dart';
import '../services/auth_email_service.dart';

enum UserRole { user, moderator, admin, superAdmin }

enum AuthErrorCode {
  cancelled,
  invalidCredentials,
  networkError,
  accountExistsWithDifferentCredential,
  unknown,
}

class AuthException implements Exception {
  const AuthException(this.message, {this.code = AuthErrorCode.unknown});

  final String message;
  final AuthErrorCode code;

  @override
  String toString() => message;
}

class UserDocument {
  const UserDocument({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoURL,
    this.avatar = '',
    required this.role,
    this.provider = 'email',
    required this.isActive,
    this.hasCompletedOnboarding = false,
    this.preferencesCompleted = false,
    this.favoriteGenres = const [],
    required this.createdAt,
    required this.lastLogin,
    this.profiles = const [],
  });

  final String uid;
  final String email;
  final String displayName;
  final String photoURL;
  final String avatar;
  final UserRole role;
  final String provider;
  final bool isActive;
  final bool hasCompletedOnboarding;
  final bool preferencesCompleted;
  final List<String> favoriteGenres;
  final DateTime createdAt;
  final DateTime lastLogin;
  final List<UserProfile> profiles;

  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;
  bool get isSuperAdmin => role == UserRole.superAdmin;

  UserDocument copyWith({
    String? email,
    String? displayName,
    String? photoURL,
    String? avatar,
    UserRole? role,
    String? provider,
    bool? isActive,
    bool? hasCompletedOnboarding,
    bool? preferencesCompleted,
    List<String>? favoriteGenres,
    DateTime? lastLogin,
    List<UserProfile>? profiles,
  }) =>
      UserDocument(
        uid: uid,
        email: email ?? this.email,
        displayName: displayName ?? this.displayName,
        photoURL: photoURL ?? this.photoURL,
        avatar: avatar ?? this.avatar,
        role: role ?? this.role,
        provider: provider ?? this.provider,
        isActive: isActive ?? this.isActive,
        hasCompletedOnboarding:
            hasCompletedOnboarding ?? this.hasCompletedOnboarding,
        preferencesCompleted: preferencesCompleted ?? this.preferencesCompleted,
        favoriteGenres: favoriteGenres ?? this.favoriteGenres,
        createdAt: createdAt,
        lastLogin: lastLogin ?? this.lastLogin,
        profiles: profiles ?? this.profiles,
      );

  Map<String, dynamic> toFirestoreMap() => {
        'email': email,
        'displayName': displayName,
        'photoURL': photoURL,
        'avatar': avatar,
        'role': _roleToValue(role),
        'provider': provider,
        'isActive': isActive,
        'hasCompletedOnboarding': hasCompletedOnboarding,
        'preferencesCompleted': preferencesCompleted,
        'favoriteGenres': favoriteGenres,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastLogin': Timestamp.fromDate(lastLogin),
        'profiles':
            profiles.map((profile) => profile.toFirestoreMap()).toList(),
      };

  factory UserDocument.fromFirestore(String uid, Map<String, dynamic> data) {
    final now = DateTime.now();
    return UserDocument(
      uid: uid,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'Viewer',
      photoURL: data['photoURL'] as String? ?? '',
      avatar: data['avatar'] as String? ?? '',
      role: _roleFromValue(data['role'] as String?),
      provider: data['provider'] as String? ?? 'email',
      isActive: data['isActive'] as bool? ?? true,
      hasCompletedOnboarding: data['hasCompletedOnboarding'] as bool? ?? false,
      preferencesCompleted: data['preferencesCompleted'] as bool? ?? false,
      favoriteGenres: List<String>.from(data['favoriteGenres'] ?? const []),
      createdAt: _dateFromValue(data['createdAt']) ?? now,
      lastLogin: _dateFromValue(data['lastLogin']) ?? now,
      profiles: (data['profiles'] as List<dynamic>? ?? const [])
          .whereType<Map<dynamic, dynamic>>()
          .map((profile) =>
              UserProfile.fromFirestoreMap(Map<String, dynamic>.from(profile)))
          .toList(),
    );
  }
}

DateTime? _dateFromValue(Object? value) =>
    value is Timestamp ? value.toDate() : null;

UserRole _roleFromValue(String? value) => switch (value) {
      'super_admin' || 'superAdmin' => UserRole.superAdmin,
      'admin' => UserRole.admin,
      'moderator' => UserRole.moderator,
      _ => UserRole.user,
    };

String _roleToValue(UserRole role) => switch (role) {
      UserRole.superAdmin => 'super_admin',
      _ => role.name,
    };

/// Firebase-backed auth repository. Auth credentials live in Firebase Auth and
/// product profile data is persisted in `users/{uid}` in Cloud Firestore.
class AuthRepository {
  factory AuthRepository() => _instance;
  AuthRepository._internal();
  static final AuthRepository _instance = AuthRepository._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AuthEmailService _emailService = const AuthEmailService();

  UserDocument? _currentUserDoc;
  UserProfile? _activeProfile;

  UserDocument? get currentUser => _currentUserDoc;
  UserProfile? get activeProfile => _activeProfile;
  Map<String, UserDocument> get firestoreUsers => _currentUserDoc == null
      ? const {}
      : {_currentUserDoc!.uid: _currentUserDoc!};
  UserRole get role => _currentUserDoc?.role ?? UserRole.user;
  UserRole get currentUserRole => role;
  bool canManageContent() => _currentUserDoc?.isAdmin ?? false;

  Stream<UserDocument?> get userChanges =>
      _firebaseAuth.authStateChanges().asyncExpand((user) {
        if (user == null) {
          _currentUserDoc = null;
          _activeProfile = null;
          return Stream.value(null);
        }
        return _userReference(user.uid).snapshots().asyncMap((snapshot) async {
          final document = snapshot.exists
              ? UserDocument.fromFirestore(user.uid, snapshot.data()!)
              : await _createUserDocument(user, _providerFor(user),
                  user.displayName ?? _fallbackName(user));
          _currentUserDoc = document;
          _activeProfile ??=
              document.profiles.isEmpty ? null : document.profiles.first;
          return document;
        });
      });

  DocumentReference<Map<String, dynamic>> _userReference(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<UserDocument> registerWithEmail(
      String displayName, String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null)
        throw const AuthException('Account creation did not return a user.');
      if (displayName.trim().isNotEmpty)
        await user.updateDisplayName(displayName.trim());
      final document = await _loadOrCreateUser(
        user,
        'email',
        displayName.trim().isEmpty ? _fallbackName(user) : displayName.trim(),
      );
      // A verification-email delivery failure must not invalidate a Firebase
      // account that was successfully created.
      try {
        await user.sendEmailVerification();
      } on FirebaseAuthException catch (error) {
        debugPrint('[AuthRepository] Verification email failed: ${error.code}');
      }
      _sendEmailSafely(() => _emailService.sendWelcome(
          email: document.email, name: document.displayName));
      return document;
    } on FirebaseAuthException catch (error) {
      throw _fromFirebaseAuthError(error, fallback: 'Registration failed.');
    }
  }

  Future<UserDocument> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null)
        throw const AuthException('Sign-in did not return a user.');
      final document =
          await _loadOrCreateUser(user, 'email', _fallbackName(user));
      _sendEmailSafely(() => _emailService.sendLoginAlert(
          email: document.email, name: document.displayName));
      return document;
    } on FirebaseAuthException catch (error) {
      throw _fromFirebaseAuthError(error, fallback: 'Unable to sign in.');
    }
  }

  Future<UserDocument> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null)
        throw const AuthException('Google sign-in was cancelled.',
            code: AuthErrorCode.cancelled);
      final authentication = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );
      final result = await _firebaseAuth.signInWithCredential(credential);
      final user = result.user;
      if (user == null)
        throw const AuthException('Google sign-in did not return a user.');
      return _loadOrCreateUser(
          user, 'google', googleUser.displayName ?? _fallbackName(user));
    } on FirebaseAuthException catch (error) {
      throw _fromFirebaseAuthError(error, fallback: 'Google sign-in failed.');
    }
  }

  Future<UserDocument> signInWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.cancelled) {
        throw const AuthException('Facebook sign-in was cancelled.',
            code: AuthErrorCode.cancelled);
      }
      if (result.status != LoginStatus.success || result.accessToken == null) {
        throw AuthException(result.message ?? 'Facebook sign-in failed.',
            code: AuthErrorCode.networkError);
      }
      final credential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);
      final firebaseResult =
          await _firebaseAuth.signInWithCredential(credential);
      final user = firebaseResult.user;
      if (user == null)
        throw const AuthException('Facebook sign-in did not return a user.');
      final data = await FacebookAuth.instance.getUserData();
      return _loadOrCreateUser(
          user, 'facebook', data['name'] as String? ?? _fallbackName(user));
    } on FirebaseAuthException catch (error) {
      throw _fromFirebaseAuthError(error, fallback: 'Facebook sign-in failed.');
    }
  }

  Future<UserDocument> signInAsGuest() => signInAnonymously();

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw _fromFirebaseAuthError(error,
          fallback: 'Unable to send the password reset email.');
    }
  }

  Future<UserDocument> signInAnonymously() async {
    try {
      final result = await _firebaseAuth.signInAnonymously();
      final user = result.user;
      if (user == null)
        throw const AuthException('Guest sign-in did not return a user.');
      return _loadOrCreateUser(user, 'anonymous', 'Guest Viewer');
    } on FirebaseAuthException catch (error) {
      throw _fromFirebaseAuthError(error, fallback: 'Guest sign-in failed.');
    }
  }

  Future<void> signOut() async {
    await Future.wait<void>([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
      FacebookAuth.instance.logOut(),
    ]);
    _currentUserDoc = null;
    _activeProfile = null;
  }

  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    await _userReference(user.uid).delete();
    await user.delete();
    _currentUserDoc = null;
    _activeProfile = null;
  }

  void setActiveProfile(UserProfile profile) => _activeProfile = profile;

  Future<void> updateUserAvatarAndName(
      {String? avatarUrl, String? displayName}) async {
    final user = _requireUser();
    if (displayName != null && displayName.trim().isNotEmpty)
      await user.updateDisplayName(displayName.trim());
    if (avatarUrl != null) await user.updatePhotoURL(avatarUrl);
    await _updateCurrent((document) => document.copyWith(
          displayName: displayName?.trim(),
          avatar: avatarUrl,
          photoURL: avatarUrl,
        ));
  }

  Future<List<UserProfile>> addProfile(UserProfile profile) =>
      _changeProfiles((profiles) => [...profiles, profile]);
  Future<List<UserProfile>> updateProfile(UserProfile profile) =>
      _changeProfiles((profiles) {
        final index = profiles.indexWhere((item) => item.id == profile.id);
        if (index >= 0) profiles[index] = profile;
        return profiles;
      });
  Future<List<UserProfile>> deleteProfile(String profileId) => _changeProfiles(
      (profiles) => profiles..removeWhere((item) => item.id == profileId));

  Future<void> updateUserFavoriteGenres(List<String> genres) => _updateCurrent(
        (document) => document.copyWith(
            favoriteGenres: genres, preferencesCompleted: true),
      );
  Future<void> completeOnboarding() => _updateCurrent(
        (document) => document.copyWith(hasCompletedOnboarding: true),
      );

  Future<UserDocument> _loadOrCreateUser(
      User user, String provider, String fallbackName) async {
    final snapshot = await _userReference(user.uid).get();
    final document = snapshot.exists
        ? UserDocument.fromFirestore(user.uid, snapshot.data()!)
        : await _createUserDocument(user, provider, fallbackName);
    final updated = document.copyWith(
      displayName:
          document.displayName.isEmpty ? fallbackName : document.displayName,
      photoURL:
          document.photoURL.isEmpty ? (user.photoURL ?? '') : document.photoURL,
      provider: provider,
      lastLogin: DateTime.now(),
    );
    await _userReference(user.uid)
        .set(updated.toFirestoreMap(), SetOptions(merge: true));
    _currentUserDoc = updated;
    _activeProfile ??= updated.profiles.isEmpty ? null : updated.profiles.first;
    return updated;
  }

  Future<UserDocument> _createUserDocument(
      User user, String provider, String fallbackName) async {
    final now = DateTime.now();
    final name = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!
        : fallbackName;
    final photo = user.photoURL ?? '';
    final document = UserDocument(
      uid: user.uid,
      email: user.email ?? '',
      displayName: name,
      photoURL: photo,
      avatar: photo,
      role: UserRole.user,
      provider: provider,
      isActive: true,
      createdAt: now,
      lastLogin: now,
      profiles: [
        UserProfile(
            id: 'default_${user.uid}', displayName: name, avatarUrl: photo)
      ],
    );
    await _userReference(user.uid).set(document.toFirestoreMap());
    return document;
  }

  Future<void> _updateCurrent(
      UserDocument Function(UserDocument) transform) async {
    final current = _currentUserDoc;
    if (current == null) return;
    final updated = transform(current);
    await _userReference(updated.uid)
        .set(updated.toFirestoreMap(), SetOptions(merge: true));
    _currentUserDoc = updated;
  }

  Future<List<UserProfile>> _changeProfiles(
      List<UserProfile> Function(List<UserProfile>) change) async {
    final current = _currentUserDoc;
    if (current == null) return const [];
    final profiles = change(List<UserProfile>.from(current.profiles));
    await _updateCurrent((document) => document.copyWith(profiles: profiles));
    return profiles;
  }

  User _requireUser() =>
      _firebaseAuth.currentUser ??
      (throw const AuthException(
          'You must be signed in to update your profile.'));
  String _fallbackName(User user) => user.email?.split('@').first ?? 'Viewer';
  String _providerFor(User user) => user.isAnonymous
      ? 'anonymous'
      : (user.providerData.isEmpty
          ? 'email'
          : user.providerData.first.providerId.replaceAll('.com', ''));

  void _sendEmailSafely(Future<void> Function() action) {
    action().catchError((Object error) {
      debugPrint('[AuthRepository] Auth email notification failed: $error');
    });
  }
}

AuthException _fromFirebaseAuthError(FirebaseAuthException error,
    {required String fallback}) {
  final code = switch (error.code) {
    'wrong-password' ||
    'user-not-found' ||
    'invalid-credential' ||
    'invalid-email' =>
      AuthErrorCode.invalidCredentials,
    'email-already-in-use' ||
    'account-exists-with-different-credential' =>
      AuthErrorCode.accountExistsWithDifferentCredential,
    'network-request-failed' => AuthErrorCode.networkError,
    _ => AuthErrorCode.unknown,
  };
  final message = switch (code) {
    AuthErrorCode.invalidCredentials => 'Incorrect email address or password.',
    AuthErrorCode.accountExistsWithDifferentCredential =>
      'This email is already registered with another sign-in method.',
    AuthErrorCode.networkError =>
      'Network error. Please check your connection and try again.',
    _ => error.message ?? fallback,
  };
  return AuthException(message, code: code);
}
