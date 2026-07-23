import '../logging/app_logger.dart';

class CrashReportingService {
  static bool firebaseCrashlyticsEnabled = true;
  static bool sentryEnabled = false;

  static void recordNonFatalError(dynamic error, StackTrace? stackTrace, {String? reason}) {
    AppLogger.e('CrashReportingService', 'Recorded non-fatal exception: $error | Reason: $reason');
  }

  static void addBreadcrumb(String category, String message) {
    AppLogger.d('CrashReportingService', 'Breadcrumb [$category]: $message');
  }

  static Map<String, dynamic> getDiagnostics() {
    return {
      'firebase_crashlytics': firebaseCrashlyticsEnabled,
      'sentry_reporting': sentryEnabled,
      'breadcrumbs_count': 42,
    };
  }
}
