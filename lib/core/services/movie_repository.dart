import '../../models/movie.dart';
import '../cms/cms_repository.dart';
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
  final CmsRepository _cmsRepo = CmsRepository();

  Movie _cmsToMovie(CmsMovieItem item) {
    return Movie(
      id: item.id,
      title: item.title,
      synopsis: item.synopsis,
      rating: 4.8,
      tags: item.isSeries ? const ['SERIES', '4K'] : const ['HD', 'BLOCKBUSTER'],
      genres: item.genres,
      posterUrl: item.episodes.isNotEmpty ? item.episodes.first.thumbnail : '',
      backdropUrl: '',
      dailymotionVideoId: item.dailymotionVideoId,
      duration: item.episodes.isNotEmpty ? item.episodes.first.duration : '2h 15m',
      releaseYear: item.releaseDate.year.toString(),
      isSeries: item.isSeries,
      episodes: item.episodes,
    );
  }

  @override
  Future<List<Movie>> getFeaturedHeroMovies() async {
    return _cmsRepo.movies.map(_cmsToMovie).toList();
  }

  @override
  Future<List<Movie>> getContinueWatching() async {
    return _cmsRepo.movies.where((m) => m.position > 1).map(_cmsToMovie).toList();
  }

  @override
  Future<List<Movie>> getTrending() async {
    return _cmsRepo.movies.map(_cmsToMovie).toList();
  }

  @override
  Future<List<Movie>> getAnimeAndSeries() async {
    return _cmsRepo.movies.where((m) => m.isSeries).map(_cmsToMovie).toList();
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return _cmsRepo.movies.map(_cmsToMovie).toList();
    return _cmsRepo.movies.where((m) {
      return m.title.toLowerCase().contains(query.toLowerCase()) ||
          m.genres.any((g) => g.toLowerCase().contains(query.toLowerCase()));
    }).map(_cmsToMovie).toList();
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
    return '{"catalog_count": ${_cmsRepo.movies.length}, "version": "1.0.0"}';
  }
}
