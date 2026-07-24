import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/domain/usecases/get_trending_movies.dart';
import 'package:ether_cinema/core/security/security_service.dart';
import 'package:ether_cinema/core/cms/cms_repository.dart';

void main() {
  group('Domain & Security Unit Tests', () {
    test('GetTrendingMoviesUseCase should fetch movies', () async {
      CmsRepository().publishMovie(
        CmsMovieItem(
          id: 'test_m1',
          title: 'Test Movie',
          synopsis: 'Synopsis',
          dailymotionVideoId: 'x8m00bc',
          isPublished: true,
          releaseDate: DateTime.now(),
          genres: ['Sci-Fi'],
        ),
        'admin',
      );
      final useCase = GetTrendingMoviesUseCase();
      final movies = await useCase.execute();
      expect(movies.isNotEmpty, true);
    });

    test('SecurityService should validate Dailymotion IDs accurately', () {
      expect(SecurityService.validateDailymotionVideoId('x8m00bc'), true);
      expect(SecurityService.validateDailymotionVideoId(''), false);
    });
  });
}
