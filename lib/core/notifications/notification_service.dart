import '../logging/app_logger.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationService {
  static final List<AppNotification> _notifications = [
    AppNotification(
      id: 'n1',
      title: 'New Movie Released!',
      message: 'NEBULA DRIFT in IMAX 4K is now streaming.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      id: 'n2',
      title: 'System Update v6.0',
      message: 'Commercial Production Edition is active.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
  ];

  static List<AppNotification> get notifications => List.unmodifiable(_notifications);

  static int get unreadCount => _notifications.where((n) => !n.isRead).length;

  static void addNotification(String title, String message) {
    _notifications.insert(
      0,
      AppNotification(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        message: message,
        timestamp: DateTime.now(),
      ),
    );
    AppLogger.i('NotificationService', 'Published notification: $title');
  }

  static void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
  }
}
