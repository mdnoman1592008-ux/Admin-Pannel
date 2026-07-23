import '../../models/movie.dart';
import '../../data/mock_data.dart';
import '../models/admin_config.dart';

abstract class IMovieRepository {
  Future<List<Movie>> getFeaturedHeroMovies();
  Future<List<Movie>> getContinueWatching();
  Future<List<Movie>> getTrending();
  Future<List<Movie>> getAnimeAndSeries();
  Future<List<Movie>> searchMovies(String query);
  Future<AdminConfig> getAdminConfig();
  Future<void> updateAdminConfig(AdminConfig config);
  Future<String> exportBackupJson();
}

class MovieRepository implements IMovieRepository {
  AdminConfig _config = const AdminConfig();

  @override
  Future<List<Movie>> getFeaturedHeroMovies() async {
    return [MockData.featuredHeroMovie];
  }

  @override
  Future<List<Movie>> getContinueWatching() async {
    return MockData.continueWatchingMovies;
  }

  @override
  Future<List<Movie>> getTrending() async {
    return MockData.trendingMovies;
  }

  @override
  Future<List<Movie>> getAnimeAndSeries() async {
    return MockData.animeMovies;
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return MockData.searchResults;
    return MockData.searchResults.where((m) {
      return m.title.toLowerCase().contains(query.toLowerCase()) ||
          m.genres.any((g) => g.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  @override
  Future<AdminConfig> getAdminConfig() async {
    return _config;
  }

  @override
  Future<void> updateAdminConfig(AdminConfig config) async {
    _config = config;
  }

  @override
  Future<String> exportBackupJson() async {
    return '{"catalog_count": 428, "dailymotion_links": 1250, "version": "1.0.0"}';
  }
}
