import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';
import '../../core/widgets/status_badge.dart';

/// Series Screen — TV Series & Episode Management
class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  int? _expandedIndex;
  String _search = '';

  final _series = [
    _Series('Stranger Things', 'Sci-Fi/Horror', 4, 34, 'published', true, '8.7M'),
    _Series('Breaking Bad', 'Drama', 5, 62, 'published', true, '12.4M'),
    _Series('The Crown', 'Drama', 6, 60, 'published', false, '5.2M'),
    _Series('Wednesday', 'Comedy/Horror', 2, 16, 'published', true, '7.8M'),
    _Series('Squid Game', 'Thriller', 2, 17, 'published', true, '10.1M'),
    _Series('Arcane', 'Animation', 2, 18, 'draft', false, '3.4M'),
    _Series('The Last of Us', 'Drama', 2, 17, 'published', true, '6.9M'),
    _Series('House of Dragon', 'Fantasy', 2, 18, 'published', false, '5.8M'),
  ];

  List<_Series> get _filtered => _series
      .where((s) => s.title.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildToolbar(),
          const SizedBox(height: 16),
          Expanded(child: _buildSeriesList()),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 280,
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: AppTextStyles.body().copyWith(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search series...',
                hintStyle: AppTextStyles.body()
                    .copyWith(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 16, color: AppColors.textMuted),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              ),
            ),
          ),
          const Spacer(),
          GlowButton(
            label: 'Add Series',
            icon: Icons.add_rounded,
            color: AppColors.secondary,
            textColor: Colors.white,
            isSmall: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSeriesList() {
    final filtered = _filtered;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        itemCount: filtered.length,
        separatorBuilder: (_, __) =>
            Container(height: 1, color: AppColors.glassBorder.withOpacity(0.5)),
        itemBuilder: (_, i) => _buildSeriesRow(filtered[i], i),
      ),
    );
  }

  Widget _buildSeriesRow(_Series series, int index) {
    final isExpanded = _expandedIndex == index;

    return Column(
      children: [
        GestureDetector(
          onTap: () =>
              setState(() => _expandedIndex = isExpanded ? null : index),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: isExpanded
                  ? AppColors.secondary.withOpacity(0.07)
                  : Colors.transparent,
              child: Row(
                children: [
                  // Poster
                  Container(
                    width: 44,
                    height: 62,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(Icons.live_tv_rounded,
                        color: AppColors.textMuted, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(series.title,
                            style: AppTextStyles.h4()),
                        const SizedBox(height: 3),
                        Text(series.genre,
                            style: AppTextStyles.bodySm()),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('${series.seasons}',
                            style: AppTextStyles.h3().copyWith(
                                color: AppColors.secondary)),
                        Text('Seasons',
                            style: AppTextStyles.bodySm()),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('${series.episodes}',
                            style: AppTextStyles.h3().copyWith(
                                color: AppColors.primary)),
                        Text('Episodes',
                            style: AppTextStyles.bodySm()),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(series.views,
                        style: AppTextStyles.tableCell()
                            .copyWith(color: AppColors.textSecond)),
                  ),
                  Expanded(
                    flex: 1,
                    child: series.status == 'published'
                        ? StatusBadge.published()
                        : StatusBadge.draft(),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecond,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildEpisodeExpansion(series),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }

  Widget _buildEpisodeExpansion(_Series series) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Season Overview',
                  style: AppTextStyles.h4().copyWith(
                      color: AppColors.secondary)),
              const Spacer(),
              GlowButton(
                label: 'Add Episode',
                icon: Icons.add_rounded,
                color: AppColors.secondary,
                textColor: Colors.white,
                isSmall: true,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(series.seasons.clamp(1, 3), (si) {
            final epPerSeason = (series.episodes / series.seasons).ceil();
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.glass,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('S${si + 1}',
                          style: AppTextStyles.badge().copyWith(
                              color: AppColors.secondary, fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Season ${si + 1}',
                      style: AppTextStyles.h4().copyWith(fontSize: 13)),
                  const SizedBox(width: 16),
                  Text('$epPerSeason Episodes',
                      style: AppTextStyles.bodySm()),
                  const Spacer(),
                  StatusBadge.published(),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Series {
  const _Series(this.title, this.genre, this.seasons, this.episodes,
      this.status, this.isFeatured, this.views);
  final String title, genre, status, views;
  final int seasons, episodes;
  final bool isFeatured;
}
