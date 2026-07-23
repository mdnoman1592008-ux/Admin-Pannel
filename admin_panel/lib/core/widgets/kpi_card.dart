import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

/// KPI Metric Card — Ether Cinema Admin Panel
/// Animated number counter, trend indicator, glow accent
class KpiCard extends StatefulWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.trend,
    this.trendPositive = true,
    this.subtitle,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String? trend;
  final bool trendPositive;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  State<KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<KpiCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
            .animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GlassCard(
          hoverable: true,
          glowColor: widget.accentColor,
          glowBlur: 32,
          borderColor: widget.accentColor.withOpacity(0.18),
          onTap: widget.onTap,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon container with glow
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withOpacity(0.25),
                          blurRadius: 16,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(widget.icon,
                        color: widget.accentColor, size: 20),
                  ),
                  const Spacer(),
                  if (widget.trend != null)
                    _TrendChip(
                      trend: widget.trend!,
                      positive: widget.trendPositive,
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(widget.value, style: AppTextStyles.kpiValue()),
              const SizedBox(height: 5),
              Text(widget.label, style: AppTextStyles.kpiLabel()),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(widget.subtitle!,
                    style: AppTextStyles.bodySm().copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    )),
              ],
              const SizedBox(height: 14),
              // Accent bottom line
              Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.accentColor.withOpacity(0.7),
                      widget.accentColor.withOpacity(0.0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.trend, required this.positive});
  final String trend;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final c = positive ? AppColors.success : AppColors.danger;
    final icon = positive ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: c, size: 12),
          const SizedBox(width: 3),
          Text(trend,
              style: AppTextStyles.badge().copyWith(
                  color: c, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Status dot indicator
class StatusDot extends StatefulWidget {
  const StatusDot({super.key, required this.status, this.size = 8});
  final SystemStatus status;
  final double size;

  @override
  State<StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Color get _color {
    switch (widget.status) {
      case SystemStatus.operational:
        return AppColors.success;
      case SystemStatus.degraded:
        return AppColors.warning;
      case SystemStatus.down:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _color.withOpacity(0.3 + _pulse.value * 0.4),
              blurRadius: 8 + _pulse.value * 6,
              spreadRadius: 0,
            ),
          ],
        ),
      ),
    );
  }
}

enum SystemStatus { operational, degraded, down }

/// System service status card
class ServiceStatusCard extends StatelessWidget {
  const ServiceStatusCard({
    super.key,
    required this.name,
    required this.status,
    required this.icon,
    required this.latency,
  });

  final String name;
  final SystemStatus status;
  final IconData icon;
  final String latency;

  String get _statusText {
    switch (status) {
      case SystemStatus.operational:
        return 'Operational';
      case SystemStatus.degraded:
        return 'Degraded';
      case SystemStatus.down:
        return 'Down';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecond, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.h4()),
                Text(latency,
                    style: AppTextStyles.bodySm()),
              ],
            ),
          ),
          Row(
            children: [
              StatusDot(status: status),
              const SizedBox(width: 6),
              Text(_statusText,
                  style: AppTextStyles.bodySm().copyWith(
                    color: status == SystemStatus.operational
                        ? AppColors.success
                        : status == SystemStatus.degraded
                            ? AppColors.warning
                            : AppColors.danger,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
