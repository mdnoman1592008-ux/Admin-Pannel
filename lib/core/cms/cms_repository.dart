import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/auth_repository.dart';
import '../models/banner_item.dart';
import '../models/category_item.dart';
import '../../models/movie.dart';
import '../../models/episode.dart';
import '../../models/streaming_source.dart';

enum ExtendedUserRole {
  user,
  moderator,
  admin,
  superAdmin,
}

class CmsMovieItem {
  final String id;
  final String title;
  final String synopsis;
  final String dailymotionVideoId;
  final bool isPublished;
  final DateTime releaseDate;
  final List<String> genres;
  final bool isSeries;
  final int position;
  final List<Episode> episodes;
  final String posterUrl;
  final String bannerUrl;
  final String sourceProvider;
  final String sourceUrl;

  const CmsMovieItem({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.dailymotionVideoId,
    required this.isPublished,
    required this.releaseDate,
    required this.genres,
    this.isSeries = false,
    this.position = 1,
    this.episodes = const [],
    this.posterUrl = '',
    this.bannerUrl = '',
    this.sourceProvider = '',
    this.sourceUrl = '',
  });

  factory CmsMovieItem.fromMap(String docId, Map<String, dynamic> map) {
    DateTime parsedDate = DateTime.now();
    if (map['releaseDate'] != null) {
      if (map['releaseDate'] is Timestamp) {
        parsedDate = (map['releaseDate'] as Timestamp).toDate();
      } else if (map['releaseDate'] is String) {
        parsedDate = DateTime.tryParse(map['releaseDate']) ?? DateTime.now();
      }
    }

    return CmsMovieItem(
      id: docId,
      title: map['title'] as String? ?? 'Untitled',
      synopsis: map['synopsis'] as String? ?? '',
      dailymotionVideoId: map['dailymotionVideoId'] as String? ?? '',
      isPublished: map['isPublished'] as bool? ?? false,
      releaseDate: parsedDate,
      genres: List<String>.from(map['genres'] ?? []),
      isSeries: map['isSeries'] as bool? ?? map['contentType'] == 'series',
      position: map['position'] as int? ?? 1,
      episodes: (map['episodes'] as List<dynamic>? ?? []).map((e) {
        return Episode.fromMap(e as Map<String, dynamic>,
            e['id'] ?? 'ep_${DateTime.now().millisecondsSinceEpoch}');
      }).toList(),
      posterUrl: map['posterUrl'] as String? ?? '',
      bannerUrl: map['bannerUrl'] as String? ?? '',
      sourceProvider: map['sourceProvider'] as String? ?? '',
      sourceUrl: map['sourceUrl'] as String? ?? map['dailymotionVideoId'] as String? ?? '',
    );
  }

  CmsMovieItem copyWith({int? position, bool? isPublished}) {
    return CmsMovieItem(
      id: id,
      title: title,
      synopsis: synopsis,
      dailymotionVideoId: dailymotionVideoId,
      isPublished: isPublished ?? this.isPublished,
      releaseDate: releaseDate,
      genres: genres,
      isSeries: isSeries,
      position: position ?? this.position,
      episodes: episodes,
      posterUrl: posterUrl,
      bannerUrl: bannerUrl,
      sourceProvider: sourceProvider,
      sourceUrl: sourceUrl,
    );
  }
}

class CmsAuditLogger {
  static final List<String> _logs = [];

  static List<String> get logs => List.unmodifiable(_logs);

  static void logAction(String actor, String action, String target) {
    final entry =
        '[${DateTime.now().toIso8601String().substring(11, 19)}] $actor -> $action on $target';
    _logs.insert(0, entry);
    debugPrint('[CmsAuditLogger] $entry');
  }
}

class CmsRepository {
  static final CmsRepository _instance = CmsRepository._internal();
  factory CmsRepository() => _instance;
  CmsRepository._internal();

  final List<CmsMovieItem> _movies = [];

  final List<BannerItem> _banners = [];

  final List<CategoryItem> _categories = [];

  List<CmsMovieItem> get movies {
    final list = List<CmsMovieItem>.from(_movies);
    list.sort((a, b) => a.position.compareTo(b.position));
    return List.unmodifiable(list);
  }

  List<BannerItem> get banners => List.unmodifiable(_banners);
  List<CategoryItem> get categories => List.unmodifiable(_categories);

  void setCategories(List<CategoryItem> cats) {
    _categories.clear();
    _categories.addAll(cats);
  }

  void clearCatalog() {
    _movies.clear();
    _banners.clear();
    _categories.clear();
  }

  bool canManageContent(ExtendedUserRole role) {
    return role != ExtendedUserRole.user;
  }

  bool canAccessFullCms(ExtendedUserRole role) {
    return role == ExtendedUserRole.admin ||
        role == ExtendedUserRole.superAdmin;
  }

  bool reorderPlaylist(List<String> orderedIds) {
    for (int i = 0; i < orderedIds.length; i++) {
      final id = orderedIds[i];
      final idx = _movies.indexWhere((m) => m.id == id);
      if (idx != -1) {
        _movies[idx] = _movies[idx].copyWith(position: i + 1);
      }
    }
    CmsAuditLogger.logAction(
      AuthRepository().role.name,
      'BATCH_REORDER_PLAYLIST',
      'Updated ${orderedIds.length} item positions explicitly',
    );
    return true;
  }

  bool publishMovie(CmsMovieItem item, [String? actor]) {
    final role = AuthRepository().role;
    if (role == UserRole.user && actor == null) {
      debugPrint(
          '[CmsRepository] DENIED: User lacks admin credentials to publish content');
      return false;
    }

    final index = _movies.indexWhere((m) => m.id == item.id);
    if (index >= 0) {
      _movies[index] = item;
    } else {
      _movies.add(item);
    }

    CmsAuditLogger.logAction(
      actor ?? role.name,
      'PUBLISH_MOVIE',
      item.title,
    );
    return true;
  }
}
