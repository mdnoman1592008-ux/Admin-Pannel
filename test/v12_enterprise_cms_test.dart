import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/cms/cms_repository.dart';

void main() {
  group('Ether Cinema v12.0 Enterprise Backend CMS Test Suite', () {
    final cmsRepo = CmsRepository();

    test('CmsRepository should enforce 4-tier RBAC permission gates', () {
      expect(cmsRepo.canManageContent(ExtendedUserRole.user), false);
      expect(cmsRepo.canManageContent(ExtendedUserRole.moderator), true);
      expect(cmsRepo.canManageContent(ExtendedUserRole.admin), true);
      expect(cmsRepo.canManageContent(ExtendedUserRole.superAdmin), true);

      expect(cmsRepo.canAccessFullCms(ExtendedUserRole.moderator), false);
      expect(cmsRepo.canAccessFullCms(ExtendedUserRole.admin), true);
      expect(cmsRepo.canAccessFullCms(ExtendedUserRole.superAdmin), true);
    });

    test('Movie publication should add item and trigger audit log entry', () {
      final initialCount = cmsRepo.movies.length;
      final newItem = CmsMovieItem(
        id: 'm3',
        title: 'Quantum Abyss 4K',
        synopsis: 'Underwater quantum exploration.',
        dailymotionVideoId: 'x8m00bc',
        isPublished: true,
        releaseDate: DateTime.now(),
        genres: const ['Sci-Fi', 'Documentary'],
      );

      cmsRepo.publishMovie(newItem, 'admin@ethercinema.com');
      expect(cmsRepo.movies.length, initialCount + 1);
      expect(CmsAuditLogger.logs.first.contains('PUBLISH_MOVIE'), true);
    });
  });
}
