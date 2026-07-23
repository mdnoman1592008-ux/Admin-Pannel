import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';

/// Analytics Screen — Interactive charts and performance insights
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildMainChart()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildRightColumn()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text('Analytics Overview', style: AppTextStyles.h3()),
          const Spacer(),
          TabBar(
            controller: _tab,
            isScrollable: true,
            indicator: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: AppTextStyles.badge().copyWith(
                fontSize: 12, fontWeight: FontWeight.w700),
            labelColor: AppColors.primary,
            unselectedLabelStyle: AppTextStyles.badge().copyWith(fontSize: 12),
            unselectedLabelColor: AppColors.textSecond,
            dividerColor: Colors.transparent,
            padding: EdgeInsets.zero,
            tabs: const [
              Tab(text: '7 Days'),
              Tab(text: '30 Days'),
              Tab(text: '90 Days'),
              Tab(text: '1 Year'),
            ],
            onTap: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildMainChart() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('User Growth', style: AppTextStyles.h3()),
              const SizedBox(width: 12),
              _LegendDot(color: AppColors.primary, label: 'New Users'),
              const SizedBox(width: 12),
              _LegendDot(color: AppColors.secondary, label: 'Active Users'),
            ],
          ),
          const SizedBox(height: 8),
          Text('Monthly user acquisition and retention',
              style: AppTextStyles.bodySm()),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: _buildBarGroups(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2000,
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: AppColors.glassBorder, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            months[v.toInt().clamp(0, 6)],
                            style: AppTextStyles.monoSm(),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text(
                        '${(v / 1000).toStringAsFixed(0)}K',
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
                maxY: 12000,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.surfaceHigh,
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      '${rod.toY.toInt()} users',
                      AppTextStyles.labelLg().copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final data = [
      [3200.0, 2800.0],
      [4100.0, 3700.0],
      [5800.0, 4900.0],
      [4600.0, 5200.0],
      [7200.0, 6100.0],
      [8900.0, 7400.0],
      [10200.0, 8800.0],
    ];

    return List.generate(data.length, (i) {
      return BarChartGroupData(
        x: i,
        groupVertically: false,
        barRods: [
          BarChartRodData(
            toY: data[i][0],
            color: AppColors.primary,
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: data[i][1],
            color: AppColors.secondary,
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
        barsSpace: 4,
      );
    });
  }

  Widget _buildRightColumn() {
    return Column(
      children: [
        Expanded(child: _buildDonutChart()),
        const SizedBox(height: 16),
        Expanded(child: _buildTopContent()),
      ],
    );
  }

  Widget _buildDonutChart() {
    final sections = [
      PieChartSectionData(
          value: 44, color: AppColors.google, title: '44%',
          radius: 55, titleStyle: AppTextStyles.badge().copyWith(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      PieChartSectionData(
          value: 31, color: AppColors.facebook, title: '31%',
          radius: 55, titleStyle: AppTextStyles.badge().copyWith(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      PieChartSectionData(
          value: 25, color: AppColors.accent, title: '25%',
          radius: 55, titleStyle: AppTextStyles.badge().copyWith(
              color: Colors.black, fontSize: 12, fontWeight: FontWeight.w700)),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Auth Providers', style: AppTextStyles.h3()),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 3,
                      centerSpaceRadius: 35,
                      pieTouchData: PieTouchData(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegendRow(color: AppColors.google, label: 'Google', pct: '44%'),
                    const SizedBox(height: 8),
                    _LegendRow(color: AppColors.facebook, label: 'Facebook', pct: '31%'),
                    const SizedBox(height: 8),
                    _LegendRow(color: AppColors.accent, label: 'Email', pct: '25%'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopContent() {
    final items = [
      ('Interstellar', 5100000, AppColors.primary),
      ('Breaking Bad', 4800000, AppColors.secondary),
      ('Dark Knight', 4200000, AppColors.accent),
      ('Dune Part 2', 3100000, AppColors.gold),
      ('Squid Game', 2900000, AppColors.danger),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Content', style: AppTextStyles.h3()),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.$1,
                          style: AppTextStyles.labelLg()
                              .copyWith(color: AppColors.textPrimary)),
                    ),
                    Text('${(item.$2 / 1000000).toStringAsFixed(1)}M',
                        style: AppTextStyles.badge()
                            .copyWith(color: item.$3, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 5),
                Stack(
                  children: [
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.glassBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: (item.$2 / 5100000).clamp(0.0, 1.0),
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: item.$3,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [BoxShadow(color: item.$3.withOpacity(0.4), blurRadius: 4)],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.labelLg()),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label, required this.pct});
  final Color color;
  final String label, pct;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 7),
        Text(label, style: AppTextStyles.labelLg()),
        const SizedBox(width: 8),
        Text(pct,
            style: AppTextStyles.badge()
                .copyWith(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
