import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/services/movie_repository.dart';
import 'package:ether_cinema/core/security/security_service.dart';
import 'package:ether_cinema/core/diagnostics/app_diagnostics.dart';
import 'package:ether_cinema/core/cms/cms_repository.dart';

void main() {
  group('Ether Cinema v5.1 Production Release Candidate Test Suite', () {
    final repository = MovieRepository();

    test('Catalog data integrity should be 100% valid for production', () async {
      CmsRepository().publishMovie(
        CmsMovieItem(
          id: 'rc_m1',
          title: 'RC Movie 1',
          synopsis: 'Synopsis',
          dailymotionVideoId: 'x8m00bc',
          isPublished: true,
          releaseDate: DateTime.now(),
          genres: ['Sci-Fi'],
          position: 1,
        ),
        'admin',
      );
      CmsRepository().publishMovie(
        CmsMovieItem(
          id: 'rc_m2',
          title: 'RC Movie 2',
          synopsis: 'Synopsis',
          dailymotionVideoId: 'x8k92b1',
          isPublished: true,
          releaseDate: DateTime.now(),
          genres: ['Drama'],
          position: 2,
        ),
        'admin',
      );

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
