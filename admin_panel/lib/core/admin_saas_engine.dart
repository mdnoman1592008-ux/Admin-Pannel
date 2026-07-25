import 'package:flutter/foundation.dart';

class PermissionMatrix {
  static bool hasPermission(String role, String permission) {
    if (role == 'super_admin') return true;
    if (role == 'admin') {
      return permission != 'DELETE_ADMIN' && permission != 'SECURITY_OVERRIDE';
    }
    if (role == 'moderator') {
      return permission == 'EDIT_METADATA' || permission == 'MODERATE_REPORT' || permission == 'VIEW_ANALYTICS';
    }
    return false;
  }
}
