import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';

/// Audit Logs Screen — Timeline layout with severity colors
class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  String _filterSeverity = 'all';

  final _logs = [
    _Log('info', 'User Login', 'ariana@example.com signed in via Google', '2 min ago', Icons.login_rounded),
    _Log('success', 'Content Published', 'Movie "Dune Part 2" published to production', '15 min ago', Icons.check_circle_rounded),
    _Log('warning', 'High Traffic', 'CDN bandwidth exceeded 80% threshold', '1 hour ago', Icons.warning_rounded),
    _Log('info', 'Notification Sent', 'Push notification sent to 94,721 users', '2 hours ago', Icons.notifications_rounded),
    _Log('success', 'Bucket Upload', 'poster/m101/uuid.jpg uploaded to Supabase Storage', '3 hours ago', Icons.cloud_upload_rounded),
    _Log('danger', 'Auth Failure', 'Multiple failed login attempts from IP 192.168.1.100', '4 hours ago', Icons.gpp_bad_rounded),
    _Log('info', 'Category Created', 'New category "Documentary" added by admin', '5 hours ago', Icons.category_rounded),
    _Log('warning', 'Storage Warning', 'Storage bucket at 73% capacity', '6 hours ago', Icons.cloud_rounded),
    _Log('success', 'User Promoted', 'james@example.com promoted to admin role', '8 hours ago', Icons.shield_rounded),
    _Log('info', 'Config Updated', 'Remote config key "feature_4k" updated to true', '10 hours ago', Icons.tune_rounded),
    _Log('danger', 'User Suspended', 'sofia@example.com account suspended', '12 hours ago', Icons.block_rounded),
    _Log('success', 'Backup Complete', 'Firestore backup completed successfully', '1 day ago', Icons.backup_rounded),
  ];

  List<_Log> get _filtered => _filterSeverity == 'all'
      ? _logs
      : _logs.where((l) => l.severity == _filterSeverity).toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildToolbar(),
          const SizedBox(height: 16),
          Expanded(child: _buildTimeline()),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text('System Activity Log', style: AppTextStyles.h3()),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.glassBorder,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${_filtered.length} events',
                style: AppTextStyles.badge().copyWith(
                    color: AppColors.textSecond, fontSize: 11)),
          ),
          const SizedBox(width: 20),
          _SeverityFilter('all', 'All', AppColors.textSecond, _filterSeverity, (v) => setState(() => _filterSeverity = v)),
          const SizedBox(width: 6),
          _SeverityFilter('info', 'Info', AppColors.primary, _filterSeverity, (v) => setState(() => _filterSeverity = v)),
          const SizedBox(width: 6),
          _SeverityFilter('success', 'Success', AppColors.success, _filterSeverity, (v) => setState(() => _filterSeverity = v)),
          const SizedBox(width: 6),
          _SeverityFilter('warning', 'Warning', AppColors.warning, _filterSeverity, (v) => setState(() => _filterSeverity = v)),
          const SizedBox(width: 6),
          _SeverityFilter('danger', 'Danger', AppColors.danger, _filterSeverity, (v) => setState(() => _filterSeverity = v)),
          const Spacer(),
          GlowButton(
            label: 'Export CSV',
            icon: Icons.download_rounded,
            color: AppColors.accent,
            textColor: Colors.black,
            isSmall: true,
            outlined: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final filtered = _filtered;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (_, i) => _TimelineItem(
          log: filtered[i],
          isLast: i == filtered.length - 1,
        ),
      ),
    );
  }
}

class _Log {
  const _Log(this.severity, this.title, this.description, this.time, this.icon);
  final String severity, title, description, time;
  final IconData icon;
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.log, required this.isLast});
  final _Log log;
  final bool isLast;

  Color get _color {
    switch (log.severity) {
      case 'success': return AppColors.success;
      case 'warning': return AppColors.warning;
      case 'danger': return AppColors.danger;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _color.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: _color.withOpacity(0.4)),
                    boxShadow: [BoxShadow(color: _color.withOpacity(0.3), blurRadius: 8)],
                  ),
                  child: Icon(log.icon, size: 13, color: _color),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: AppColors.glassBorder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(log.title,
                          style: AppTextStyles.h4()),
                      const SizedBox(width: 10),
                      _SeverityBadge(severity: log.severity, color: _color),
                      const Spacer(),
                      Text(log.time,
                          style: AppTextStyles.bodySm()),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(log.description,
                      style: AppTextStyles.body()
                          .copyWith(color: AppColors.textSecond, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity, required this.color});
  final String severity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(severity.toUpperCase(),
          style: AppTextStyles.badge()
              .copyWith(color: color, fontSize: 9, letterSpacing: 0.8)),
    );
  }
}

class _SeverityFilter extends StatelessWidget {
  const _SeverityFilter(
      this.value, this.label, this.color, this.current, this.onTap);
  final String value, label;
  final Color color;
  final String current;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final sel = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: sel ? color.withOpacity(0.12) : AppColors.glass,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: sel ? color.withOpacity(0.4) : AppColors.glassBorder,
          ),
        ),
        child: Text(label,
            style: AppTextStyles.badge().copyWith(
                color: sel ? color : AppColors.textSecond,
                fontSize: 11,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }
}
