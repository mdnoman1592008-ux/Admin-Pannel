import 'package:flutter/material.dart';
import '../../core/backend/backend_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';
import '../../core/widgets/status_badge.dart';

/// Live Series Screen — TV Series & Episode Management
class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  final _backend = LiveBackendService.instance;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _backend,
      builder: (context, _) {
        final series = _backend.series
            .where((s) => s.title.toLowerCase().contains(_search.toLowerCase()))
            .toList();

        return Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildToolbar(),
              const SizedBox(height: 16),
              Expanded(child: _buildSeriesList(series)),
            ],
          ),
        );
      },
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
                hintText: 'Search TV series...',
                hintStyle: AppTextStyles.body()
                    .copyWith(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 16, color: AppColors.textMuted),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              ),
            ),
          ),
          const Spacer(),
          GlowButton(
            label: 'Add Series to Firestore',
            icon: Icons.add_rounded,
            color: AppColors.secondary,
            textColor: Colors.white,
            isSmall: true,
            onPressed: _showAddSeriesDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSeriesList(List<LiveSeries> series) {
    if (series.isEmpty) {
      return GlassCard(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.live_tv_rounded, color: AppColors.textMuted, size: 48),
              const SizedBox(height: 16),
              Text('No data available in Firestore collection "series"',
                  style: AppTextStyles.h3()),
              const SizedBox(height: 8),
              Text('Click "Add Series to Firestore" to add live TV series.',
                  style: AppTextStyles.bodySm()),
              const SizedBox(height: 20),
              GlowButton(
                label: 'Add First TV Series',
                icon: Icons.add_rounded,
                color: AppColors.secondary,
                textColor: Colors.white,
                isSmall: true,
                onPressed: _showAddSeriesDialog,
              ),
            ],
          ),
        ),
      );
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        itemCount: series.length,
        separatorBuilder: (_, __) =>
            Container(height: 1, color: AppColors.glassBorder.withOpacity(0.5)),
        itemBuilder: (_, i) {
          final s = series[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: AppColors.secondaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.live_tv_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.title, style: AppTextStyles.h4()),
                      Text(s.genre, style: AppTextStyles.bodySm()),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text('${s.seasons} Seasons', style: AppTextStyles.tableCell()),
                ),
                Expanded(
                  flex: 1,
                  child: Text('${s.episodes} Episodes', style: AppTextStyles.tableCell()),
                ),
                StatusBadge.published(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddSeriesDialog() {
    final titleCtrl = TextEditingController();
    final genreCtrl = TextEditingController(text: 'Drama');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Text('Add Live TV Series to Firestore', style: AppTextStyles.h3()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(hintText: 'Series Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: genreCtrl,
              decoration: const InputDecoration(hintText: 'Genre'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          GlowButton(
            label: 'Save Series',
            icon: Icons.check_rounded,
            color: AppColors.secondary,
            textColor: Colors.white,
            isSmall: true,
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                _backend.addSeries(LiveSeries(
                  id: 's_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleCtrl.text.trim(),
                  genre: genreCtrl.text.trim(),
                  seasons: 1,
                  episodes: 10,
                  status: 'published',
                  isFeatured: true,
                  views: 0,
                  posterUrl: '',
                  createdAt: DateTime.now(),
                ));
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
