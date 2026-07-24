class Episode {
  final String id;
  final int episodeNumber;
  final int seasonNumber;
  final String title;
  final String description;
  final String duration;
  final String thumbnail;
  final String dailymotionVideoId;
  final String? videoUrl;
  final String? subtitleUrl;
  final DateTime? uploadDate;

  const Episode({
    required this.id,
    required this.episodeNumber,
    this.seasonNumber = 1,
    required this.title,
    this.description = '',
    required this.duration,
    required this.thumbnail,
    required this.dailymotionVideoId,
    this.videoUrl,
    this.subtitleUrl,
    this.uploadDate,
  });

  String get thumbnailUrl => thumbnail;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'episodeNumber': episodeNumber,
      'seasonNumber': seasonNumber,
      'title': title,
      'description': description,
      'duration': duration,
      'thumbnail': thumbnail,
      'dailymotionVideoId': dailymotionVideoId,
      'videoUrl': videoUrl,
      'subtitleUrl': subtitleUrl,
      'uploadDate': (uploadDate ?? DateTime.now()).toIso8601String(),
    };
  }

  factory Episode.fromMap(Map<String, dynamic> map, String docId) {
    return Episode(
      id: docId,
      episodeNumber: map['episodeNumber'] ?? 1,
      seasonNumber: map['seasonNumber'] ?? 1,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      duration: map['duration'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      dailymotionVideoId: map['dailymotionVideoId'] ?? 'x8m00bc',
      videoUrl: map['videoUrl'],
      subtitleUrl: map['subtitleUrl'],
      uploadDate: map['uploadDate'] != null ? DateTime.tryParse(map['uploadDate']) : null,
    );
  }
}
