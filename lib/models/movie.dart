import 'cast_member.dart';
import 'episode.dart';

class Movie {
  final String id;
  final String title;
  final String synopsis;
  final double rating;
  final List<String> tags; // e.g. ["4K", "IMAX", "VIP"]
  final List<String> genres; // e.g. ["Sci-Fi", "Thriller"]
  final String posterUrl;
  final String backdropUrl;
  final String duration;
  final String releaseYear;
  final double? watchProgress; // 0.0 to 1.0
  final String? episodeInfo;
  final String dailymotionVideoId; // Dailymotion ID e.g. "x8m00bc"
  final bool isSeries;
  final bool isAnime;
  final bool isNewRelease;
  final bool isTopRated;
  final List<CastMember> cast;
  final List<Episode> episodes;

  const Movie({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.rating,
    required this.tags,
    required this.genres,
    required this.posterUrl,
    required this.backdropUrl,
    required this.duration,
    required this.releaseYear,
    this.dailymotionVideoId = 'x8m00bc',
    this.isSeries = false,
    this.isAnime = false,
    this.isNewRelease = false,
    this.isTopRated = false,
    this.watchProgress,
    this.episodeInfo,
    this.cast = const [],
    this.episodes = const [],
  });
}
