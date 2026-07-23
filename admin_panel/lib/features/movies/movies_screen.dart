import 'package:flutter/material.dart';
import '../../core/backend/backend_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';
import '../../core/widgets/status_badge.dart';

import '../content_wizard/content_wizard_dialog.dart';
import '../analytics/movie_analytics_dialog.dart';

/// Live Movies DataGrid Screen
/// Connected to live Firestore collection 'movies'
class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final _backend = LiveBackendService.instance;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _backend,
      builder: (context, _) {
        final movies = _backend.movies
            .where((m) => m.title.toLowerCase().contains(_search.toLowerCase()))
            .toList();

        return Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildToolbar(),
              const SizedBox(height: 16),
              Expanded(child: _buildDataGrid(movies)),
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
                hintText: 'Search movies in Firestore...',
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
            label: 'Launch 7-Step Content Wizard',
            icon: Icons.auto_awesome_rounded,
            color: AppColors.primary,
            isSmall: true,
            onPressed: _showAddMovieDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildDataGrid(List<LiveMovie> movies) {
    if (movies.isEmpty) {
      return GlassCard(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.movie_filter_rounded,
                  color: AppColors.textMuted, size: 48),
              const SizedBox(height: 16),
              Text('No data available in Firestore collection "movies"',
                  style: AppTextStyles.h3()),
              const SizedBox(height: 8),
              Text('Launch the 7-step wizard to populate live records.',
                  style: AppTextStyles.bodySm()),
              const SizedBox(height: 20),
              GlowButton(
                label: 'Launch 7-Step Content Wizard',
                icon: Icons.auto_awesome_rounded,
                color: AppColors.primary,
                isSmall: true,
                onPressed: _showAddMovieDialog,
              ),
            ],
          ),
        ),
      );
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildTableHeader(),
          Container(height: 1, color: AppColors.glassBorder),
          Expanded(
            child: ListView.separated(
              itemCount: movies.length,
              separatorBuilder: (_, __) =>
                  Container(height: 1, color: AppColors.glassBorder.withOpacity(0.5)),
              itemBuilder: (_, i) => _buildMovieRow(movies[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 52),
          Expanded(flex: 3, child: Text('TITLE', style: AppTextStyles.tableHeader())),
          Expanded(flex: 2, child: Text('CATEGORY', style: AppTextStyles.tableHeader())),
          Expanded(flex: 1, child: Text('STATUS', style: AppTextStyles.tableHeader())),
          Expanded(flex: 1, child: Text('VIEWS', style: AppTextStyles.tableHeader())),
          Expanded(flex: 1, child: Text('PUBLISHED', style: AppTextStyles.tableHeader())),
          SizedBox(width: 90, child: Text('ANALYTICS', style: AppTextStyles.tableHeader())),
        ],
      ),
    );
  }

  Widget _buildMovieRow(LiveMovie movie) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.movie_rounded, color: Colors.black, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.title,
                    style: AppTextStyles.tableCell().copyWith(fontWeight: FontWeight.w600)),
                Text(movie.year, style: AppTextStyles.bodySm()),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: StatusBadge(label: movie.category, color: AppColors.secondary),
          ),
          Expanded(
            flex: 1,
            child: movie.isPublished ? StatusBadge.published() : StatusBadge.draft(),
          ),
          Expanded(
            flex: 1,
            child: Text('${movie.views}', style: AppTextStyles.tableCell()),
          ),
          Expanded(
            flex: 1,
            child: Switch(
              value: movie.isPublished,
              onChanged: (_) {},
              activeColor: AppColors.primary,
            ),
          ),
          SizedBox(
            width: 90,
            child: IconButton(
              icon: const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 18),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => MovieAnalyticsDialog(movie: movie),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMovieDialog() {
    showDialog(
      context: context,
      builder: (context) => const ContentWizardDialog(),
    );
  }
}
