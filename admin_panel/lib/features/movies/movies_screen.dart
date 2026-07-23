import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';
import '../../core/widgets/status_badge.dart';

/// Movies Screen — Professional DataGrid with poster preview
class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  String _search = '';
  int _hoveredRow = -1;
  final Set<int> _selected = {};

  final _movies = [
    _Movie('Interstellar', 'Sci-Fi', 'published', true, false, '2.4M', '2014'),
    _Movie('The Dark Knight', 'Action', 'published', true, true, '5.1M', '2008'),
    _Movie('Inception', 'Thriller', 'published', false, true, '3.8M', '2010'),
    _Movie('Dune Part 2', 'Sci-Fi', 'published', true, true, '1.9M', '2024'),
    _Movie('Oppenheimer', 'Drama', 'published', true, false, '2.2M', '2023'),
    _Movie('Avatar 2', 'Fantasy', 'draft', false, false, '980K', '2022'),
    _Movie('Top Gun Maverick', 'Action', 'published', true, false, '3.2M', '2022'),
    _Movie('Spider-Man NWH', 'Action', 'published', true, true, '4.5M', '2021'),
    _Movie('Black Panther 2', 'Action', 'archived', false, false, '1.7M', '2022'),
    _Movie('Guardians 3', 'Sci-Fi', 'published', false, false, '2.0M', '2023'),
  ];

  List<_Movie> get _filtered => _movies
      .where((m) => m.title.toLowerCase().contains(_search.toLowerCase()))
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
          Expanded(child: _buildDataGrid()),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Search
          SizedBox(
            width: 280,
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: AppTextStyles.body().copyWith(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search movies...',
                hintStyle: AppTextStyles.body()
                    .copyWith(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded,
                    size: 16, color: AppColors.textMuted),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Filter chips
          _FilterChip(label: 'All', selected: true),
          const SizedBox(width: 8),
          _FilterChip(label: 'Published'),
          const SizedBox(width: 8),
          _FilterChip(label: 'Featured'),
          const Spacer(),
          if (_selected.isNotEmpty) ...[
            Text('${_selected.length} selected',
                style: AppTextStyles.labelLg()
                    .copyWith(color: AppColors.primary)),
            const SizedBox(width: 12),
            GlowButton(
              label: 'Delete Selected',
              icon: Icons.delete_outline_rounded,
              color: AppColors.danger,
              textColor: Colors.white,
              isSmall: true,
              onPressed: () => setState(() => _selected.clear()),
            ),
            const SizedBox(width: 8),
          ],
          GlowButton(
            label: 'Add Movie',
            icon: Icons.add_rounded,
            color: AppColors.primary,
            isSmall: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDataGrid() {
    final filtered = _filtered;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildTableHeader(),
          Container(height: 1, color: AppColors.glassBorder),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
                  Container(height: 1, color: AppColors.glassBorder.withOpacity(0.5)),
              itemBuilder: (_, i) => _buildMovieRow(filtered[i], i),
            ),
          ),
          Container(height: 1, color: AppColors.glassBorder),
          _buildPagination(filtered.length),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Checkbox(
              value: _selected.length == _movies.length,
              onChanged: (v) => setState(() {
                if (v == true) {
                  _selected.addAll(List.generate(_movies.length, (i) => i));
                } else {
                  _selected.clear();
                }
              }),
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(width: 52),
          Expanded(
              flex: 3,
              child: Text('TITLE', style: AppTextStyles.tableHeader())),
          Expanded(
              flex: 2,
              child: Text('CATEGORY', style: AppTextStyles.tableHeader())),
          Expanded(
              flex: 1,
              child: Text('STATUS', style: AppTextStyles.tableHeader())),
          Expanded(
              flex: 1,
              child: Text('VIEWS', style: AppTextStyles.tableHeader())),
          Expanded(
              flex: 1,
              child: Text('PUBLISHED', style: AppTextStyles.tableHeader())),
          Expanded(
              flex: 1,
              child: Text('FEATURED', style: AppTextStyles.tableHeader())),
          SizedBox(
              width: 80,
              child: Text('ACTIONS', style: AppTextStyles.tableHeader())),
        ],
      ),
    );
  }

  Widget _buildMovieRow(_Movie movie, int index) {
    final isSelected = _selected.contains(index);
    final isHovered = _hoveredRow == index;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredRow = index),
      onExit: (_) => setState(() => _hoveredRow = -1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: isSelected
            ? AppColors.primary.withOpacity(0.07)
            : isHovered
                ? AppColors.glass
                : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: Checkbox(
                value: isSelected,
                onChanged: (v) => setState(() {
                  if (v == true) {
                    _selected.add(index);
                  } else {
                    _selected.remove(index);
                  }
                }),
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            // Poster preview
            Container(
              width: 36,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.secondary.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(Icons.movie_rounded,
                  color: AppColors.textMuted, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title,
                      style: AppTextStyles.tableCell().copyWith(
                          fontWeight: FontWeight.w600)),
                  Text(movie.year,
                      style: AppTextStyles.bodySm()),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: StatusBadge(
                label: movie.category,
                color: AppColors.secondary,
                icon: Icons.category_rounded,
              ),
            ),
            Expanded(
              flex: 1,
              child: movie.status == 'published'
                  ? StatusBadge.published()
                  : movie.status == 'draft'
                      ? StatusBadge.draft()
                      : StatusBadge.archived(),
            ),
            Expanded(
              flex: 1,
              child: Text(movie.views,
                  style: AppTextStyles.tableCell().copyWith(
                      color: AppColors.textSecond)),
            ),
            Expanded(
              flex: 1,
              child: Switch(
                value: movie.isPublished,
                onChanged: (v) =>
                    setState(() => movie.isPublished = v),
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            Expanded(
              flex: 1,
              child: Switch(
                value: movie.isFeatured,
                onChanged: (v) =>
                    setState(() => movie.isFeatured = v),
                activeColor: AppColors.gold,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            SizedBox(
              width: 80,
              child: Row(
                children: [
                  _ActionBtn(
                    icon: Icons.edit_rounded,
                    color: AppColors.primary,
                    onTap: () {},
                  ),
                  const SizedBox(width: 4),
                  _ActionBtn(
                    icon: Icons.delete_rounded,
                    color: AppColors.danger,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Text('Showing $total of ${_movies.length} movies',
              style: AppTextStyles.labelLg()),
          const Spacer(),
          _PageBtn(label: '‹', onTap: () {}),
          const SizedBox(width: 4),
          _ActivePageBtn(page: 1),
          const SizedBox(width: 4),
          _PageBtn(label: '2', onTap: () {}),
          const SizedBox(width: 4),
          _PageBtn(label: '3', onTap: () {}),
          const SizedBox(width: 4),
          _PageBtn(label: '›', onTap: () {}),
        ],
      ),
    );
  }
}

class _Movie {
  _Movie(this.title, this.category, this.status, this.isPublished,
      this.isFeatured, this.views, this.year);
  final String title, category, status, views, year;
  bool isPublished, isFeatured;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withOpacity(0.12) : AppColors.glass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.glassBorder,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.badge().copyWith(
          color: selected ? AppColors.primary : AppColors.textSecond,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  const _PageBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.glass,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Center(
          child: Text(label, style: AppTextStyles.labelLg()),
        ),
      ),
    );
  }
}

class _ActivePageBtn extends StatelessWidget {
  const _ActivePageBtn({required this.page});
  final int page;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [AppColors.glowCyan(blur: 12, opacity: 0.4)],
      ),
      child: Center(
        child: Text('$page',
            style: AppTextStyles.labelLg().copyWith(
                color: Colors.black, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
