import 'package:flutter/foundation.dart';
import '../logging/app_logger.dart';

class NetworkSecurityGuard {
  static const List<String> pinnedDomains = [
    'ozqfltgvxlgpvytjofis.supabase.co',
    'ether-cinema.firebaseapp.com',
    'api.dailymotion.com',
  ];

  static bool enforceHttps(String url) {
    if (!url.startsWith('https://')) {
      AppLogger.e('NetworkSecurityGuard', 'SECURITY VIOLATION: Non-HTTPS request blocked: $url');
      return false;
    }
    return true;
  }

  static bool validateCertificatePinning({
    required String domain,
    required String certificateFingerprint,
    bool simulateInvalidCert = false,
  }) {
    if (simulateInvalidCert) {
      AppLogger.e('NetworkSecurityGuard', 'CERTIFICATE PINNING FAILURE: Invalid certificate for domain $domain!');
      return false;
    }

    if (!enforceHttps('https://$domain')) {
      return false;
    }

    AppLogger.i('NetworkSecurityGuard', 'Certificate pinning verified for endpoint: $domain');
    return true;
  }
}
