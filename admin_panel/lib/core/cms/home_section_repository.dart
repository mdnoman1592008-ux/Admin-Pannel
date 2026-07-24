import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/home_section_model.dart';

class HomeSectionRepository {
  static final HomeSectionRepository _instance = HomeSectionRepository._internal();
  factory HomeSectionRepository() => _instance;
  HomeSectionRepository._internal();

  final List<HomeSectionModel> _sections = [];
  final _sectionsStreamController = StreamController<List<HomeSectionModel>>.broadcast();

  List<HomeSectionModel> get sections => List.unmodifiable(_sections..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)));
  Stream<List<HomeSectionModel>> get sectionsStream => _sectionsStreamController.stream;

  List<HomeSectionModel> get enabledSections {
    final now = DateTime.now();
    return List.unmodifiable(
      _sections
          .where((s) => s.isEnabled && s.scheduling.isCurrentlyActive)
          .toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)),
    );
  }

  void _initDefaultSections() {
    if (_sections.isNotEmpty) return;

    final now = DateTime.now();
    _sections.addAll([
      HomeSectionModel(
        id: 'sec_hero',
        title: 'Featured Blockbusters',
        slug: 'featured_blockbusters',
        description: 'Handpicked cinematic masterpieces in 4K HDR',
        layoutType: SectionLayoutType.heroBanner,
        contentSource: SectionContentSource.trending,
        iconName: 'star_rounded',
        displayOrder: 1,
        maxItems: 5,
        isEnabled: true,
        style: const SectionStyleConfig(
          autoScroll: true,
          showMoreButton: false,
        ),
        createdAt: now,
        updatedAt: now,
      ),
      HomeSectionModel(
        id: 'sec_categories',
        title: 'Category Navigation',
        slug: 'category_pills',
        description: 'Browse content by genre & category',
        layoutType: SectionLayoutType.horizontalCarousel,
        contentSource: SectionContentSource.category,
        iconName: 'category_rounded',
        displayOrder: 2,
        maxItems: 17,
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      ),
      HomeSectionModel(
        id: 'sec_continue',
        title: 'Continue Watching',
        slug: 'continue_watching',
        description: 'Pick up right where you left off',
        layoutType: SectionLayoutType.continueWatching,
        contentSource: SectionContentSource.continueWatching,
        iconName: 'play_circle_fill',
        displayOrder: 3,
        maxItems: 10,
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      ),
      HomeSectionModel(
        id: 'sec_trending',
        title: 'Trending Now',
        slug: 'trending_now',
        description: 'Most watched titles across Ether Cinema today',
        layoutType: SectionLayoutType.horizontalCarousel,
        contentSource: SectionContentSource.trending,
        iconName: 'local_fire_department_rounded',
        displayOrder: 4,
        maxItems: 12,
        isEnabled: true,
        style: const SectionStyleConfig(
          cardRadius: 16.0,
          posterRatio: 1.45,
        ),
        createdAt: now,
        updatedAt: now,
      ),
      HomeSectionModel(
        id: 'sec_top10',
        title: 'Top 10 Today in Bangladesh',
        slug: 'top_10_today',
        description: 'Daily ranking based on active streams',
        layoutType: SectionLayoutType.top10,
        contentSource: SectionContentSource.highestRated,
        iconName: 'leaderboard_rounded',
        displayOrder: 5,
        maxItems: 10,
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      ),
      HomeSectionModel(
        id: 'sec_coming_soon',
        title: 'Coming Soon & Premieres',
        slug: 'coming_soon',
        description: 'Set reminders for upcoming releases',
        layoutType: SectionLayoutType.comingSoon,
        contentSource: SectionContentSource.comingSoon,
        iconName: 'schedule_rounded',
        displayOrder: 6,
        maxItems: 8,
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      ),
      HomeSectionModel(
        id: 'sec_anime',
        title: 'Anime & Cyberpunk Worlds',
        slug: 'anime_cyberpunk',
        description: 'Futuristic animation & cyberpunk series',
        layoutType: SectionLayoutType.horizontalCarousel,
        contentSource: SectionContentSource.genre,
        filters: const {'genre': 'Anime'},
        iconName: 'auto_awesome_rounded',
        displayOrder: 7,
        maxItems: 10,
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      ),
      HomeSectionModel(
        id: 'sec_natok',
        title: 'Bangla Drama & Natok',
        slug: 'bangla_natok',
        description: 'Exclusive Bengali series and drama productions',
        layoutType: SectionLayoutType.grid,
        contentSource: SectionContentSource.category,
        filters: const {'category': 'Natok'},
        iconName: 'tv_rounded',
        displayOrder: 8,
        maxItems: 6,
        isEnabled: true,
        createdAt: now,
        updatedAt: now,
      ),
      HomeSectionModel(
        id: 'sec_kids',
        title: 'Kids & Family Favorites',
        slug: 'kids_family',
        description: 'Safe animated entertainment for all ages',
        layoutType: SectionLayoutType.horizontalCarousel,
        contentSource: SectionContentSource.category,
        filters: const {'category': 'Kids'},
        iconName: 'child_care_rounded',
        displayOrder: 9,
        maxItems: 10,
        isEnabled: true,
        visibility: SectionVisibilityRule.visible,
        createdAt: now,
        updatedAt: now,
      ),
    ]);

    _notifyListeners();
  }

  void _notifyListeners() {
    _sectionsStreamController.add(enabledSections);
  }

  Future<void> createSection(HomeSectionModel section) async {
    final nextOrder = _sections.isEmpty ? 1 : (_sections.map((s) => s.displayOrder).reduce((a, b) => a > b ? a : b) + 1);
    final newSec = section.copyWith(
      id: section.id.isEmpty ? 'sec_${DateTime.now().millisecondsSinceEpoch}' : section.id,
      displayOrder: section.displayOrder <= 0 ? nextOrder : section.displayOrder,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _sections.add(newSec);
    _notifyListeners();
    debugPrint('[HomeSectionRepository] Created section: ${newSec.title} (${newSec.slug})');
  }

  Future<void> updateSection(HomeSectionModel section) async {
    final index = _sections.indexWhere((s) => s.id == section.id);
    if (index != -1) {
      _sections[index] = section.copyWith(updatedAt: DateTime.now());
      _notifyListeners();
      debugPrint('[HomeSectionRepository] Updated section: ${section.title}');
    }
  }

  Future<void> deleteSection(String sectionId) async {
    _sections.removeWhere((s) => s.id == sectionId);
    _reindexDisplayOrders();
    _notifyListeners();
    debugPrint('[HomeSectionRepository] Deleted section: $sectionId');
  }

  Future<void> duplicateSection(String sectionId) async {
    final original = _sections.firstWhere((s) => s.id == sectionId, orElse: () => _sections.first);
    final dupId = 'sec_${DateTime.now().millisecondsSinceEpoch}';
    final dup = original.copyWith(
      id: dupId,
      title: '${original.title} (Copy)',
      slug: '${original.slug}_copy_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      displayOrder: original.displayOrder + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final insertIdx = _sections.indexWhere((s) => s.id == sectionId) + 1;
    if (insertIdx > 0 && insertIdx <= _sections.length) {
      _sections.insert(insertIdx, dup);
    } else {
      _sections.add(dup);
    }

    _reindexDisplayOrders();
    _notifyListeners();
    debugPrint('[HomeSectionRepository] Duplicated section: ${dup.title}');
  }

  Future<void> toggleSectionEnabled(String sectionId, bool isEnabled) async {
    final index = _sections.indexWhere((s) => s.id == sectionId);
    if (index != -1) {
      _sections[index] = _sections[index].copyWith(isEnabled: isEnabled, updatedAt: DateTime.now());
      _notifyListeners();
      debugPrint('[HomeSectionRepository] Toggled section $sectionId isEnabled = $isEnabled');
    }
  }

  Future<void> reorderSections(List<String> orderedIds) async {
    for (int i = 0; i < orderedIds.length; i++) {
      final id = orderedIds[i];
      final idx = _sections.indexWhere((s) => s.id == id);
      if (idx != -1) {
        _sections[idx] = _sections[idx].copyWith(displayOrder: i + 1, updatedAt: DateTime.now());
      }
    }
    _notifyListeners();
    debugPrint('[HomeSectionRepository] Reordered ${orderedIds.length} sections in realtime');
  }

  void _reindexDisplayOrders() {
    _sections.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    for (int i = 0; i < _sections.length; i++) {
      _sections[i] = _sections[i].copyWith(displayOrder: i + 1);
    }
  }
}
