import '../cms/cms_repository.dart';

class AiRecommendationEngine {
  static List<CmsMovieItem> generateRecommendations({
    required List<CmsMovieItem> catalog,
    required List<String> userFavoriteGenres,
    required List<String> watchHistoryIds,
  }) {
    if (catalog.isEmpty) return [];

    final recommendations = catalog.where((movie) {
      final matchesGenre = movie.genres.any((g) => userFavoriteGenres.contains(g));
      final notYetWatched = !watchHistoryIds.contains(movie.id);
      return matchesGenre && notYetWatched;
    }).toList();

    if (recommendations.isEmpty) {
      return catalog.take(2).toList();
    }

    return recommendations;
  }
}
