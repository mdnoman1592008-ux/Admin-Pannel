import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const List<Map<String, dynamic>> _categories = [
    {'name': 'Sci-Fi & Cyberpunk', 'icon': Icons.rocket_launch_rounded, 'count': '142 Titles'},
    {'name': 'Action & Thriller', 'icon': Icons.bolt_rounded, 'count': '98 Titles'},
    {'name': 'Documentaries', 'icon': Icons.public_rounded, 'count': '56 Titles'},
    {'name': 'Drama & Noir', 'icon': Icons.theater_comedy_rounded, 'count': '87 Titles'},
    {'name': '3D & IMAX Shorts', 'icon': Icons.view_in_ar_rounded, 'count': '34 Titles'},
    {'name': 'Classic Masterpieces', 'icon': Icons.workspace_premium_rounded, 'count': '112 Titles'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories & Genres',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Curated experiential cinema collections',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(cat['icon'] as IconData, color: AppColors.primaryContainer, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      cat['name'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat['count'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
