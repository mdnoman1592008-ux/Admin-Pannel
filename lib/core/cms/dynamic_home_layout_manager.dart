import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/home_section_model.dart';
import 'home_section_repository.dart';

class ContentRailConfig {
  final String id;
  final String title;
  final String layout;
  final String sorting;
  final String category;
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

  final HomeSectionRepository _sectionRepo = HomeSectionRepository();
  final Map<String, int> _watchProgressMs = {};
  final _layoutStreamController = StreamController<List<ContentRailConfig>>.broadcast();

  List<ContentRailConfig> get rails {
    return _sectionRepo.enabledSections.map((sec) {
      final legacyId = sec.id == 'sec_hero'
          ? 'hero_banner'
          : (sec.id == 'sec_trending'
              ? 'trending'
              : (sec.id == 'sec_categories' ? 'categories' : sec.id));
      return ContentRailConfig(
        id: legacyId,
        title: sec.title,
        layout: sec.layoutType.name,
        sorting: sec.contentSource.name,
        category: sec.filters['category'] ?? 'ALL',
        maximumItems: sec.maxItems,
        isVisible: sec.isEnabled,
      );
    }).toList();
  }

  Stream<List<ContentRailConfig>> get layoutStream => _layoutStreamController.stream;

  void reorderRails(int oldIndex, int newIndex) {
    final currentSecs = List<HomeSectionModel>.from(_sectionRepo.sections);
    if (oldIndex < newIndex) newIndex -= 1;
    final item = currentSecs.removeAt(oldIndex);
    currentSecs.insert(newIndex, item);
    _sectionRepo.reorderSections(currentSecs.map((s) => s.id).toList());
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
