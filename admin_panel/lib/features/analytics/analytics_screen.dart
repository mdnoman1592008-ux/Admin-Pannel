import 'package:flutter/material.dart';
import '../../core/backend/backend_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';

/// Live Analytics Screen — Realtime Telemetry from Firestore
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _backend = LiveBackendService.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _backend,
      builder: (context, _) {
        final movies = _backend.movies;
        final series = _backend.series;

        return Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildMainChart(movies)),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: _buildTopContent(movies, series)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Text('Live Telemetry & Realtime Analytics', style: AppTextStyles.h3()),
        ],
      ),
    );
  }

  Widget _buildMainChart(List<LiveMovie> movies) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Content Ingestion Growth', style: AppTextStyles.h3()),
          const SizedBox(height: 6),
          Text('Live records in collection "movies"', style: AppTextStyles.bodySm()),
          const SizedBox(height: 24),
          Expanded(
            child: movies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.analytics_outlined, color: AppColors.textMuted, size: 48),
                        const SizedBox(height: 12),
                        Text('No analytics telemetry records available', style: AppTextStyles.h3()),
                        const SizedBox(height: 4),
                        Text('Add records to Firestore "movies" collection to populate telemetry.',
                            style: AppTextStyles.bodySm()),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final m = movies[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Text(m.title, style: AppTextStyles.tableCell()),
                            const Spacer(),
                            Text('${m.views} views', style: AppTextStyles.monoSm()),
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

  Widget _buildTopContent(List<LiveMovie> movies, List<LiveSeries> series) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Database Stats', style: AppTextStyles.h3()),
          const SizedBox(height: 16),
          _StatRow('Movies Record Count', '${movies.length}', AppColors.primary),
          const SizedBox(height: 12),
          _StatRow('Series Record Count', '${series.length}', AppColors.secondary),
          const SizedBox(height: 12),
          _StatRow('Audit Log Count', '${_backend.auditLogs.length}', AppColors.gold),
          const SizedBox(height: 12),
          _StatRow('Push Notification History', '${_backend.notifications.length}', AppColors.accent),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.val, this.color);
  final String label, val;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppTextStyles.bodySm())),
        Text(val, style: AppTextStyles.h4().copyWith(color: color)),
      ],
    );
  }
}
