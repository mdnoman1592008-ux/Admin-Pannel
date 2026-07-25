import 'package:flutter/material.dart';
import '../../core/backend/backend_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';

/// Live FCM Notifications Screen — Connected to Firestore collection 'notifications'
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _backend = LiveBackendService.instance;
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (title.isEmpty || body.isEmpty) return;

    setState(() => _sending = true);

    await _backend.sendNotification(LiveNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      target: 'all',
      recipientCount: 1,
      sentAt: DateTime.now(),
    ));

    if (mounted) {
      setState(() {
        _sending = false;
        _titleCtrl.clear();
        _bodyCtrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _backend,
      builder: (context, _) {
        final notifications = _backend.notifications;

        return Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildComposer()),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: _buildHistory(notifications)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComposer() {
    return GlassCard(
      glowColor: AppColors.secondary,
      glowBlur: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_rounded,
                  color: AppColors.secondary, size: 20),
              const SizedBox(width: 10),
              Text('Send Live FCM Push', style: AppTextStyles.h3()),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleCtrl,
            style: AppTextStyles.body().copyWith(fontSize: 14),
            decoration: const InputDecoration(hintText: 'Push Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyCtrl,
            maxLines: 4,
            style: AppTextStyles.body().copyWith(fontSize: 14),
            decoration: const InputDecoration(hintText: 'Push Message Body'),
          ),
          const SizedBox(height: 20),
          GlowButton(
            label: _sending ? 'Queueing...' : 'Queue Push Delivery',
            icon: Icons.send_rounded,
            color: AppColors.secondary,
            textColor: Colors.white,
            fullWidth: true,
            isLoading: _sending,
            onPressed: _sendNotification,
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(List<LiveNotification> notifications) {
    if (notifications.isEmpty) {
      return GlassCard(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications_off_rounded,
                  color: AppColors.textMuted, size: 48),
              const SizedBox(height: 16),
              Text('No push requests in Firestore collection "notifications"',
                  style: AppTextStyles.h3()),
              const SizedBox(height: 8),
              Text('Queue a notification; the secure server worker delivers it.',
                  style: AppTextStyles.bodySm()),
            ],
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Push Notification History', style: AppTextStyles.h3()),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) =>
                  Container(height: 1, color: AppColors.glassBorder),
              itemBuilder: (_, i) {
                final n = notifications[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_rounded,
                            color: AppColors.secondary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.title, style: AppTextStyles.h4()),
                            Text(n.body, style: AppTextStyles.bodySm()),
                          ],
                        ),
                      ),
                      Text('${n.recipientCount} delivered',
                          style: AppTextStyles.monoSm()),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
