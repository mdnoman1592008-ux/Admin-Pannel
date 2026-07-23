import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema_admin_panel/core/operations/content_lifecycle_service.dart';
import 'package:ether_cinema_admin_panel/core/operations/media_validation_service.dart';
import 'package:ether_cinema_admin_panel/core/operations/backup_export_service.dart';

void main() {
  group('Content Lifecycle & Version History Tests', () {
    test('Records version history and changed fields accurately', () {
      final service = ContentLifecycleService.instance;

      service.recordVersion(
        resourceId: 'm_movie_101',
        editorUid: 'u_admin_01',
        editorEmail: 'admin@ethercinema.app',
        changedFields: ['title', 'isPublished'],
        snapshotData: {'title': 'Nebula Drift 4K', 'isPublished': true},
      );

      final history = service.getVersionHistory('m_movie_101');
      expect(history, isNotEmpty);
      expect(history.first.versionNumber, equals(1));
      expect(history.first.changedFields, contains('title'));
      expect(history.first.editorEmail, equals('admin@ethercinema.app'));
    });

    test('Schedules future publication task in UTC timezone', () {
      final service = ContentLifecycleService.instance;
      final futureUtc = DateTime.now().toUtc().add(const Duration(hours: 24));

      service.schedulePublish(
        resourceType: 'movie',
        resourceId: 'm_movie_102',
        scheduledTimeUtc: futureUtc,
        adminEmail: 'owner@ethercinema.app',
      );

      expect(service.scheduledTasks, isNotEmpty);
      expect(service.scheduledTasks.last.resourceId, equals('m_movie_102'));
    });
  });

  group('Pre-Flight Media Validation Tests', () {
    test('Validates poster size limits and image formats', () {
      final validBytes = List<int>.filled(100, 0);
      final validRes = MediaValidationService.validatePoster(
        bytes: validBytes,
        fileName: 'poster.jpg',
      );

      expect(validRes.isValid, isTrue);

      final invalidRes = MediaValidationService.validatePoster(
        bytes: validBytes,
        fileName: 'poster.exe',
      );

      expect(invalidRes.isValid, isFalse);
      expect(invalidRes.errorMessage, contains('Unsupported image extension'));
    });

    test('Validates WebVTT and SubRip subtitle formats', () {
      final validSub = MediaValidationService.validateSubtitle(
        fileName: 'subtitles_en.vtt',
        bytes: List<int>.filled(50, 0),
      );

      expect(validSub.isValid, isTrue);

      final invalidSub = MediaValidationService.validateSubtitle(
        fileName: 'subtitles.txt',
        bytes: List<int>.filled(50, 0),
      );

      expect(invalidSub.isValid, isFalse);
      expect(invalidSub.errorMessage, contains('Only WebVTT (.vtt) and SubRip (.srt)'));
    });
  });

  group('Data Backup & Export Tests', () {
    test('Generates valid formatted JSON metadata snapshot', () {
      final jsonOutput = BackupExportService.exportMetadataJson();
      expect(jsonOutput, contains('"platform": "Ether Cinema Enterprise Admin Console"'));
      expect(jsonOutput, contains('"collections"'));
    });
  });
}
