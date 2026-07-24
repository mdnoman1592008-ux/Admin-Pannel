class BannerItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? movieId;
  final int displayOrder;
  final bool isPublished;

  const BannerItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.movieId,
    this.displayOrder = 0,
    this.isPublished = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'movieId': movieId,
      'displayOrder': displayOrder,
      'isPublished': isPublished,
    };
  }

  factory BannerItem.fromMap(Map<String, dynamic> map, String id) {
    return BannerItem(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      movieId: map['movieId'],
      displayOrder: map['displayOrder'] ?? 0,
      isPublished: map['isPublished'] ?? true,
    );
  }
}
