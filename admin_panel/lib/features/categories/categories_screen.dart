import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';

/// Categories Screen — Animated icon card grid
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _categories = [
    _Cat('Action', Icons.local_fire_department_rounded, AppColors.danger, 248),
    _Cat('Comedy', Icons.sentiment_very_satisfied_rounded, AppColors.gold, 186),
    _Cat('Drama', Icons.theater_comedy_rounded, AppColors.secondary, 312),
    _Cat('Sci-Fi', Icons.rocket_launch_rounded, AppColors.primary, 174),
    _Cat('Horror', Icons.warning_amber_rounded, AppColors.warning, 93),
    _Cat('Romance', Icons.favorite_rounded, Color(0xFFFF6B9D), 127),
    _Cat('Animation', Icons.animation_rounded, AppColors.accent, 208),
    _Cat('Documentary', Icons.video_library_rounded, AppColors.textSecond, 64),
    _Cat('Thriller', Icons.psychology_rounded, Color(0xFF9C27B0), 89),
    _Cat('Fantasy', Icons.auto_awesome_rounded, AppColors.gold, 143),
    _Cat('History', Icons.menu_book_rounded, Color(0xFF8D6E63), 52),
    _Cat('Sport', Icons.sports_soccer_rounded, AppColors.success, 76),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Expanded(child: _buildGrid()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text('${_categories.length} Categories',
              style: AppTextStyles.h3()),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${_categories.fold(0, (s, c) => s + c.count)} total movies',
                style: AppTextStyles.badge().copyWith(
                    color: AppColors.primary, fontSize: 11)),
          ),
          const Spacer(),
          GlowButton(
            label: 'Add Category',
            icon: Icons.add_rounded,
            color: AppColors.accent,
            textColor: Colors.black,
            isSmall: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      final cols = constraints.maxWidth > 1100 ? 6 :
                   constraints.maxWidth > 800 ? 4 : 3;
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          childAspectRatio: 0.95,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: _categories.length,
        itemBuilder: (_, i) => _CategoryCard(cat: _categories[i]),
      );
    });
  }
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({required this.cat});
  final _Cat cat;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 1.04)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: GlassCard(
          glowColor: widget.cat.color,
          glowBlur: 24,
          borderColor: widget.cat.color.withOpacity(0.2),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.cat.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: widget.cat.color.withOpacity(0.3),
                            blurRadius: 16),
                      ],
                    ),
                    child: Icon(widget.cat.icon,
                        color: widget.cat.color, size: 22),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.glass,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: const Icon(Icons.more_horiz_rounded,
                          color: AppColors.textMuted, size: 14),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(widget.cat.name, style: AppTextStyles.h3()),
              const SizedBox(height: 4),
              Text('${widget.cat.count} movies',
                  style: AppTextStyles.bodySm()),
              const SizedBox(height: 12),
              // Progress bar
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
                    widthFactor: (widget.cat.count / 350).clamp(0.1, 1.0),
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: widget.cat.color,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                              color: widget.cat.color.withOpacity(0.5),
                              blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cat {
  const _Cat(this.name, this.icon, this.color, this.count);
  final String name;
  final IconData icon;
  final Color color;
  final int count;
}
