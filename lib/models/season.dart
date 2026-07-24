import 'episode.dart';

enum SeasonStatus { draft, published, scheduled, archived }

class Season {
  final String id;
  final String seriesId;
  final int seasonNumber;
  final String seasonTitle;
  final String posterUrl;
  final String bannerUrl;
  final String description;
  final DateTime releaseDate;
  final SeasonStatus status;
  final int displayOrder;
  final List<Episode> episodes;

  const Season({
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    required this.seasonTitle,
    this.posterUrl = '',
    this.bannerUrl = '',
    this.description = '',
    required this.releaseDate,
    this.status = SeasonStatus.published,
    this.displayOrder = 0,
    this.episodes = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seriesId': seriesId,
      'seasonNumber': seasonNumber,
      'seasonTitle': seasonTitle,
      'posterUrl': posterUrl,
      'bannerUrl': bannerUrl,
      'description': description,
      'releaseDate': releaseDate.toIso8601String(),
      'status': status.name,
      'displayOrder': displayOrder,
      'episodes': episodes.map((e) => e.toMap()).toList(),
    };
  }

  factory Season.fromMap(Map<String, dynamic> map, String docId) {
    return Season(
      id: docId,
      seriesId: map['seriesId'] ?? '',
      seasonNumber: map['seasonNumber'] ?? 1,
      seasonTitle: map['seasonTitle'] ?? 'Season 1',
      posterUrl: map['posterUrl'] ?? '',
      bannerUrl: map['bannerUrl'] ?? '',
      description: map['description'] ?? '',
      releaseDate: map['releaseDate'] != null ? DateTime.tryParse(map['releaseDate']) ?? DateTime.now() : DateTime.now(),
      status: SeasonStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SeasonStatus.published,
      ),
      displayOrder: map['displayOrder'] ?? 0,
      episodes: (map['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromMap(e as Map<String, dynamic>, e['id'] ?? ''))
              .toList() ??
          [],
    );
  }
}
