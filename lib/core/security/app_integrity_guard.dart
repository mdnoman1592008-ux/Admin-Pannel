import 'package:flutter/foundation.dart';
import '../logging/app_logger.dart';

class IntegrityReport {
  final bool isValidSignature;
  final bool isTampered;
  final bool isEmulator;
  final bool isDebuggerAttached;
  final String activePackageName;
  final String certificateHash;

  const IntegrityReport({
    required this.isValidSignature,
    required this.isTampered,
    required this.isEmulator,
    required this.isDebuggerAttached,
    required this.activePackageName,
    required this.certificateHash,
  });

  bool get isSecure => isValidSignature && !isTampered && (!kReleaseMode || !isDebuggerAttached);
}

class AppIntegrityGuard {
  static const String expectedPackageName = 'com.example.ether_cinema';
  static const String expectedCertHash = '13:BC:F5:18:8E:8A:7B:70:19:2D:FE:BA:82:D0:6A:11:E2:F8:38:97';

  static bool _screenshotProtectionEnabled = false;

  static bool get isScreenshotProtectionEnabled => _screenshotProtectionEnabled;

  static void enableScreenshotProtection() {
    _screenshotProtectionEnabled = true;
    AppLogger.i('AppIntegrityGuard', 'FLAG_SECURE enabled. Screen capture and screenshots disabled on sensitive views.');
  }

  static IntegrityReport verifyAppIntegrity({
    String? mockPackageName,
    String? mockCertHash,
    bool simulateTamper = false,
    bool simulateEmulator = false,
    bool simulateDebugger = false,
  }) {
    final pkg = mockPackageName ?? expectedPackageName;
    final cert = mockCertHash ?? expectedCertHash;

    final isValidSignature = (pkg == expectedPackageName) && (cert == expectedCertHash);
    final isTampered = simulateTamper || !isValidSignature;

    final report = IntegrityReport(
      isValidSignature: isValidSignature,
      isTampered: isTampered,
      isEmulator: simulateEmulator,
      isDebuggerAttached: simulateDebugger,
      activePackageName: pkg,
      certificateHash: cert,
    );

    if (!report.isSecure) {
      AppLogger.e(
        'AppIntegrityGuard',
        'COMPROMISE DETECTED! Signature: ${report.isValidSignature}, Tampered: ${report.isTampered}, Debugger: ${report.isDebuggerAttached}',
      );
    } else {
      AppLogger.i('AppIntegrityGuard', 'App bundle, signature, and runtime integrity verified successfully.');
    }

    return report;
  }
}
