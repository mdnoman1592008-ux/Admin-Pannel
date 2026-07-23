import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema_admin_panel/core/auth/admin_auth_service.dart';
import 'package:ether_cinema_admin_panel/core/observability/observability_service.dart';

void main() {
  group('Enterprise IAM Role & Permission Matrix Tests', () {
    test('Super Admin has full granular permissions across all modules', () {
      const role = AdminRole.superAdmin;
      expect(role.canCreateContent(), isTrue);
      expect(role.canEditContent(), isTrue);
      expect(role.canDeleteContent(), isTrue);
      expect(role.canManageUsers(), isTrue);
      expect(role.canBroadcastNotifications(), isTrue);
      expect(role.canManageRemoteConfig(), isTrue);
      expect(role.canUploadMedia(), isTrue);
      expect(role.canViewAuditLogs(), isTrue);
    });

    test('Editor can create & edit content, but cannot delete or manage users', () {
      const role = AdminRole.editor;
      expect(role.canCreateContent(), isTrue);
      expect(role.canEditContent(), isTrue);
      expect(role.canDeleteContent(), isFalse);
      expect(role.canManageUsers(), isFalse);
      expect(role.canManageRemoteConfig(), isFalse);
    });

    test('Viewer role is strictly denied administrative access', () {
      const role = AdminRole.viewer;
      expect(role.isAuthorized, isFalse);
      expect(role.canCreateContent(), isFalse);
      expect(role.canDeleteContent(), isFalse);
      expect(role.canManageUsers(), isFalse);
    });
  });

  group('Observability & Telemetry Tests', () {
    test('ObservabilityService records error logs and failed uploads correctly', () {
      final obs = ObservabilityService.instance;

      obs.recordError(
        source: 'Firestore',
        message: 'Timeout connecting to collection movies',
      );

      expect(obs.errorLogs, isNotEmpty);
      expect(obs.errorLogs.first.source, equals('Firestore'));

      obs.recordFailedUpload('poster_101.jpg', 'Bucket access denied');
      expect(obs.failedUploadCount, equals(1));
    });
  });
}
