import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/domain/usecases/get_trending_movies.dart';
import 'package:ether_cinema/core/security/security_service.dart';

void main() {
  group('Domain & Security Unit Tests', () {
    test('GetTrendingMoviesUseCase should fetch movies', () async {
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
