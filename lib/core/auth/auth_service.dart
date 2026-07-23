import 'package:flutter/foundation.dart';
import 'auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  UserDocument? get currentUser => _authRepository.currentUser;
  bool get isLoggedIn => currentUser != null;

  Future<UserDocument> signInWithEmailPassword(String email, String password) async {
    try {
      return await _authRepository.signInWithEmail(email, password);
    } catch (e) {
      debugPrint('[AuthService] Email Sign-In failed: $e');
      rethrow;
    }
  }

  Future<UserDocument> signInWithGoogle({String? mockEmail, String? mockDisplayName}) async {
    try {
      return await _authRepository.signInWithGoogle(
        mockEmail: mockEmail,
        mockDisplayName: mockDisplayName,
      );
    } catch (e) {
      debugPrint('[AuthService] Google Sign-In failed: $e');
      rethrow;
    }
  }

  Future<UserDocument> signInWithFacebook({
    String? mockEmail,
    String? mockDisplayName,
    bool simulateUserCancel = false,
    bool simulateNetworkError = false,
    bool simulateAccountConflict = false,
  }) async {
    try {
      return await _authRepository.signInWithFacebook(
        mockEmail: mockEmail,
        mockDisplayName: mockDisplayName,
        simulateUserCancel: simulateUserCancel,
        simulateNetworkError: simulateNetworkError,
        simulateAccountConflict: simulateAccountConflict,
      );
    } on AuthException catch (e) {
      debugPrint('[AuthService] Facebook Authentication Exception [${e.code.name}]: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[AuthService] Facebook Sign-In unexpected error: $e');
      throw AuthException('Unexpected Facebook login error: $e');
    }
  }

  Future<UserDocument> signInAsGuest() async {
    return await _authRepository.signInAsGuest();
  }

  void signOut() {
    _authRepository.signOut();
  }
}
