import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/auth/auth_repository.dart';
import 'package:ether_cinema/core/auth/role_guard.dart';

void main() {
  group('Ether Cinema v11.0 Firebase Auth & RBAC Test Suite', () {
    final authRepo = AuthRepository();

    test('Super Admin account initialization should assign superAdmin role', () async {
      final superAdminUser = await authRepo.signInWithEmail('admin@ethercinema.com', 'AdminPass123!');
      expect(superAdminUser.role, UserRole.superAdmin);
      expect(superAdminUser.isAdmin, true);
      expect(superAdminUser.isSuperAdmin, true);
      expect(RoleGuard.canAccessAdminPortal(superAdminUser), true);
      expect(RoleGuard.canManageAdmins(superAdminUser), true);
    });

    test('Regular user sign in should assign user role and deny admin access', () async {
      final regularUser = await authRepo.signInWithEmail('user@ethercinema.com', 'Pass123!');
      expect(regularUser.role, UserRole.user);
      expect(regularUser.isAdmin, false);
      expect(regularUser.isSuperAdmin, false);
      expect(RoleGuard.canAccessAdminPortal(regularUser), false);
      expect(RoleGuard.canManageAdmins(regularUser), false);
    });

    test('Anonymous guest authentication should assign guest credentials', () async {
      final guestUser = await authRepo.signInAnonymously();
      expect(guestUser.provider, 'anonymous');
      expect(guestUser.isAdmin, false);
      expect(RoleGuard.canAccessAdminPortal(guestUser), false);
    });
  });
}
