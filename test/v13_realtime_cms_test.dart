import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/cms/realtime_cms_engine.dart';
import 'package:ether_cinema/core/cms/cms_repository.dart';
import 'package:ether_cinema/core/ai/recommendation_engine.dart';

void main() {
  group('Ether Cinema v13.0 Realtime Firebase CMS & AI Test Suite', () {
    final realtimeEngine = RealtimeCmsEngine();

    test('RealtimeCmsEngine should broadcast movie catalog updates', () async {
      final sampleMovies = [
        CmsMovieItem(
          id: 'm10',
          title: 'Cyber AI Odyssey 2026',
          synopsis: 'Autonomous AI streaming universe.',
          dailymotionVideoId: 'x8m00bc',
          isPublished: true,
          releaseDate: DateTime.now(),
          genres: const ['Sci-Fi', 'AI Shorts'],
        )
      ];

      expect(realtimeEngine.movieStream, emits(sampleMovies));
      realtimeEngine.emitMovies(sampleMovies);
    });

    test('AiRecommendationEngine should score and return genre-matched unwatched items', () {
      final catalog = [
        CmsMovieItem(
          id: 'm1',
          title: 'Aetherius 4K',
          synopsis: 'Space adventure.',
          dailymotionVideoId: 'x8m00bc',
          isPublished: true,
          releaseDate: DateTime.now(),
          genres: const ['Sci-Fi'],
        ),
        CmsMovieItem(
          id: 'm2',
          title: 'Romantic Sunset',
          synopsis: 'Drama film.',
          dailymotionVideoId: 'x8lzs3e',
          isPublished: true,
          releaseDate: DateTime.now(),
          genres: const ['Romance'],
        ),
      ];

      final recs = AiRecommendationEngine.generateRecommendations(
        catalog: catalog,
        userFavoriteGenres: ['Sci-Fi'],
        watchHistoryIds: [],
      );

      expect(recs.length, 1);
      expect(recs.first.title, 'Aetherius 4K');
    });
  });
}
