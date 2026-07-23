import 'package:flutter/foundation.dart';
import '../config/environment_config.dart';

class AppLogger {
  static void d(String tag, String message) {
    if (EnvironmentConfig.isDebugMode) {
      debugPrint('[DEBUG] [$tag] $message');
    }
  }

  static void i(String tag, String message) {
    debugPrint('[INFO] [$tag] $message');
  }

  static void w(String tag, String message) {
    debugPrint('[WARN] [$tag] $message');
  }

  static void e(String tag, String message, [dynamic error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] [$tag] $message - Error: $error');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }

  static void player(String message) => d('PlayerService', message);
  static void network(String message) => d('NetworkService', message);
  static void admin(String message) => i('AdminPortal', message);
}
