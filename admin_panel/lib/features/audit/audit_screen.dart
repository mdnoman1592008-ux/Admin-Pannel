import 'package:flutter/material.dart';
import '../../core/backend/backend_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';

/// Live Audit Logs Screen — Realtime stream from Firestore collection 'audit_logs'
class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  final _backend = LiveBackendService.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _backend,
      builder: (context, _) {
        final logs = _backend.auditLogs;

        return Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildToolbar(logs.length),
              const SizedBox(height: 16),
              Expanded(child: _buildTimeline(logs)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolbar(int count) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.history_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Text('Live Audit Events Stream', style: AppTextStyles.h3()),
          const SizedBox(width: 12),
          StatusBadge(label: '$count Events', color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<LiveAuditLog> logs) {
    if (logs.isEmpty) {
      return GlassCard(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history_toggle_off_rounded,
                  color: AppColors.textMuted, size: 48),
              const SizedBox(height: 16),
              Text('No audit events logged in Firestore collection "audit_logs"',
                  style: AppTextStyles.h3()),
              const SizedBox(height: 8),
              Text('Events will automatically populate as admin actions occur.',
                  style: AppTextStyles.bodySm()),
            ],
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (_, i) {
          final log = logs[i];
          final color = log.severity == 'success'
              ? AppColors.success
              : log.severity == 'warning'
                  ? AppColors.warning
                  : log.severity == 'danger'
                      ? AppColors.danger
                      : AppColors.primary;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.info_outline_rounded, color: color, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.title, style: AppTextStyles.h4()),
                      Text(log.description, style: AppTextStyles.bodySm()),
                    ],
                  ),
                ),
                Text(log.timestamp, style: AppTextStyles.monoSm()),
              ],
            ),
          );
        },
      ),
    );
  }
}
