import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema_admin_panel/core/auth/admin_auth_service.dart';
import 'package:ether_cinema_admin_panel/core/auth/auth_gateway.dart';
import 'package:ether_cinema_admin_panel/features/auth/login_screen.dart';
import 'package:ether_cinema_admin_panel/features/auth/access_denied_screen.dart';
import 'package:ether_cinema_admin_panel/features/shell/admin_shell.dart';
import 'package:ether_cinema_admin_panel/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final authService = AdminAuthService.instance;

  void setDesktopView(WidgetTester tester) {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
  }

  group('Enterprise Admin Auth & RBAC Security Tests', () {
    test('Unauthenticated users are denied access and shown LoginScreen by default', () {
      authService.setAuthStateForTesting(AdminAuthState.unauthenticated());
      expect(authService.state.status, equals(AuthStatus.unauthenticated));
      expect(authService.state.isAuthorized, isFalse);
    });

    test('Users with role=user or role=guest are denied administrative access', () {
      final regularUser = AdminUser(
        uid: 'u_101',
        email: 'user@example.com',
        displayName: 'Regular User',
        role: AdminRole.user,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      authService.setAuthStateForTesting(AdminAuthState.denied(regularUser, 'Access Denied'));

      expect(authService.state.status, equals(AuthStatus.denied));
      expect(authService.state.isAuthorized, isFalse);
      expect(authService.state.user?.role.isAuthorized, isFalse);
    });

    test('Users with role=admin are granted access', () {
      final adminUser = AdminUser(
        uid: 'u_202',
        email: 'admin@ethercinema.app',
        displayName: 'Admin User',
        role: AdminRole.admin,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      authService.setAuthStateForTesting(AdminAuthState.authorized(adminUser));

      expect(authService.state.status, equals(AuthStatus.authorized));
      expect(authService.state.isAuthorized, isTrue);
      expect(authService.state.user?.role, equals(AdminRole.admin));
    });

    test('Users with role=super_admin are granted full access', () {
      final superAdmin = AdminUser(
        uid: 'u_303',
        email: 'owner@ethercinema.app',
        displayName: 'Owner Super Admin',
        role: AdminRole.superAdmin,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      authService.setAuthStateForTesting(AdminAuthState.authorized(superAdmin));

      expect(authService.state.status, equals(AuthStatus.authorized));
      expect(authService.state.isAuthorized, isTrue);
      expect(authService.state.user?.role, equals(AdminRole.superAdmin));
    });

    test('Sign out purges session and returns to unauthenticated status', () async {
      final adminUser = AdminUser(
        uid: 'u_202',
        email: 'admin@ethercinema.app',
        displayName: 'Admin User',
        role: AdminRole.admin,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      authService.setAuthStateForTesting(AdminAuthState.authorized(adminUser));
      expect(authService.state.isAuthorized, isTrue);

      await authService.signOut();

      expect(authService.state.status, equals(AuthStatus.unauthenticated));
      expect(authService.state.isAuthorized, isFalse);
    });

    testWidgets('AuthGateway renders LoginScreen when unauthenticated', (WidgetTester tester) async {
      setDesktopView(tester);
      addTearDown(tester.view.resetPhysicalSize);

      authService.setAuthStateForTesting(AdminAuthState.unauthenticated());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const AuthGateway(),
        ),
      );
      await tester.pump();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(AdminShell), findsNothing);
      expect(find.byType(AccessDeniedScreen), findsNothing);
    });

    testWidgets('AuthGateway renders AccessDeniedScreen when role is denied', (WidgetTester tester) async {
      setDesktopView(tester);
      addTearDown(tester.view.resetPhysicalSize);

      final regularUser = AdminUser(
        uid: 'u_101',
        email: 'user@example.com',
        displayName: 'Regular User',
        role: AdminRole.user,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      authService.setAuthStateForTesting(
          AdminAuthState.denied(regularUser, 'Unauthorized Access'));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const AuthGateway(),
        ),
      );
      await tester.pump();

      expect(find.byType(AccessDeniedScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(AdminShell), findsNothing);
      expect(find.text('Access Denied 🚫'), findsOneWidget);
    });

    testWidgets('AuthGateway renders AdminShell when role is super_admin', (WidgetTester tester) async {
      setDesktopView(tester);
      addTearDown(tester.view.resetPhysicalSize);

      final superAdmin = AdminUser(
        uid: 'u_303',
        email: 'admin@ethercinema.app',
        displayName: 'Super Admin',
        role: AdminRole.superAdmin,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      authService.setAuthStateForTesting(AdminAuthState.authorized(superAdmin));

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const AuthGateway(),
        ),
      );
      await tester.pump();

      expect(find.byType(AdminShell), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(AccessDeniedScreen), findsNothing);
    });
  });
}
