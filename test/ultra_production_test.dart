import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/downloads/encrypted_download_manager.dart';
import 'package:ether_cinema/core/analytics/crash_reporting_service.dart';

void main() {
  group('Ultra Production Engine v7.0 Test Suite', () {
    test('EncryptedDownloadManager should manage encrypted payloads', () async {
      final queue = EncryptedDownloadManager.activeQueue;
      expect(queue.isNotEmpty, true);
      expect(queue.first.isEncryptedAtRest, true);

      final success = await EncryptedDownloadManager.startEncryptedDownload('x8m00bc', 'Aetherius 4K');
      expect(success, true);
      expect(EncryptedDownloadManager.validatePayloadIntegrity('d1'), true);
    });

    test('CrashReportingService should record non-fatal errors and telemetry diagnostics', () {
      CrashReportingService.recordNonFatalError('Network timeout simulated', null, reason: 'Testing recovery');
      final diag = CrashReportingService.getDiagnostics();
      expect(diag['firebase_crashlytics'], true);
    });
  });
}
