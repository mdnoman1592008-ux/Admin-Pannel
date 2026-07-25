import 'package:flutter/material.dart';

import '../../core/notifications/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _relativeTime(DateTime value) {
    final difference = DateTime.now().difference(value);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${value.day}/${value.month}/${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070812),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070812),
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: NotificationService.markAllAsRead,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: NotificationService.notificationsStream,
        initialData: NotificationService.notifications,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <AppNotification>[];
          if (snapshot.connectionState == ConnectionState.waiting && items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (items.isEmpty) {
            return const _EmptyNotifications();
          }
          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return _NotificationTile(item: item, time: _relativeTime(item.timestamp));
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.time});
  final AppNotification item;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.isRead ? const Color(0xFF111426) : const Color(0xFF17223A),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => NotificationService.markAsRead(item.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isRead ? const Color(0xFF283047) : const Color(0xFF6C5CE7),
                ),
                child: Icon(
                  item.isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15))),
                        if (!item.isRead) const CircleAvatar(radius: 4, backgroundColor: Color(0xFF00CFFF)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(item.message, style: const TextStyle(color: Colors.white70, height: 1.35, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text(time, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined, color: Colors.white38, size: 58),
            SizedBox(height: 16),
            Text('No notifications yet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text('Admin updates will appear here.', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
}
