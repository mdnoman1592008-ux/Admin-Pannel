import 'package:flutter/foundation.dart';
import '../auth/auth_repository.dart';

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

  const CmsMovieItem({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.dailymotionVideoId,
    required this.isPublished,
    required this.releaseDate,
    required this.genres,
  });
}

class CmsAuditLogger {
  static final List<String> _logs = [
    '[08:00:12] Initialized Firebase Enterprise CMS v12.0 Engine',
    '[07:58:45] Security Rules active: Firestore RBAC 4-tier enforcement',
    '[07:55:00] Super Admin admin@ethercinema.com authorized',
  ];

  static List<String> get logs => List.unmodifiable(_logs);

  static void logAction(String actor, String action, String target) {
    final entry = '[${DateTime.now().toIso8601String().substring(11, 19)}] $actor -> $action on $target';
    _logs.insert(0, entry);
    debugPrint('[CmsAuditLogger] $entry');
  }
}

class CmsRepository {
  static final CmsRepository _instance = CmsRepository._internal();
  factory CmsRepository() => _instance;
  CmsRepository._internal();

  final List<CmsMovieItem> _movies = [
    CmsMovieItem(
      id: 'm1',
      title: 'Aetherius: The Silent Void',
      synopsis: 'A deep space odyssey into humanity\'s final frontier.',
      dailymotionVideoId: 'x8m00bc',
      isPublished: true,
      releaseDate: DateTime(2026, 1, 15),
      genres: const ['Sci-Fi', 'IMAX Shorts'],
    ),
    CmsMovieItem(
      id: 'm2',
      title: 'Neon Cyberpunk 2099',
      synopsis: 'High-octane synthwave adventure in Neo Tokyo.',
      dailymotionVideoId: 'x8lzs3e',
      isPublished: true,
      releaseDate: DateTime(2026, 3, 10),
      genres: const ['Action', 'Cyberpunk'],
    ),
  ];

  List<CmsMovieItem> get movies => List.unmodifiable(_movies);

  bool canManageContent(ExtendedUserRole role) {
    return role == ExtendedUserRole.moderator || role == ExtendedUserRole.admin || role == ExtendedUserRole.superAdmin;
  }

  bool canAccessFullCms(ExtendedUserRole role) {
    return role == ExtendedUserRole.admin || role == ExtendedUserRole.superAdmin;
  }

  Future<void> publishMovie(CmsMovieItem item, String actorEmail) async {
    _movies.add(item);
    CmsAuditLogger.logAction(actorEmail, 'PUBLISH_MOVIE', item.title);
  }

  Future<void> deleteMovie(String id, String actorEmail) async {
    _movies.removeWhere((m) => m.id == id);
    CmsAuditLogger.logAction(actorEmail, 'DELETE_MOVIE', id);
  }
}
