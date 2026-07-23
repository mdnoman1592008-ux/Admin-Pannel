import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/services/movie_repository.dart';
import 'package:ether_cinema/core/security/security_service.dart';
import 'package:ether_cinema/core/diagnostics/app_diagnostics.dart';

void main() {
  group('Ether Cinema v5.1 Production Release Candidate Test Suite', () {
    final repository = MovieRepository();

    test('Catalog data integrity should be 100% valid for production', () async {
      final trending = await repository.getTrending();
      final continueWatching = await repository.getContinueWatching();

      expect(trending.isNotEmpty, true);
      expect(continueWatching.isNotEmpty, true);
      expect(trending.first.dailymotionVideoId.isNotEmpty, true);
    });

    test('Security & System Health Audit must pass for Release Candidate', () {
      final report = AppDiagnostics.runFullAudit();
      expect(report.overallHealth, true);
      expect(report.securityPassed, true);
      expect(SecurityService.validateDailymotionVideoId('x8m00bc'), true);
    });
  });
}
