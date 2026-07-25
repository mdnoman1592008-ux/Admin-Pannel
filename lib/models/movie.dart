import 'cast_member.dart';
import 'episode.dart';
import 'season.dart';
import 'streaming_source.dart';

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
  final bool isUnreleased;
  final DateTime? scheduledPublishDate;
  final int notifyMeCount;
  final List<CastMember> cast;
  final List<Episode> episodes;
  final List<Season> seasons;
  final List<StreamingSource> streamingSources;

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
    this.dailymotionVideoId = '',
    this.isSeries = false,
    this.isAnime = false,
    this.isNewRelease = false,
    this.isTopRated = false,
    this.isUnreleased = false,
    this.scheduledPublishDate,
    this.notifyMeCount = 0,
    this.watchProgress,
    this.episodeInfo,
    this.cast = const [],
    this.episodes = const [],
    this.seasons = const [],
    this.streamingSources = const [],
  });
}
