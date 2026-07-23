import 'dart:async';
import 'package:flutter/foundation.dart';

class ContentRailConfig {
  final String id;
  final String title;
  final String layout; // horizontal, grid, hero
  final String sorting; // priority, rating, releaseDate
  final String category; // ALL, Sci-Fi, Natok, Anime, etc.
  final int maximumItems;
  final bool isVisible;

  const ContentRailConfig({
    required this.id,
    required this.title,
    required this.layout,
    required this.sorting,
    required this.category,
    required this.maximumItems,
    required this.isVisible,
  });

  ContentRailConfig copyWith({
    String? title,
    String? layout,
    String? sorting,
    String? category,
    int? maximumItems,
    bool? isVisible,
  }) {
    return ContentRailConfig(
      id: id,
      title: title ?? this.title,
      layout: layout ?? this.layout,
      sorting: sorting ?? this.sorting,
      category: category ?? this.category,
      maximumItems: maximumItems ?? this.maximumItems,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

class DynamicHomeLayoutManager {
  static final DynamicHomeLayoutManager _instance = DynamicHomeLayoutManager._internal();
  factory DynamicHomeLayoutManager() => _instance;
  DynamicHomeLayoutManager._internal();

  final List<ContentRailConfig> _rails = [
    const ContentRailConfig(id: 'hero_banner', title: 'Hero Carousel', layout: 'hero', sorting: 'priority', category: 'ALL', maximumItems: 5, isVisible: true),
    const ContentRailConfig(id: 'categories', title: 'Category Pills', layout: 'horizontal', sorting: 'priority', category: 'ALL', maximumItems: 17, isVisible: true),
    const ContentRailConfig(id: 'continue_watching', title: 'Continue Watching', layout: 'horizontal', sorting: 'lastWatched', category: 'ALL', maximumItems: 10, isVisible: true),
    const ContentRailConfig(id: 'trending', title: 'Trending Now', layout: 'horizontal', sorting: 'rating', category: 'ALL', maximumItems: 10, isVisible: true),
    const ContentRailConfig(id: 'recommended', title: 'AI Recommended', layout: 'horizontal', sorting: 'aiScore', category: 'ALL', maximumItems: 10, isVisible: true),
    const ContentRailConfig(id: 'anime', title: 'Anime & Cyberpunk', layout: 'horizontal', sorting: 'releaseDate', category: 'Anime', maximumItems: 10, isVisible: true),
  ];

  final Map<String, int> _watchProgressMs = {};

  final _layoutStreamController = StreamController<List<ContentRailConfig>>.broadcast();

  List<ContentRailConfig> get rails => List.unmodifiable(_rails.where((r) => r.isVisible));
  Stream<List<ContentRailConfig>> get layoutStream => _layoutStreamController.stream;

  void reorderRails(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _rails.removeAt(oldIndex);
    _rails.insert(newIndex, item);
    _layoutStreamController.add(rails);
    debugPrint('[DynamicHomeLayoutManager] Reordered rail ${item.title} to position $newIndex');
  }

  void saveWatchProgress(String movieId, int progressMs) {
    _watchProgressMs[movieId] = progressMs;
    debugPrint('[DynamicHomeLayoutManager] Synced progress for $movieId: $progressMs ms');
  }

  int getWatchProgress(String movieId) {
    return _watchProgressMs[movieId] ?? 0;
  }
}
