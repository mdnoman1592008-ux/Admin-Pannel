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
    this.dailymotionVideoId = 'x8m00bc',
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
    this.streamingSources = const [
      StreamingSource(
        id: 'src1',
        provider: StreamingProvider.dailymotion,
        urlOrId: 'x8m00bc',
        priority: 1,
      ),
      StreamingSource(
        id: 'src2',
        provider: StreamingProvider.youtube,
        urlOrId: 'dQw4w9WgXcQ',
        priority: 2,
      ),
      StreamingSource(
        id: 'src3',
        provider: StreamingProvider.hls,
        urlOrId: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        priority: 3,
      ),
      StreamingSource(
        id: 'src4',
        provider: StreamingProvider.mp4,
        urlOrId: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        priority: 4,
      ),
    ],
  });
}
