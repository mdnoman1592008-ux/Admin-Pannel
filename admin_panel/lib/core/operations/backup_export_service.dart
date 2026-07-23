import 'dart:convert';
import '../backend/backend_service.dart';

/// Enterprise Data Backup & Export Suite
class BackupExportService {
  /// Export full Firestore metadata snapshot to formatted JSON payload
  static String exportMetadataJson() {
    final live = LiveBackendService.instance;

    final exportData = {
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'platform': 'Ether Cinema Enterprise Admin Console',
      'version': '16.0.0',
      'collections': {
        'movies': live.movies
            .map((m) => {
                  'id': m.id,
                  'title': m.title,
                  'category': m.category,
                  'views': m.views,
                  'isPublished': m.isPublished,
                  'year': m.year,
                })
            .toList(),
        'series': live.series
            .map((s) => {
                  'id': s.id,
                  'title': s.title,
                  'genre': s.genre,
                  'seasons': s.seasons,
                  'episodes': s.episodes,
                })
            .toList(),
        'audit_logs': live.auditLogs
            .map((l) => {
                  'id': l.id,
                  'severity': l.severity,
                  'title': l.title,
                  'description': l.description,
                  'timestamp': l.timestamp,
                })
            .toList(),
        'remote_config': live.remoteConfig
            .map((c) => {
                  'key': c.key,
                  'value': c.value,
                  'type': c.type,
                })
            .toList(),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }
}
