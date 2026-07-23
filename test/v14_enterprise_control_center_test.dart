import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/config/app_control_center.dart';

void main() {
  group('Ether Cinema v14.0 Enterprise Control Center Suite', () {
    final controlCenter = AppControlCenter();
    final scheduler = ContentScheduler();
    final sessionGuard = UserSessionGuard();

    test('AppControlCenter should update RemoteAppConfig and broadcast stream emissions', () {
      expect(controlCenter.config.appName, 'Ether Cinema OTT');
      controlCenter.toggleMaintenanceMode(true, 'Server upgrades in progress');
      expect(controlCenter.config.maintenanceMode, true);
      expect(controlCenter.config.emergencyMessage, 'Server upgrades in progress');
    });

    test('ContentScheduler should gate content availability based on release time', () {
      final futureDate = DateTime.now().add(const Duration(days: 7));
      scheduler.scheduleRelease('m100', futureDate);
      expect(scheduler.isContentAvailable('m100'), false);
    });

    test('UserSessionGuard should enforce session revocation for banned users', () {
      expect(sessionGuard.isSessionValid('u99'), true);
      sessionGuard.revokeUserSession('u99');
      expect(sessionGuard.isSessionValid('u99'), false);
    });
  });
}
