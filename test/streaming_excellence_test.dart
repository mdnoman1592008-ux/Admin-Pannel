import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/services/movie_repository.dart';
import 'package:ether_cinema/core/downloads/encrypted_download_manager.dart';
import 'package:ether_cinema/core/diagnostics/app_diagnostics.dart';

void main() {
  group('Streaming Excellence v8.0 Test Suite', () {
    final repository = MovieRepository();

    test('Catalog items should be available for adaptive streaming', () async {
      final catalog = await repository.getTrending();
      expect(catalog.isNotEmpty, true);
      expect(catalog.first.dailymotionVideoId, 'x8m00bc');
    });

    test('Encrypted download payload checksum verification should succeed', () {
      expect(EncryptedDownloadManager.validatePayloadIntegrity('d1'), true);
    });

    test('System audit should report 100% healthy status', () {
      final report = AppDiagnostics.runFullAudit();
      expect(report.overallHealth, true);
      expect(report.securityPassed, true);
    });
  });
}
