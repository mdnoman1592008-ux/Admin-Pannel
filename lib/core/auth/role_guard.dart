import 'auth_repository.dart';

class RoleGuard {
  static bool canAccessAdminPortal(UserDocument? user) {
    if (user == null) return false;
    return user.role == UserRole.admin || user.role == UserRole.superAdmin;
  }

  static bool canManageAdmins(UserDocument? user) {
    if (user == null) return false;
    return user.role == UserRole.superAdmin;
  }
}
