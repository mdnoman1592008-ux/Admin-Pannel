import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/profiles/profile_service.dart';
import 'package:ether_cinema/core/notifications/notification_service.dart';

void main() {
  group('Commercial Production v6.0 Test Suite', () {
    test('ProfileService should allow profile switching', () {
      expect(ProfileService.activeProfile.name, 'Alexander Vance');
      ProfileService.switchProfile('p2');
      expect(ProfileService.activeProfile.name, 'Cyber Kids');
      expect(ProfileService.activeProfile.isKids, true);
    });

    test('NotificationService should manage unread counts and push notifications', () {
      final initialUnread = NotificationService.unreadCount;
      NotificationService.addNotification('New Release', 'Cyberpunk Episode 5 is live!');
      expect(NotificationService.unreadCount, initialUnread + 1);

      NotificationService.markAllAsRead();
      expect(NotificationService.unreadCount, 0);
    });
  });
}
