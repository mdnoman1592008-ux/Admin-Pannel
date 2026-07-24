import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../core/notifications/notification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/liquid_button.dart';
import '../widgets/movie_card.dart';
import '../widgets/continue_watching_card.dart';
import '../core/cms/realtime_cms_engine.dart';
import '../core/cms/cms_repository.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(Movie) onSelectMovie;

  const HomeScreen({
    super.key,
    required this.onSelectMovie,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RealtimeCmsEngine _cmsEngine = RealtimeCmsEngine();
  final CmsRepository _cmsRepository = CmsRepository();

  late PageController _bannerPageController;
  int _activeBannerIndex = 0;
  Timer? _bannerTimer;
  String _selectedCategory = 'ALL';

  final List<Movie> _comingSoonMovies = [];

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController(initialPage: 0);
    _startBannerAutoSlide();
  }

  void _startBannerAutoSlide() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final banners = _cmsRepository.banners;
      if (banners.isEmpty) return;

      final nextPage = (_activeBannerIndex + 1) % banners.length;
      _bannerPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerPageController.dispose();
    super.dispose();
  }

  Movie _cmsItemToMovie(CmsMovieItem item) {
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
      isNewRelease: true,
    );
  }

  void _openLiveSearch() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: SearchScreen(onSelectMovie: widget.onSelectMovie),
            ),
          );
        },
      ),
    );
  }

  void _openLiveNotifications() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const _LiveNotificationDrawerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CmsMovieItem>>(
      stream: _cmsEngine.movieStream,
      initialData: _cmsRepository.movies,
      builder: (context, snapshot) {
        final cmsList = snapshot.data ?? [];
        final allMovies = cmsList.map(_cmsItemToMovie).toList();

        // Apply dynamic category filter
        final movies = _selectedCategory == 'ALL'
            ? allMovies
            : allMovies.where((m) => m.genres.contains(_selectedCategory)).toList();

        final banners = _cmsRepository.banners;
        final categories = _cmsRepository.categories;
        final unreadCount = NotificationService.unreadCount;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top App Bar Layout
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 48, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryContainer.withValues(alpha: 0.15),
                          ),
                          child: const Icon(
                            Icons.movie_filter_rounded,
                            color: AppColors.primaryContainer,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
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
                    Row(
                      children: [
                        Hero(
                          tag: 'search_bar_hero_tag',
                          child: Material(
                            color: Colors.transparent,
                            child: IconButton(
                              icon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 24),
                              onPressed: _openLiveSearch,
                              tooltip: 'Live Search',
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 24),
                              onPressed: _openLiveNotifications,
                              tooltip: 'Notifications',
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  child: Text(
                                    '$unreadCount',
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Dynamic Home Hero Banner Slider
              if (banners.isNotEmpty) ...[
                SizedBox(
                  height: 380,
                  child: PageView.builder(
                    controller: _bannerPageController,
                    onPageChanged: (index) {
                      setState(() {
                        _activeBannerIndex = index;
                      });
                    },
                    itemCount: banners.length,
                    itemBuilder: (context, index) {
                      final banner = banners[index];
                      final matchedMovie = allMovies.firstWhere(
                        (m) => m.id == banner.movieId,
                        orElse: () => allMovies.first,
                      );

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () => widget.onSelectMovie(matchedMovie),
                          child: GlassContainer(
                            padding: EdgeInsets.zero,
                            borderRadius: 32,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  banner.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(color: AppColors.surfaceContainerHigh),
                                ),
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xF2050505),
                                        Colors.transparent,
                                        Colors.black54,
                                        Color(0xE6050505),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 24,
                                  left: 20,
                                  right: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        banner.title,
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        banner.description,
                                        maxLines: 2,
                                        style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          LiquidButton(
                                            label: 'Watch Now',
                                            icon: Icons.play_arrow_rounded,
                                            onPressed: () => widget.onSelectMovie(matchedMovie),
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
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Indicator Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(banners.length, (index) {
                    final isActive = index == _activeBannerIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isActive ? const Color(0xFF00CFFF) : Colors.white24,
                      ),
                    );
                  }),
                ),
              ],

              const SizedBox(height: 24),

              // Dynamic Firestore Categories Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = cat.name == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = cat.name;
                            });
                          }
                        },
                        selectedColor: const Color(0xFF00CFFF),
                        backgroundColor: const Color(0x22151A24),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF00CFFF) : Colors.white12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 28),

              // Continue Watching Cross-Device Progress Row
              if (allMovies.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Continue Watching',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ContinueWatchingCard(
                    movie: allMovies.first,
                    onTap: () => widget.onSelectMovie(allMovies.first),
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // Dedicated Coming Soon Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: Color(0xFF00CFFF), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Coming Soon & Premieres',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _comingSoonMovies.length,
                  itemBuilder: (context, index) {
                    final cs = _comingSoonMovies[index];
                    final isSub = NotificationService.isSubscribedToNotifyMe(cs.id);

                    return Container(
                      width: 170,
                      margin: const EdgeInsets.only(right: 14),
                      child: GestureDetector(
                        onTap: () => widget.onSelectMovie(cs),
                        child: GlassContainer(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  height: 130,
                                  width: double.infinity,
                                  child: Image.network(cs.posterUrl, fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cs.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              const Text('Premieres in 4 Days', style: TextStyle(color: Color(0xFF00CFFF), fontSize: 11, fontWeight: FontWeight.w600)),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                height: 32,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSub ? const Color(0xFF10B981) : const Color(0xFF00CFFF),
                                    foregroundColor: Colors.black,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      NotificationService.toggleNotifyMe(cs.id);
                                    });
                                  },
                                  icon: Icon(isSub ? Icons.check_rounded : Icons.notifications_active_rounded, size: 14),
                                  label: Text(isSub ? 'Set' : 'Notify', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // Movie Rail Sections
              if (movies.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('No content available in this category.', style: TextStyle(color: Colors.white54)),
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    '$_selectedCategory Blockbusters',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final m = movies[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: MovieCard(
                          movie: m,
                          onTap: () => widget.onSelectMovie(m),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _LiveNotificationDrawerDialog extends StatelessWidget {
  const _LiveNotificationDrawerDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0D111A),
      title: const Text('Notifications', style: TextStyle(color: Colors.white)),
      content: const Text('No new notifications.', style: TextStyle(color: Colors.white54)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Color(0xFF00CFFF))),
        ),
      ],
    );
  }
}
