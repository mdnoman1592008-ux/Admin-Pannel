import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import 'glass_container.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final double width;
  final double aspectRatio;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    this.width = 160.0,
    this.aspectRatio = 2 / 3,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: aspectRatio,
              child: GlassContainer(
                padding: EdgeInsets.zero,
                borderRadius: 20,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      movie.posterUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surfaceContainerHigh,
                          child: const Icon(Icons.movie, color: AppColors.primary),
                        );
                      },
                    ),
                    // Gradient overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black54, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    // Badges (4K / IMAX / VIP)
                    if (movie.tags.isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: movie.tags.map((tag) {
                            final isVip = tag == 'VIP';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isVip
                                      ? AppColors.tertiary.withValues(alpha: 0.5)
                                      : AppColors.primaryContainer.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isVip ? AppColors.tertiary : AppColors.primaryContainer,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    // Rating overlay
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.tertiary, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            movie.rating.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (movie.genres.isNotEmpty)
              Text(
                '${movie.genres.first} • ${movie.releaseYear}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
