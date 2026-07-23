import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../core/models/movie.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/liquid_button.dart';
import '../../core/widgets/movie_card.dart';
import '../../core/widgets/continue_watching_card.dart';

class HomeScreen extends StatelessWidget {
  final Function(Movie) onSelectMovie;
  final VoidCallback? onOpenAdmin;

  const HomeScreen({
    super.key,
    required this.onSelectMovie,
    this.onOpenAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final heroMovie = MockData.featuredHeroMovie;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Bar with Secret Long-Press Admin Access
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onLongPress: onOpenAdmin,
                  child: const Row(
                    children: [
                      Icon(
                        Icons.movie_filter_rounded,
                        color: AppColors.primaryContainer,
                        size: 28,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ether Cinema',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryContainer,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search_rounded, color: AppColors.primary),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.account_circle_rounded, color: AppColors.primary),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Featured Hero Carousel Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GestureDetector(
              onTap: () => onSelectMovie(heroMovie),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: GlassContainer(
                  padding: EdgeInsets.zero,
                  borderRadius: 32,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        heroMovie.posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: AppColors.surfaceContainerHigh),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.background.withOpacity(0.95),
                              Colors.transparent,
                              Colors.black45,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 24,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.tertiaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'EXCLUSIVE PREMIERE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onTertiary,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              heroMovie.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              heroMovie.synopsis,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                LiquidButton(
                                  label: 'Watch Now',
                                  icon: Icons.play_arrow_rounded,
                                  onPressed: () => onSelectMovie(heroMovie),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.1),
                                    border: Border.all(color: Colors.white30),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.add, color: Colors.white),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Continue Watching Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Continue Watching',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'SEE ALL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryContainer,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 205,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: MockData.continueWatchingMovies.length,
              itemBuilder: (context, index) {
                final movie = MockData.continueWatchingMovies[index];
                return ContinueWatchingCard(
                  movie: movie,
                  onTap: () => onSelectMovie(movie),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // Trending Now
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Trending Now',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 270,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: MockData.trendingMovies.length,
              itemBuilder: (context, index) {
                final movie = MockData.trendingMovies[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: MovieCard(
                    movie: movie,
                    onTap: () => onSelectMovie(movie),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // Anime & Series Collection
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Anime & Cyberpunk Collections',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 270,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: MockData.animeMovies.length,
              itemBuilder: (context, index) {
                final movie = MockData.animeMovies[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: MovieCard(
                    movie: movie,
                    onTap: () => onSelectMovie(movie),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
