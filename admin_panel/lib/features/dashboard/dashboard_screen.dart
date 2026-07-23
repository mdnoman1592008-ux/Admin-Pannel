import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/kpi_card.dart';

/// Dashboard Screen — World-Class Ether Cinema Admin Panel
/// Hero greeting, KPI cards, system status, live area chart
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _greetCtrl;
  late Animation<double> _greetFade;
  late Animation<Offset> _greetSlide;

  final _kpis = [
    _KpiData('Total Movies', '1,248', Icons.movie_filter_rounded,
        AppColors.primary, '+12%', true, 'Last 30 days'),
    _KpiData('TV Series', '384', Icons.live_tv_rounded, AppColors.secondary,
        '+8%', true, 'Last 30 days'),
    _KpiData('Registered Users', '94,721', Icons.people_alt_rounded,
        AppColors.accent, '+24%', true, 'New this month'),
    _KpiData('Active Streams', '3,849', Icons.play_circle_rounded,
        AppColors.gold, '+6%', true, 'Right now'),
    _KpiData('Storage Used', '847 GB', Icons.cloud_rounded,
        AppColors.warning, '73%', false, 'Of 1.2 TB plan'),
    _KpiData('Revenue Ready', '\$0', Icons.attach_money_rounded,
        AppColors.success, 'Future', false, 'Monetization ready'),
  ];

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
    _greetSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _greetCtrl, curve: Curves.easeOutCubic),
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
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroGreeting(),
            const SizedBox(height: 28),
            _buildKpiGrid(),
            const SizedBox(height: 24),
            _buildBottomRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroGreeting() {
    return FadeTransition(
      opacity: _greetFade,
      child: SlideTransition(
        position: _greetSlide,
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
                              Text('Ether Cinema v16.0',
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
                      'Your platform is running perfectly. 94,721 users are enjoying Ether Cinema.',
                      style: AppTextStyles.bodyLg().copyWith(
                          color: AppColors.textSecond),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _QuickActionButton(
                          label: 'Add Movie',
                          icon: Icons.add_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        _QuickActionButton(
                          label: 'Push Notification',
                          icon: Icons.notifications_active_rounded,
                          color: AppColors.secondary,
                          outlined: true,
                        ),
                        const SizedBox(width: 10),
                        _QuickActionButton(
                          label: 'View Analytics',
                          icon: Icons.bar_chart_rounded,
                          color: AppColors.accent,
                          outlined: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              _buildTodayOverview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayOverview() {
    return GlassCard(
      width: 220,
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      backgroundColor: AppColors.surface.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Overview",
              style: AppTextStyles.h4().copyWith(fontSize: 12)),
          const SizedBox(height: 16),
          _OverviewItem(
              label: 'New Users', value: '+428', color: AppColors.success),
          _OverviewItem(
              label: 'New Content', value: '7', color: AppColors.primary),
          _OverviewItem(
              label: 'Reports', value: '2', color: AppColors.warning),
          _OverviewItem(
              label: 'Peak Streams', value: '8.2K', color: AppColors.accent),
        ],
      ),
    );
  }

  Widget _buildKpiGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 1200
            ? 6
            : constraints.maxWidth > 900
                ? 4
                : constraints.maxWidth > 600
                    ? 3
                    : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            childAspectRatio: 1.1,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: _kpis.length,
          itemBuilder: (_, i) {
            final k = _kpis[i];
            return KpiCard(
              label: k.label,
              value: k.value,
              icon: k.icon,
              accentColor: k.color,
              trend: k.trend,
              trendPositive: k.trendPositive,
              subtitle: k.subtitle,
            );
          },
        );
      },
    );
  }

  Widget _buildBottomRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildAreaChart()),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildSystemStatus()),
      ],
    );
  }

  Widget _buildAreaChart() {
    final spots = [
      const FlSpot(0, 600),
      const FlSpot(1, 980),
      const FlSpot(2, 870),
      const FlSpot(3, 1200),
      const FlSpot(4, 1050),
      const FlSpot(5, 1480),
      const FlSpot(6, 1620),
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Weekly Active Streams', style: AppTextStyles.h3()),
              const Spacer(),
              _ChartLegendDot(color: AppColors.primary, label: 'Streams'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: 400,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.glassBorder,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text(
                        '${(v / 1000).toStringAsFixed(1)}K',
                        style: AppTextStyles.monoSm(),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Text(
                        days[v.toInt().clamp(0, 6)],
                        style: AppTextStyles.monoSm(),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 2000,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.4,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.25),
                          AppColors.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: AppColors.background,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Health', style: AppTextStyles.h3()),
          const SizedBox(height: 6),
          Text('Live infrastructure status',
              style: AppTextStyles.bodySm()),
          const SizedBox(height: 20),
          _StatusRow(
            name: 'Firebase Auth',
            icon: Icons.lock_rounded,
            color: AppColors.success,
            latency: '12ms',
          ),
          const SizedBox(height: 10),
          _StatusRow(
            name: 'Cloud Firestore',
            icon: Icons.storage_rounded,
            color: AppColors.success,
            latency: '28ms',
          ),
          const SizedBox(height: 10),
          _StatusRow(
            name: 'Supabase Storage',
            icon: Icons.cloud_upload_rounded,
            color: AppColors.success,
            latency: '45ms',
          ),
          const SizedBox(height: 10),
          _StatusRow(
            name: 'FCM Push',
            icon: Icons.notifications_rounded,
            color: AppColors.success,
            latency: '18ms',
          ),
          const SizedBox(height: 10),
          _StatusRow(
            name: 'CDN Network',
            icon: Icons.router_rounded,
            color: AppColors.warning,
            latency: '110ms',
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.2)),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      boxShadow: [AppColors.glowMint(blur: 8, opacity: 0.9)],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('All Systems Operational',
                      style: AppTextStyles.h4().copyWith(
                          color: AppColors.success, fontSize: 13)),
                ],
              ),
            ),
          ),
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

class _KpiData {
  const _KpiData(this.label, this.value, this.icon, this.color, this.trend,
      this.trendPositive, this.subtitle);
  final String label, value, trend, subtitle;
  final IconData icon;
  final Color color;
  final bool trendPositive;
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.outlined = false,
  });
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: outlined ? null : LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          color: outlined ? color.withOpacity(0.08) : null,
          borderRadius: BorderRadius.circular(11),
          border: outlined ? Border.all(color: color.withOpacity(0.4)) : null,
          boxShadow: outlined ? null : [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 16, spreadRadius: -4),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: outlined ? color : Colors.black),
            const SizedBox(width: 6),
            Text(label,
                style: AppTextStyles.h4().copyWith(
                    fontSize: 12,
                    color: outlined ? color : Colors.black)),
          ],
        ),
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  const _OverviewItem(
      {required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: AppTextStyles.labelLg()
                      .copyWith(color: AppColors.textSecond))),
          Text(value,
              style: AppTextStyles.h4().copyWith(color: color, fontSize: 13)),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.name,
    required this.icon,
    required this.color,
    required this.latency,
  });
  final String name, latency;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(name, style: AppTextStyles.labelLg())),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 6)],
          ),
        ),
        const SizedBox(width: 6),
        Text(latency,
            style: AppTextStyles.monoSm()
                .copyWith(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ChartLegendDot extends StatelessWidget {
  const _ChartLegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.labelLg()),
      ],
    );
  }
}
