import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';

/// Notifications Screen — FCM Push Notification Center
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _target = 'all';
  bool _sending = false;

  final _recent = [
    _Notif('🎬 New Release: Dune Part 2', 'Now available to stream in 4K HDR!', 'all', '2 hours ago', 94721),
    _Notif('⭐ Featured This Week', 'Breaking Bad complete series now featured', 'all', '1 day ago', 84300),
    _Notif('🎉 Premium Feature Unlocked', 'Download offline viewing is now available!', 'premium', '3 days ago', 12400),
    _Notif('📢 Maintenance Notice', 'Scheduled maintenance on Sunday 2AM UTC', 'all', '5 days ago', 94721),
    _Notif('🆕 New Category Added', 'Explore our new Documentary section!', 'all', '1 week ago', 94721),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _buildComposer()),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: _buildHistory()),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return GlassCard(
      glowColor: AppColors.secondary,
      glowBlur: 32,
      borderColor: AppColors.secondary.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [AppColors.glowPurple(blur: 12, opacity: 0.5)],
                ),
                child: const Icon(Icons.notifications_active_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text('Send Notification', style: AppTextStyles.h3()),
            ],
          ),
          const SizedBox(height: 24),
          Text('Title', style: AppTextStyles.labelLg()),
          const SizedBox(height: 6),
          TextField(
            controller: _titleCtrl,
            style: AppTextStyles.body().copyWith(fontSize: 14),
            decoration: const InputDecoration(
              hintText: '🎬 Notification title...',
            ),
          ),
          const SizedBox(height: 16),
          Text('Message', style: AppTextStyles.labelLg()),
          const SizedBox(height: 6),
          TextField(
            controller: _bodyCtrl,
            maxLines: 4,
            style: AppTextStyles.body().copyWith(fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Your notification message...',
            ),
          ),
          const SizedBox(height: 16),
          Text('Target Audience', style: AppTextStyles.labelLg()),
          const SizedBox(height: 8),
          Row(
            children: [
              _TargetChip(
                label: 'All Users',
                selected: _target == 'all',
                onTap: () => setState(() => _target = 'all'),
                count: '94,721',
              ),
              const SizedBox(width: 8),
              _TargetChip(
                label: 'Premium',
                selected: _target == 'premium',
                onTap: () => setState(() => _target = 'premium'),
                count: '12,400',
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Preview
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(Icons.play_circle_fill_rounded,
                          color: Colors.black, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Text('Ether Cinema', style: AppTextStyles.labelLg().copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const Spacer(),
                    Text('now', style: AppTextStyles.bodySm()),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _titleCtrl.text.isEmpty ? 'Notification Title' : _titleCtrl.text,
                  style: AppTextStyles.h4().copyWith(fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  _bodyCtrl.text.isEmpty ? 'Notification body preview...' : _bodyCtrl.text,
                  style: AppTextStyles.bodySm(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GlowButton(
            label: _sending ? 'Sending...' : 'Send Push Notification',
            icon: Icons.send_rounded,
            color: AppColors.secondary,
            textColor: Colors.white,
            fullWidth: true,
            isLoading: _sending,
            gradient: AppColors.primaryGradient,
            onPressed: () async {
              setState(() => _sending = true);
              await Future.delayed(const Duration(seconds: 2));
              setState(() => _sending = false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text('Notification History', style: AppTextStyles.h3()),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${_recent.length} sent',
                      style: AppTextStyles.badge().copyWith(
                          color: AppColors.secondary, fontSize: 11)),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.glassBorder),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _recent.length,
              separatorBuilder: (_, __) =>
                  Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 20),
                      color: AppColors.glassBorder.withOpacity(0.5)),
              itemBuilder: (_, i) => _NotifHistoryRow(notif: _recent[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Notif {
  const _Notif(this.title, this.body, this.target, this.time, this.sent);
  final String title, body, target, time;
  final int sent;
}

class _NotifHistoryRow extends StatelessWidget {
  const _NotifHistoryRow({required this.notif});
  final _Notif notif;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(notif.title, style: AppTextStyles.h4()),
                const SizedBox(height: 3),
                Text(notif.body,
                    style: AppTextStyles.bodySm(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${notif.sent.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')} delivered',
                          style: AppTextStyles.badge().copyWith(
                              color: AppColors.primary, fontSize: 10)),
                    ),
                    const SizedBox(width: 8),
                    Text(notif.time, style: AppTextStyles.bodySm()),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Sent',
                style: AppTextStyles.badge()
                    .copyWith(color: AppColors.success, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  const _TargetChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.count,
  });
  final String label, count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondary.withOpacity(0.12)
              : AppColors.glass,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? AppColors.secondary.withOpacity(0.4)
                : AppColors.glassBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.badge().copyWith(
                    color: selected
                        ? AppColors.secondary
                        : AppColors.textSecond,
                    fontSize: 12, fontWeight: FontWeight.w700)),
            Text(count, style: AppTextStyles.bodySm().copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
