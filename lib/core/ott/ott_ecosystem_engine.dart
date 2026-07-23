import 'package:flutter/foundation.dart';
import '../cms/cms_repository.dart';

class ProfileModel {
  final String id;
  final String name;
  final String avatarUrl;
  final bool isKidsMode;
  final String pinCode;
  final String contentRatingRestriction;
  final List<String> favoriteMovieIds;
  final List<String> watchHistoryIds;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.isKidsMode,
    required this.pinCode,
    required this.contentRatingRestriction,
    required this.favoriteMovieIds,
    required this.watchHistoryIds,
  });

  bool canAccessMovie(CmsMovieItem movie) {
    if (isKidsMode && movie.genres.contains('18+')) return false;
    return true;
  }
}

class UniversalSearchEngine {
  static List<CmsMovieItem> search({
    required List<CmsMovieItem> catalog,
    required String query,
  }) {
    if (query.trim().isEmpty) return [];
    final cleanQuery = query.toLowerCase();
    return catalog.where((movie) {
      final titleMatch = movie.title.toLowerCase().contains(cleanQuery);
      final genreMatch = movie.genres.any((g) => g.toLowerCase().contains(cleanQuery));
      return titleMatch || genreMatch;
    }).toList();
  }
}

class SecurityAuditLogger {
  static final List<String> _securityLogs = [];

  static List<String> get securityLogs => List.unmodifiable(_securityLogs);

  static void recordLoginAttempt(String email, bool success, String ipAddress) {
    final status = success ? 'SUCCESS' : 'SUSPICIOUS_FAILURE';
    final entry = '[SECURITY] Login $status for $email from IP: $ipAddress';
    _securityLogs.insert(0, entry);
    debugPrint(entry);
  }
}
