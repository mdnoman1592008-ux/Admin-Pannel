import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/services/movie_repository.dart';
import 'package:ether_cinema/core/performance/performance_monitor.dart';
import 'package:ether_cinema/core/theme/app_colors.dart';
import 'package:ether_cinema/core/cms/cms_repository.dart';

void main() {
  group('Ether Cinema v9.0 World-Class UI/UX Test Suite', () {
    final repository = MovieRepository();

    test('Color Palette should match World-Class Glassmorphic Palette', () {
      expect(AppColors.background.value, 0xFF050505);
      expect(AppColors.primaryContainer.value, 0xFF00D4FF);
    });

    test('Catalog items should map backdrop, rating, and video ID for Hero UI', () async {
      CmsRepository().publishMovie(
        CmsMovieItem(
          id: 'hero_1',
          title: 'Hero Movie',
          synopsis: 'Synopsis',
          dailymotionVideoId: 'x8m00bc',
          isPublished: true,
          releaseDate: DateTime.now(),
          genres: ['Sci-Fi'],
        ),
        'admin',
      );
      final featured = await repository.getFeaturedHeroMovies();
      expect(featured.isNotEmpty, true);
      final hero = featured.first;
      expect(hero.rating >= 4.0, true);
      expect(hero.dailymotionVideoId, 'x8m00bc');
    });

    test('PerformanceMonitor should maintain 120 FPS target for micro-animations', () {
      PerformanceMonitor.recordFrame(8.33);
      final metrics = PerformanceMonitor.getMetrics();
      expect(metrics.averageFps > 115, true);
    });
  });
}
