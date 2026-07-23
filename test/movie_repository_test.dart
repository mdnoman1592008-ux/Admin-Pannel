import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/services/movie_repository.dart';
import 'package:ether_cinema/core/mappers/movie_mapper.dart';

void main() {
  group('MovieRepository Unit Tests', () {
    final repository = MovieRepository();

    test('getTrending should return non-empty movie list', () async {
      final movies = await repository.getTrending();
      expect(movies.isNotEmpty, true);
      expect(movies.first.title, 'Silicon Soul');
    });

    test('searchMovies should filter correctly by title', () async {
      final results = await repository.searchMovies('Crystalline');
      expect(results.length, 1);
      expect(results.first.title, 'Crystalline Horizon');
    });

    test('MovieMapper should map DTO to Entity accurately', () {
      final dto = MovieDto(
        id: 'test_1',
        title: 'Test Movie',
        synopsis: 'Test Synopsis',
        rating: 4.8,
        posterUrl: 'http://test.com/poster.jpg',
        backdropUrl: 'http://test.com/backdrop.jpg',
        dailymotionId: 'x8m00bc',
      );

      final entity = MovieMapper.toEntity(dto);
      expect(entity.id, 'test_1');
      expect(entity.dailymotionVideoId, 'x8m00bc');
    });
  });
}
