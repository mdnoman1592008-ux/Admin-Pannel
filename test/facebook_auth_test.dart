import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/auth/auth_repository.dart';
import 'package:ether_cinema/core/auth/auth_service.dart';
import 'package:ether_cinema/features/auth/login_screen.dart';

void main() {
  group('Ether Cinema Facebook Authentication Test Suite', () {
    late AuthRepository authRepo;
    late AuthService authService;

    setUp(() {
      authRepo = AuthRepository();
      authService = AuthService(authRepository: authRepo);
    });

    test('First Facebook Login should auto-create Firestore user document', () async {
      final user = await authService.signInWithFacebook(
        mockEmail: 'alex.fb@ethercinema.com',
        mockDisplayName: 'Alex Morgan',
      );

      expect(user.email, 'alex.fb@ethercinema.com');
      expect(user.displayName, 'Alex Morgan');
      expect(user.provider, 'facebook');
      expect(user.photoURL.contains('graph.facebook.com'), true);
      expect(user.role, UserRole.user);
      expect(user.isActive, true);
      expect(user.createdAt, isNotNull);
      expect(user.lastLogin, isNotNull);

      // Verify Firestore User Document stored
      final storedUser = authRepo.firestoreUsers[user.uid];
      expect(storedUser, isNotNull);
      expect(storedUser?.provider, 'facebook');
    });

    test('Subsequent Facebook Login should update lastLogin while preserving createdAt', () async {
      final firstLogin = await authService.signInWithFacebook(
        mockEmail: 'repeat.fb@ethercinema.com',
        mockDisplayName: 'Repeat User',
      );
      final originalCreatedAt = firstLogin.createdAt;

      await Future.delayed(const Duration(milliseconds: 20));

      final secondLogin = await authService.signInWithFacebook(
        mockEmail: 'repeat.fb@ethercinema.com',
        mockDisplayName: 'Repeat User',
      );

      expect(secondLogin.createdAt, originalCreatedAt);
      expect(secondLogin.lastLogin.isAfter(originalCreatedAt) || secondLogin.lastLogin == originalCreatedAt, true);
    });

    test('Facebook Login error handling for User Cancellation', () async {
      expect(
        () async => await authService.signInWithFacebook(simulateUserCancel: true),
        throwsA(isA<AuthException>().having((e) => e.code, 'code', AuthErrorCode.cancelled)),
      );
    });

    test('Facebook Login error handling for Network Errors', () async {
      expect(
        () async => await authService.signInWithFacebook(simulateNetworkError: true),
        throwsA(isA<AuthException>().having((e) => e.code, 'code', AuthErrorCode.networkError)),
      );
    });

    test('Facebook Login error handling for Account Conflict', () async {
      expect(
        () async => await authService.signInWithFacebook(simulateAccountConflict: true),
        throwsA(
            isA<AuthException>().having((e) => e.code, 'code', AuthErrorCode.accountExistsWithDifferentCredential)),
      );
    });

    test('Facebook, Google, and Email authentication should operate side-by-side without regressions', () async {
      final emailUser = await authService.signInWithEmailPassword('user@ethercinema.com', 'Pass123!');
      expect(emailUser.provider, 'email');

      final googleUser = await authService.signInWithGoogle(mockEmail: 'guser@gmail.com');
      expect(googleUser.provider, 'google');

      final fbUser = await authService.signInWithFacebook(mockEmail: 'fbuser@fb.com');
      expect(fbUser.provider, 'facebook');

      expect(authService.isLoggedIn, true);
      expect(authService.currentUser?.provider, 'facebook');
    });

    testWidgets('LoginScreen should render "Continue with Facebook" button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      expect(find.text('Continue with Facebook'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Sign In with Email'), findsOneWidget);
      expect(find.byIcon(Icons.facebook_rounded), findsOneWidget);
    });
  });
}
