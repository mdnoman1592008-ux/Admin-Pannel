import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/ott/ott_ecosystem_engine.dart';
import 'package:ether_cinema/core/cms/cms_repository.dart';

void main() {
  group('Ether Cinema v14.0 Enterprise OTT Ecosystem Suite', () {
    const adultProfile = ProfileModel(
      id: 'p1',
      name: 'Alexander VIP',
      avatarUrl: '',
      isKidsMode: false,
      pinCode: '1234',
      contentRatingRestriction: '18+',
      favoriteMovieIds: ['m1'],
      watchHistoryIds: ['m1'],
    );

    const kidsProfile = ProfileModel(
      id: 'p2',
      name: 'Cyber Kids',
      avatarUrl: '',
      isKidsMode: true,
      pinCode: '',
      contentRatingRestriction: 'PG-13',
      favoriteMovieIds: [],
      watchHistoryIds: [],
    );

    final restrictedMovie = CmsMovieItem(
      id: 'm99',
      title: 'Dark Cyberpunk 18+',
      synopsis: 'Restricted content.',
      dailymotionVideoId: 'x8m00bc',
      isPublished: true,
      releaseDate: DateTime.now(),
      genres: const ['18+', 'Cyberpunk'],
    );

    test('Kids profile should filter out 18+ restricted movies', () {
      expect(adultProfile.canAccessMovie(restrictedMovie), true);
      expect(kidsProfile.canAccessMovie(restrictedMovie), false);
    });

    test('UniversalSearchEngine should match query by title and genre', () {
      final catalog = [restrictedMovie];
      final results = UniversalSearchEngine.search(catalog: catalog, query: 'cyberpunk');
      expect(results.length, 1);
      expect(results.first.id, 'm99');
    });

    test('SecurityAuditLogger should log suspicious login attempts', () {
      SecurityAuditLogger.recordLoginAttempt('hacker@unknown.com', false, '192.168.1.100');
      expect(SecurityAuditLogger.securityLogs.first.contains('SUSPICIOUS_FAILURE'), true);
    });
  });
}
