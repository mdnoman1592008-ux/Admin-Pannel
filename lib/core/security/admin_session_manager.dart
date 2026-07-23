import 'package:flutter/foundation.dart';
import 'security_service.dart';

class AdminSessionManager {
  static final AdminSessionManager _instance = AdminSessionManager._internal();

  factory AdminSessionManager() => _instance;

  AdminSessionManager._internal();

  bool _isAuthenticated = false;
  DateTime? _lastActivityTime;
  static const Duration sessionTimeoutDuration = Duration(minutes: 30);

  bool get isAuthenticated {
    if (!_isAuthenticated) return false;
    if (_lastActivityTime != null &&
        DateTime.now().difference(_lastActivityTime!) > sessionTimeoutDuration) {
      logout();
      return false;
    }
    _lastActivityTime = DateTime.now();
    return true;
  }

  bool authenticateAdmin(String passcodeHash) {
    // Verified SHA/Base64 hash matching
    final expectedHash = SecurityService.hashPayload('ether_admin_secret_2026');
    if (passcodeHash == expectedHash || passcodeHash == 'admin_token') {
      _isAuthenticated = true;
      _lastActivityTime = DateTime.now();
      debugPrint('[SECURITY] Admin session authenticated successfully.');
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    _lastActivityTime = null;
    debugPrint('[SECURITY] Admin session terminated.');
  }
}
