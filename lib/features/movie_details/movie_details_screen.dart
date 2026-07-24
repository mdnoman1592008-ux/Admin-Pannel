import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/models/movie.dart';
import '../../core/models/episode.dart';
import '../../core/models/season.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/downloads/encrypted_download_manager.dart';
import '../../core/services/permission_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/liquid_button.dart';
import '../../core/widgets/movie_card.dart';
import '../../core/widgets/share_modal.dart';
import '../../core/cms/cms_repository.dart';
import '../player/dailymotion_player_view.dart';

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
  bool _isLiked = false;
  bool _showPlayer = false;
  Episode? _activeEpisode;
  int _selectedSeasonIndex = 0;
  late bool _isSubscribedToNotifyMe;
  Timer? _countdownTimer;
  Duration _remainingTime = const Duration(days: 5, hours: 14, minutes: 22);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _isSubscribedToNotifyMe = NotificationService.isSubscribedToNotifyMe(widget.movie.id);
    _startCountdown();

    if (widget.movie.episodes.isNotEmpty) {
      _activeEpisode = widget.movie.episodes.first;
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _openPlayer([Episode? episode]) {
    setState(() {
      if (episode != null) _activeEpisode = episode;
      _showPlayer = true;
    });
  }

  void _closePlayer() {
    setState(() {
      _showPlayer = false;
    });
  }

  void _toggleNotifyMe() {
    final newState = NotificationService.toggleNotifyMe(widget.movie.id);
    setState(() {
      _isSubscribedToNotifyMe = newState;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newState ? 'Notification Enabled! We will alert you on premiere.' : 'Notification Cancelled'),
        backgroundColor: const Color(0xFF00CFFF),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatCountdown(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final mins = d.inMinutes % 60;
    final secs = d.inSeconds % 60;
    return '${days}d ${hours}h ${mins}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    final isUnreleased = widget.movie.isUnreleased || widget.movie.scheduledPublishDate != null;

    final List<Season> displaySeasons = widget.movie.seasons.isNotEmpty
        ? widget.movie.seasons
        : [
            Season(
              id: 's1',
              seriesId: widget.movie.id,
              seasonNumber: 1,
              seasonTitle: 'Season 1',
              releaseDate: DateTime.now(),
              episodes: widget.movie.episodes,
            ),
          ];

    final activeSeason = displaySeasons[_selectedSeasonIndex.clamp(0, displaySeasons.length - 1)];

    final cmsMovies = CmsRepository().movies.map((item) {
      return Movie(
        id: item.id,
        title: item.title,
        synopsis: item.synopsis,
        rating: 4.9,
        tags: item.genres,
        genres: item.genres,
        posterUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDzKwJZepW88E0hJiIBM4Vxba1Rpq3U50h9tkiPvp7xZJQK-mO2jMmpBbUeSRQbi8RFiA4qI7p9OGX6D5KDd63ubsU9_i6fdkW6RC-mW64KoyzIwowoe6zwbzI62x9DLZTHlWO0eABkKj5stmyuXQDPc12JQywmKdc1yNjmFOwic1xpNRC0aXvh3z81Pg_DP6CVgOLwf9QQzDXP88WrgFJo4NERkeXKJgYInTZCxEoQaioAg0i_neIHlapRuo2-ngOhlcuZFphmeA',
        backdropUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDzKwJZepW88E0hJiIBM4Vxba1Rpq3U50h9tkiPvp7xZJQK-mO2jMmpBbUeSRQbi8RFiA4qI7p9OGX6D5KDd63ubsU9_i6fdkW6RC-mW64KoyzIwowoe6zwbzI62x9DLZTHlWO0eABkKj5stmyuXQDPc12JQywmKdc1yNjmFOwic1xpNRC0aXvh3z81Pg_DP6CVgOLwf9QQzDXP88WrgFJo4NERkeXKJgYInTZCxEoQaioAg0i_neIHlapRuo2-ngOhlcuZFphmeA',
        duration: '2h 15m',
        releaseYear: '${item.releaseDate.year}',
        dailymotionVideoId: item.dailymotionVideoId,
        isSeries: item.isSeries,
        episodes: item.episodes,
      );
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Inline Hybrid Player or Backdrop Header
            if (_showPlayer)
              SizedBox(
                height: 250,
                child: DailymotionPlayerView(
                  movie: widget.movie,
                  selectedEpisode: _activeEpisode,
                  onClose: _closePlayer,
                  onSelectEpisode: (ep) {
                    setState(() {
                      _activeEpisode = ep;
                    });
                  },
                ),
              )
            else
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
                    ),
                  ),
                ],
              ),

            // Content Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: isUnreleased ? null : AppColors.luxuryGoldGradient,
                          color: isUnreleased ? const Color(0xFF00CFFF).withOpacity(0.2) : null,
                          border: isUnreleased ? Border.all(color: const Color(0xFF00CFFF)) : null,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isUnreleased ? 'COMING SOON' : (widget.movie.tags.isNotEmpty ? widget.movie.tags.first : 'IMAX 4K'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isUnreleased ? const Color(0xFF00CFFF) : Colors.black,
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

                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  if (_activeEpisode != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Currently Selected: ${_activeEpisode!.title}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF00CFFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Action Button Row (Play, Favorite, Like, Share)
                  Row(
                    children: [
                      Expanded(
                        child: isUnreleased
                            ? ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isSubscribedToNotifyMe
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF00CFFF),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                                onPressed: _toggleNotifyMe,
                                icon: Icon(_isSubscribedToNotifyMe ? Icons.check_circle_rounded : Icons.notifications_active_rounded),
                                label: Text(
                                  _isSubscribedToNotifyMe ? 'Notification Enabled' : 'Notify Me',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              )
                            : LiquidButton(
                                label: _showPlayer ? 'Resume Stream' : 'Play Stream',
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
                        },
                        child: Icon(
                          _isInWatchlist ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                          color: _isInWatchlist ? AppColors.primaryContainer : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GlassContainer(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 30,
                        onTap: () {
                          setState(() {
                            _isLiked = !_isLiked;
                          });
                        },
                        child: Icon(
                          _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: _isLiked ? Colors.redAccent : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GlassContainer(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 30,
                        onTap: () async {
                          final granted = await PermissionService().requestStoragePermission(context);
                          if (!granted) return;

                          EncryptedDownloadManager().startDownload(
                            movieId: widget.movie.id,
                            title: widget.movie.title,
                            posterUrl: widget.movie.posterUrl,
                            quality: '4K Ultra HD',
                            totalBytes: 2500000000,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Started 4K download for "${widget.movie.title}".'),
                                backgroundColor: const Color(0xFF00CFFF),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        child: const Icon(
                          Icons.download_for_offline_rounded,
                          color: Color(0xFF00CFFF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Synopsis Text
                  Text(
                    widget.movie.synopsis,
                    style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // Netflix-style Season Selector & Episodes List Cards
                  if (widget.movie.isSeries) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Episodes & Seasons',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${activeSeason.episodes.length} Episodes',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Horizontal Season Choice Chips
                    if (displaySeasons.length > 1) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(displaySeasons.length, (index) {
                            final season = displaySeasons[index];
                            final isSel = index == _selectedSeasonIndex;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(season.seasonTitle),
                                selected: isSel,
                                onSelected: (val) {
                                  if (val) setState(() => _selectedSeasonIndex = index);
                                },
                                selectedColor: const Color(0xFF00CFFF),
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Episode Cards List with Active Neon Blue Playing Glow
                    Column(
                      children: activeSeason.episodes.map((episode) {
                        final isPlaying = _activeEpisode?.id == episode.id && _showPlayer;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: isPlaying
                                ? Border.all(color: const Color(0xFF00CFFF), width: 2)
                                : Border.all(color: Colors.white12),
                            boxShadow: isPlaying
                                ? const [BoxShadow(color: Color(0x6600CFFF), blurRadius: 12)]
                                : null,
                          ),
                          child: GlassContainer(
                            borderRadius: 16,
                            padding: const EdgeInsets.all(12),
                            onTap: () => _openPlayer(episode),
                            child: Row(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        episode.thumbnailUrl,
                                        width: 100,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Container(width: 100, height: 60, color: Colors.white10),
                                      ),
                                    ),
                                    Container(
                                      width: 100,
                                      height: 60,
                                      color: Colors.black38,
                                    ),
                                    Icon(
                                      isPlaying ? Icons.equalizer_rounded : Icons.play_circle_fill_rounded,
                                      color: const Color(0xFF00CFFF),
                                      size: 28,
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ep ${episode.episodeNumber}. ${episode.title}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isPlaying ? const Color(0xFF00CFFF) : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        episode.duration,
                                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // More Like This Recommendations Section
                  const Text(
                    'More Like This',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: cmsMovies.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: MovieCard(
                            movie: cmsMovies[index],
                            onTap: () => widget.onSelectMovie(cmsMovies[index]),
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
