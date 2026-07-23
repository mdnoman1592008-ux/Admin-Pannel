import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/liquid_button.dart';
import '../data/mock_data.dart';
import '../widgets/movie_card.dart';
import '../widgets/share_modal.dart';
import '../widgets/dailymotion_player_view.dart';
import '../models/episode.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;
  final VoidCallback onBack;
  final Function(Movie) onSelectMovie;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
    required this.onBack,
    required this.onSelectMovie,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  bool _isInWatchlist = false;
  bool _showPlayer = false;
  Episode? _activeEpisode;

  void _openPlayer([Episode? episode]) {
    setState(() {
      _activeEpisode = episode;
      _showPlayer = true;
    });
  }

  void _closePlayer() {
    setState(() {
      _showPlayer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showPlayer) {
      return DailymotionPlayerView(
        movie: widget.movie,
        selectedEpisode: _activeEpisode,
        onClose: _closePlayer,
        onSelectEpisode: (ep) {
          setState(() {
            _activeEpisode = ep;
          });
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Backdrop & Header
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 12,
                  child: Image.network(
                    widget.movie.backdropUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: AppColors.surfaceContainerHigh),
                  ),
                ),
                Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.background, Colors.transparent, Colors.black45],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                // Top Action Bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                            onPressed: widget.onBack,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.share_rounded, color: Colors.white),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => ShareModal(movie: widget.movie),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Content Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges & Rating
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppColors.luxuryGoldGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.movie.tags.isNotEmpty ? widget.movie.tags.first : 'IMAX 4K',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.star_rounded, color: AppColors.tertiary, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.movie.rating} / 10',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tertiary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '• ${widget.movie.duration} • ${widget.movie.releaseYear}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Genres
                  Wrap(
                    spacing: 8,
                    children: widget.movie.genres.map((genre) {
                      return GlassContainer(
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Text(
                          genre,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: LiquidButton(
                          label: 'Play Stream',
                          icon: Icons.play_arrow_rounded,
                          onPressed: () => _openPlayer(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GlassContainer(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 30,
                        onTap: () {
                          setState(() {
                            _isInWatchlist = !_isInWatchlist;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isInWatchlist
                                  ? 'Added to Watchlist!'
                                  : 'Removed from Watchlist'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Icon(
                          _isInWatchlist ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                          color: _isInWatchlist ? AppColors.primaryContainer : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Episodes List (if Series/Anime)
                  if (widget.movie.isSeries && widget.movie.episodes.isNotEmpty) ...[
                    const Text(
                      'Season 1 Episodes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.movie.episodes.length,
                      itemBuilder: (context, index) {
                        final ep = widget.movie.episodes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GlassContainer(
                            borderRadius: 20,
                            padding: const EdgeInsets.all(12),
                            onTap: () => _openPlayer(ep),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    ep.thumbnail,
                                    width: 80,
                                    height: 55,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ep.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        ep.duration,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.play_circle_fill_rounded, color: AppColors.primaryContainer),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Synopsis Container
                  GlassContainer(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Synopsis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.movie.synopsis,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Cast Section
                  if (widget.movie.cast.isNotEmpty) ...[
                    const Text(
                      'Director & Leading Cast',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.movie.cast.length,
                        itemBuilder: (context, index) {
                          final member = widget.movie.cast[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: AppColors.primaryContainer,
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(member.avatarUrl),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  member.name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  member.role,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Related Masterpieces
                  const Text(
                    'Related Masterpieces',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: MockData.trendingMovies.length,
                      itemBuilder: (context, index) {
                        final relMovie = MockData.trendingMovies[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 14.0),
                          child: MovieCard(
                            movie: relMovie,
                            onTap: () => widget.onSelectMovie(relMovie),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
