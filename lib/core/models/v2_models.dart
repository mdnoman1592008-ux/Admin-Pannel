class CategoryItem {
  final String id;
  final String name;
  final String iconName;
  final int titleCount;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.iconName,
    required this.titleCount,
  });
}

class PlaylistItem {
  final String id;
  final String name;
  final List<String> movieIds;

  const PlaylistItem({
    required this.id,
    required this.name,
    required this.movieIds,
  });
}

class SubtitleItem {
  final String language;
  final String label;
  final String fileUrl;

  const SubtitleItem({
    required this.language,
    required this.label,
    required this.fileUrl,
  });
}

class AppNotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;

  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
  });
}
