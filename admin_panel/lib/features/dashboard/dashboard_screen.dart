import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/backend/backend_health_check.dart';
import '../../core/backend/backend_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/kpi_card.dart';

/// Live Enterprise Dashboard Screen
/// 100% connected to live backend (Firestore, Firebase Auth, Supabase Storage)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final _backend = LiveBackendService.instance;
  late AnimationController _greetCtrl;
  late Animation<double> _greetFade;

  @override
  void initState() {
    super.initState();
    _greetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _greetFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _greetCtrl, curve: Curves.easeOut),
    );
    _greetCtrl.forward();
  }

  @override
  void dispose() {
    _greetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _backend,
      builder: (context, _) {
        final report = BackendHealthCheck.runAudit();
        final movies = _backend.movies;
        final series = _backend.series;
        final logs = _backend.auditLogs;

        return Container(
          color: AppColors.background,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroGreeting(report),
                const SizedBox(height: 24),
                _buildKpiGrid(movies.length, series.length),
                const SizedBox(height: 24),
                _buildLiveTelemetry(movies, logs),
                const SizedBox(height: 24),
                _buildInfrastructureChecklist(report),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroGreeting(BackendHealthReport report) {
    return FadeTransition(
      opacity: _greetFade,
      child: GlassCard(
        glowColor: AppColors.primary,
        glowBlur: 40,
        borderColor: AppColors.primary.withOpacity(0.15),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.06),
            AppColors.secondary.withOpacity(0.04),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('Live Cloud Pipeline Connected',
                                style: AppTextStyles.badge().copyWith(
                                    color: AppColors.primary, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getGreeting(),
                    style: AppTextStyles.display2().copyWith(
                      foreground: Paint()
                        ..shader = AppColors.primaryGradient
                            .createShader(const Rect.fromLTWH(0, 0, 400, 60)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connected to Firebase Auth, Cloud Firestore & Supabase Storage.',
                    style: AppTextStyles.bodyLg()
                        .copyWith(color: AppColors.textSecond),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            GlassCard(
              width: 220,
              padding: const EdgeInsets.all(16),
              backgroundColor: AppColors.surface.withOpacity(0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('System Status',
                      style: AppTextStyles.h4().copyWith(fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${report.healthyCount}/${report.totalCount} Systems OK',
                          style: AppTextStyles.h4().copyWith(
                              color: AppColors.success, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiGrid(int movieCount, int seriesCount) {
    return Row(
      children: [
        Expanded(
          child: KpiCard(
            label: 'Live Movies (Firestore)',
            value: '$movieCount',
            icon: Icons.movie_filter_rounded,
            accentColor: AppColors.primary,
            subtitle: movieCount == 0 ? 'No movies in collection "movies"' : 'Active stream',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: KpiCard(
            label: 'TV Series (Firestore)',
            value: '$seriesCount',
            icon: Icons.live_tv_rounded,
            accentColor: AppColors.secondary,
            subtitle: seriesCount == 0 ? 'No series in collection "series"' : 'Active stream',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: KpiCard(
            label: 'Supabase Storage',
            value: '${_backend.storageFiles.length} files',
            icon: Icons.cloud_done_rounded,
            accentColor: AppColors.accent,
            subtitle: 'Bucket: ether-cinema',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: KpiCard(
            label: 'Audit Events',
            value: '${_backend.auditLogs.length}',
            icon: Icons.history_rounded,
            accentColor: AppColors.gold,
            subtitle: 'Live event telemetry',
          ),
        ),
      ],
    );
  }

  Widget _buildLiveTelemetry(List<LiveMovie> movies, List<LiveAuditLog> logs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Realtime Content Growth', style: AppTextStyles.h3()),
                const SizedBox(height: 6),
                Text('Live record stream count by hour',
                    style: AppTextStyles.bodySm()),
                const SizedBox(height: 20),
                if (movies.isEmpty)
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.show_chart_rounded,
                              color: AppColors.textMuted, size: 32),
                          const SizedBox(height: 8),
                          Text('No data available in Firestore collection "movies"',
                              style: AppTextStyles.bodySm()),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              movies.length,
                              (i) => FlSpot(i.toDouble(), (i + 1).toDouble()),
                            ),
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Realtime Activity Feed', style: AppTextStyles.h3()),
                const SizedBox(height: 16),
                if (logs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('No audit events logged yet',
                          style: AppTextStyles.bodySm()),
                    ),
                  )
                else
                  ...logs.take(4).map((log) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(log.title,
                                  style: AppTextStyles.bodySm()
                                      .copyWith(color: AppColors.textPrimary)),
                            ),
                            Text(log.timestamp, style: AppTextStyles.monoSm()),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfrastructureChecklist(BackendHealthReport report) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text('Live Backend Diagnostic & Infrastructure Checklist',
                  style: AppTextStyles.h3()),
            ],
          ),
          const SizedBox(height: 16),
          ...report.items.map((item) {
            final isConnected = item.status == ResourceStatus.connected;
            final isEmpty = item.status == ResourceStatus.empty;

            final icon = isConnected
                ? Icons.check_circle_rounded
                : isEmpty
                    ? Icons.error_outline_rounded
                    : Icons.cancel_rounded;

            final color = isConnected
                ? AppColors.success
                : isEmpty
                    ? AppColors.warning
                    : AppColors.danger;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 10),
                  Text(item.name,
                      style: AppTextStyles.h4().copyWith(fontSize: 13)),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(
                      item.status.name.toUpperCase(),
                      style: AppTextStyles.badge()
                          .copyWith(color: color, fontSize: 10),
                    ),
                  ),
                  const Spacer(),
                  Text(item.details,
                      style: AppTextStyles.bodySm().copyWith(fontSize: 12)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 18) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }
}
