import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/auth/auth_repository.dart';

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
      final regularUser = await authRepo.signInWithEmail('user@gmail.com', 'UserPass123!');
      expect(regularUser.role, UserRole.user);
      expect(regularUser.isAdmin, false);
      expect(regularUser.isSuperAdmin, false);
      expect(RoleGuard.canAccessAdminPortal(regularUser), false);
      expect(RoleGuard.canManageAdmins(regularUser), false);
    });

    test('Anonymous Guest sign in should assign user role', () async {
      final guestUser = await authRepo.signInAsGuest();
      expect(guestUser.role, UserRole.user);
      expect(guestUser.isAdmin, false);
      expect(RoleGuard.canAccessAdminPortal(guestUser), false);
    });
  });
}
