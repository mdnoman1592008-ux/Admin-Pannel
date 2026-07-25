import 'package:flutter/foundation.dart';
import 'auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  UserDocument? get currentUser => _authRepository.currentUser;
  bool get isLoggedIn => currentUser != null;

  Future<UserDocument> registerWithEmailPassword(
      String name, String email, String password) async {
    try {
      return await _authRepository.registerWithEmail(name, email, password);
    } catch (e) {
      debugPrint('[AuthService] Registration failed: $e');
      rethrow;
    }
  }

  Future<UserDocument> signInWithEmailPassword(
      String email, String password) async {
    try {
      return await _authRepository.signInWithEmail(email, password);
    } catch (e) {
      debugPrint('[AuthService] Email Sign-In failed: $e');
      rethrow;
    }
  }

  Future<UserDocument> signInWithGoogle() async {
    try {
      return await _authRepository.signInWithGoogle();
    } catch (e) {
      debugPrint('[AuthService] Google Sign-In failed: $e');
      rethrow;
    }
  }

  Future<UserDocument> signInWithFacebook() async {
    try {
      return await _authRepository.signInWithFacebook();
    } on AuthException catch (e) {
      debugPrint(
          '[AuthService] Facebook Authentication Exception [${e.code.name}]: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[AuthService] Facebook Sign-In unexpected error: $e');
      throw AuthException('Unexpected Facebook login error: $e');
    }
  }

  Future<UserDocument> signInAsGuest() async {
    return await _authRepository.signInAsGuest();
  }

  Future<void> signOut() {
    return _authRepository.signOut();
  }

  Future<void> deleteAccount() async {
    await _authRepository.deleteAccount();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _authRepository.sendPasswordResetEmail(email);
  }

  Future<void> sendEmailVerification() => _authRepository.sendEmailVerification();

  Future<bool> isCurrentEmailVerified() => _authRepository.isCurrentEmailVerified();
}
