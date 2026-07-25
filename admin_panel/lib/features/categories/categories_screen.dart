import 'package:flutter/material.dart';
import '../../core/backend/backend_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';

/// Live Categories Screen — Animated Icon Grid from Firestore 'categories'
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _backend = LiveBackendService.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _backend,
      builder: (context, _) {
        final categories = _backend.categories;

        return Container(
          color: AppColors.background,
          padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 12 : 20),
          child: Column(
            children: [
              _buildHeader(categories.length),
              const SizedBox(height: 20),
              Expanded(child: _buildGrid(categories)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(int count) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text('$count Live Categories', style: AppTextStyles.h3()),
          const Spacer(),
          GlowButton(
            label: 'Add Category',
            icon: Icons.add_rounded,
            color: AppColors.accent,
            textColor: Colors.black,
            isSmall: true,
            onPressed: _showAddCategoryDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<LiveCategory> categories) {
    if (categories.isEmpty) {
      return GlassCard(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.category_rounded, color: AppColors.textMuted, size: 48),
              const SizedBox(height: 16),
              Text('No data available in Firestore collection "categories"', style: AppTextStyles.h3()),
              const SizedBox(height: 8),
              Text('Click "Add Category" to create live categories.', style: AppTextStyles.bodySm()),
              const SizedBox(height: 20),
              GlowButton(
                label: 'Add First Category',
                icon: Icons.add_rounded,
                color: AppColors.accent,
                textColor: Colors.black,
                isSmall: true,
                onPressed: _showAddCategoryDialog,
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final cols = constraints.maxWidth > 1100 ? 6 : constraints.maxWidth > 800 ? 4 : constraints.maxWidth > 500 ? 2 : 1;
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          childAspectRatio: 0.95,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final cat = categories[i];
          final color = _colorFromHex(cat.colorHex);
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _showCategoryDialog(category: cat),
            child: GlassCard(
            glowColor: color,
            glowBlur: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_iconForName(cat.iconName), color: color, size: 20),
                ),
                const Spacer(),
                Text(cat.name, style: AppTextStyles.h3()),
                const SizedBox(height: 4),
                Row(children: [
                  Expanded(child: Text('${cat.movieCount} movies', style: AppTextStyles.bodySm())),
                  IconButton(icon: const Icon(Icons.more_horiz_rounded, size: 18), onPressed: () => _showCategoryDialog(category: cat)),
                ]),
              ],
            ),
          ));
        },
      );
    });
  }

  IconData _iconForName(String name) => switch (name) {
        'movie' => Icons.movie_rounded,
        'tv' => Icons.live_tv_rounded,
        'anime' => Icons.auto_awesome_rounded,
        'kids' => Icons.child_care_rounded,
        _ => Icons.category_rounded,
      };

  Color _colorFromHex(String value) {
    final clean = value.replaceFirst('#', '');
    return Color(int.tryParse('FF$clean', radix: 16) ?? 0xFF00D8FF);
  }

  void _showAddCategoryDialog() => _showCategoryDialog();

  void _showCategoryDialog({LiveCategory? category}) {
    final nameCtrl = TextEditingController(text: category?.name ?? '');
    var iconName = category?.iconName ?? 'category';
    var colorHex = category?.colorHex ?? '#00D8FF';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Text(category == null ? 'Create category' : 'Edit category', style: AppTextStyles.h3()),
        content: StatefulBuilder(builder: (context, setDialogState) => SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Category name', hintText: 'Action, Drama, Anime')),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(value: iconName, decoration: const InputDecoration(labelText: 'Icon'), items: const [
            DropdownMenuItem(value: 'category', child: Text('Category')),
            DropdownMenuItem(value: 'movie', child: Text('Movie')),
            DropdownMenuItem(value: 'tv', child: Text('TV / Series')),
            DropdownMenuItem(value: 'anime', child: Text('Anime')),
            DropdownMenuItem(value: 'kids', child: Text('Kids')),
          ], onChanged: (value) => setDialogState(() => iconName = value ?? 'category')),
          const SizedBox(height: 14),
          Wrap(spacing: 8, children: ['#00D8FF', '#7B61FF', '#00FFC8', '#FFD86A', '#FF5D8F'].map((hex) => ChoiceChip(label: Text(hex), selected: colorHex == hex, onSelected: (_) => setDialogState(() => colorHex = hex))).toList()),
        ])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          GlowButton(
            label: category == null ? 'Create' : 'Save changes',
            icon: Icons.check_rounded,
            color: AppColors.accent,
            textColor: Colors.black,
            isSmall: true,
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                final saved = LiveCategory(id: category?.id ?? 'cat_${DateTime.now().millisecondsSinceEpoch}', name: nameCtrl.text.trim(), iconName: iconName, colorHex: colorHex, movieCount: category?.movieCount ?? 0);
                category == null ? _backend.addCategory(saved) : _backend.updateCategory(saved);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
