import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../logging/app_logger.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String? deepLinkTargetId;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.deepLinkTargetId,
    this.isRead = false,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) {
    return AppNotification(
      id: id,
      title: map['title'] ?? 'Notification',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null 
          ? (map['timestamp'] as Timestamp).toDate() 
          : DateTime.now(),
      deepLinkTargetId: map['deepLinkTargetId'],
      isRead: map['isRead'] ?? false,
    );
  }
}

class NotificationService {
  static final Set<String> _notifyMeSubscriptions = {};
  
  // A local stream controller to broadcast notifications if needed
  static final StreamController<List<AppNotification>> _notificationsController = StreamController<List<AppNotification>>.broadcast();
  static List<AppNotification> _notifications = [];

  static Stream<List<AppNotification>> get notificationsStream => _notificationsController.stream;
  static List<AppNotification> get notifications => List.unmodifiable(_notifications);
  static int get unreadCount => _notifications.where((n) => !n.isRead).length;

  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    // Permission is requested after a user signs in. Do not block startup on a
    // system dialog or an FCM network round-trip.
    unawaited(messaging.getToken().then((token) {
      AppLogger.i('NotificationService', 'FCM token available: ${token != null}');
    }).catchError((Object error) {
      AppLogger.e('NotificationService', 'FCM token unavailable: $error');
    }));

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.i('NotificationService', 'Received Foreground Message: ${message.notification?.title}');
      if (message.notification != null) {
        final newNotification = AppNotification(
          id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: message.notification!.title ?? 'New Notification',
          message: message.notification!.body ?? '',
          timestamp: DateTime.now(),
          deepLinkTargetId: message.data['deepLinkTargetId'],
          isRead: false, // Explicitly unread for real-time foreground notifications
        );
        _notifications.insert(0, newNotification);
        _notificationsController.add(_notifications);
      }
    });

    // Handle background/terminated messages when opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.i('NotificationService', 'App opened from notification: ${message.messageId}');
      // Handle deep linking here if necessary based on message.data
    });

    // Start listening to Firestore for persistent notification history
    _listenToFirestoreNotifications();
  }

  static void _listenToFirestoreNotifications() {
    FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
      _notifications = snapshot.docs.map((doc) {
        return AppNotification.fromMap(doc.data(), doc.id);
      }).toList();
      _notificationsController.add(_notifications);
      AppLogger.i('NotificationService', 'Synced ${_notifications.length} notifications from Firestore');
    });
  }

  static void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    _notificationsController.add(_notifications);
    // Ideally we would also update this status in Firestore if notifications are user-specific.
    // For global notifications, local read state can be maintained via SharedPrefs or just in memory.
  }

  static void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((notification) => notification.id == notificationId);
    if (index < 0 || _notifications[index].isRead) return;
    final item = _notifications[index];
    item.isRead = true;
    _notificationsController.add(List.unmodifiable(_notifications));
  }

  static bool isSubscribedToNotifyMe(String contentId) {
    return _notifyMeSubscriptions.contains(contentId);
  }

  static bool toggleNotifyMe(String contentId) {
    if (_notifyMeSubscriptions.contains(contentId)) {
      _notifyMeSubscriptions.remove(contentId);
      FirebaseMessaging.instance.unsubscribeFromTopic('content_$contentId');
      AppLogger.i('NotificationService', 'Cancelled Notify Me (unsubscribed from topic): $contentId');
      return false;
    } else {
      _notifyMeSubscriptions.add(contentId);
      FirebaseMessaging.instance.subscribeToTopic('content_$contentId');
      AppLogger.i('NotificationService', 'Subscribed to Notify Me (subscribed to topic): $contentId');
      return true;
    }
  }

  // Used by trusted admin workflows; delivery is handled server-side.
  static Future<void> addNotification(String title, String message, {String? targetId}) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'deepLinkTargetId': targetId,
      'isRead': false,
    });
    AppLogger.i('NotificationService', 'Published notification to Firestore: $title');
  }
}
