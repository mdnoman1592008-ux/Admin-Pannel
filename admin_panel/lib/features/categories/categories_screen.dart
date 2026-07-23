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
          padding: const EdgeInsets.all(20),
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
      final cols = constraints.maxWidth > 1100 ? 6 : constraints.maxWidth > 800 ? 4 : 3;
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
          return GlassCard(
            glowColor: AppColors.primary,
            glowBlur: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.category_rounded, color: AppColors.primary, size: 20),
                ),
                const Spacer(),
                Text(cat.name, style: AppTextStyles.h3()),
                const SizedBox(height: 4),
                Text('${cat.movieCount} movies', style: AppTextStyles.bodySm()),
              ],
            ),
          );
        },
      );
    });
  }

  void _showAddCategoryDialog() {
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Text('Add Category to Firestore', style: AppTextStyles.h3()),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(hintText: 'Category Name (e.g. Action, Cyberpunk)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          GlowButton(
            label: 'Save',
            icon: Icons.check_rounded,
            color: AppColors.accent,
            textColor: Colors.black,
            isSmall: true,
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                _backend.addCategory(LiveCategory(
                  id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  iconName: 'category',
                  colorHex: '#00D8FF',
                  movieCount: 0,
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
