class Episode {
  final String id;
  final int episodeNumber;
  final int seasonNumber;
  final String title;
  final String duration;
  final String thumbnail;
  final String dailymotionVideoId;

  const Episode({
    required this.id,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.title,
    required this.duration,
    required this.thumbnail,
    required this.dailymotionVideoId,
  });
}
