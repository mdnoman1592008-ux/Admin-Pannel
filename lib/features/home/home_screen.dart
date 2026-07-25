import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/movie.dart';
import '../../core/models/home_section_model.dart';
import '../../core/cms/realtime_cms_engine.dart';
import '../../core/cms/cms_repository.dart';
import '../../core/cms/home_section_repository.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/services/permission_service.dart';
import '../../models/streaming_source.dart';
import '../search/search_screen.dart';
import '../notifications/notifications_screen.dart';
import 'renderers/section_renderer.dart';

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
  final HomeSectionRepository _sectionRepository = HomeSectionRepository();

  String _selectedCategory = 'ALL';

  void _openNotificationsModal() async {
    final granted =
        await PermissionService().requestNotificationPermission(context);
    if (!granted)
      return; // If permanently denied or not granted, don't show the mock sheet for now, or just show it empty? Let's show it anyway but tell them. Wait, if granted is false, we can just return, but they might want to see past notifications even without push. Let's just proceed.
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141927),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StreamBuilder<List<AppNotification>>(
          stream: NotificationService.notificationsStream,
          initialData: NotificationService.notifications,
          builder: (context, snapshot) {
            final notifications = snapshot.data ?? [];
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.notifications_active_rounded,
                              color: Color(0xFF6C5CE7), size: 24),
                          SizedBox(width: 10),
                          Text(
                            'Live Notifications',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          NotificationService.markAllAsRead();
                        },
                        child: const Text('Mark all read',
                            style: TextStyle(
                                color: Color(0xFF00CFFF), fontSize: 12)),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  if (notifications.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text('No new notifications',
                            style: TextStyle(color: Colors.white54)),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = notifications[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: item.isRead
                                  ? Colors.white.withOpacity(0.04)
                                  : const Color(0xFF6C5CE7).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: item.isRead
                                    ? Colors.white12
                                    : const Color(0xFF6C5CE7).withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  item.isRead
                                      ? Icons.notifications_none_rounded
                                      : Icons.notifications_active_rounded,
                                  color: item.isRead
                                      ? Colors.white54
                                      : const Color(0xFF00CFFF),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: item.isRead
                                              ? FontWeight.w600
                                              : FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.message,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openNotificationsPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
    );
  }

  Movie _cmsItemToMovie(CmsMovieItem item) {
    return Movie(
      id: item.id,
      title: item.title,
      synopsis: item.synopsis,
      rating: 4.8,
      tags:
          item.isSeries ? const ['SERIES', '4K'] : const ['HD', 'BLOCKBUSTER'],
      genres: item.genres,
      posterUrl: item.episodes.isNotEmpty
          ? item.episodes.first.thumbnail
          : item.posterUrl,
      backdropUrl: item.bannerUrl,
      dailymotionVideoId: item.dailymotionVideoId,
      streamingSources: _streamingSources(item),
      duration:
          item.episodes.isNotEmpty ? item.episodes.first.duration : '2h 15m',
      releaseYear: item.releaseDate.year.toString(),
      isSeries: item.isSeries,
      episodes: item.episodes,
    );
  }

  List<StreamingSource> _streamingSources(CmsMovieItem item) {
    final provider = switch (item.sourceProvider) {
      'youtube' => StreamingProvider.youtube,
      'dailymotion' => StreamingProvider.dailymotion,
      'hls' => StreamingProvider.hls,
      'dash' => StreamingProvider.dash,
      'mp4' => StreamingProvider.mp4,
      _ => StreamingProvider.dailymotion,
    };
    final source = item.sourceUrl.isNotEmpty ? item.sourceUrl : item.dailymotionVideoId;
    return source.isEmpty ? const [] : [StreamingSource(id: '${item.id}_primary', provider: provider, urlOrId: source, priority: 1)];
  }

  List<Movie> _getMoviesForSection(
      HomeSectionModel section, List<Movie> allCatalog) {
    List<Movie> result = List.from(allCatalog);

    // Apply category filter bar override
    if (_selectedCategory != 'ALL') {
      result = result.where((m) {
        return m.genres.any(
                (g) => g.toLowerCase() == _selectedCategory.toLowerCase()) ||
            (_selectedCategory == 'Natok' &&
                m.title.toLowerCase().contains('natok')) ||
            (_selectedCategory == 'Series' && m.isSeries) ||
            (_selectedCategory == 'Anime' &&
                m.genres.any((g) => g.toLowerCase() == 'anime'));
      }).toList();
    }

    // Apply section specific content source
    switch (section.contentSource) {
      case SectionContentSource.manual:
        if (section.manualItemIds.isNotEmpty) {
          result = result
              .where((m) => section.manualItemIds.contains(m.id))
              .toList();
        }
        break;
      case SectionContentSource.category:
        final cat = section.filters['category'] as String?;
        if (cat != null && cat.isNotEmpty) {
          result = result
              .where((m) =>
                  m.genres.any((g) => g.toLowerCase() == cat.toLowerCase()))
              .toList();
        }
        break;
      case SectionContentSource.genre:
        final g = section.filters['genre'] as String?;
        if (g != null && g.isNotEmpty) {
          result = result
              .where((m) => m.genres
                  .any((genre) => genre.toLowerCase() == g.toLowerCase()))
              .toList();
        }
        break;
      case SectionContentSource.tag:
        final tag = section.filters['tag'] as String?;
        if (tag != null && tag.isNotEmpty) {
          result = result
              .where((m) =>
                  m.tags.any((t) => t.toLowerCase() == tag.toLowerCase()))
              .toList();
        }
        break;
      case SectionContentSource.comingSoon:
        result = result
            .where((m) => m.isUnreleased || m.scheduledPublishDate != null)
            .toList();
        break;
      case SectionContentSource.highestRated:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SectionContentSource.trending:
      case SectionContentSource.mostViewed:
      case SectionContentSource.recentlyAdded:
      case SectionContentSource.continueWatching:
      case SectionContentSource.recommended:
      default:
        break;
    }

    if (result.length > section.maxItems) {
      result = result.sublist(0, section.maxItems);
    }

    return result;
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'all':
        return Icons.grid_view_rounded;
      case 'movies':
        return Icons.movie_creation_rounded;
      case 'tv shows':
        return Icons.tv_rounded;
      case 'series':
        return Icons.tv_rounded;
      case 'anime':
        return Icons.face_retouching_natural_rounded;
      case 'kids':
        return Icons.child_care_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget _buildCategoryFilterRail() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('categories')
          .orderBy('displayOrder')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const SizedBox
              .shrink(); // Hide the rail completely if no live categories are added
        }

        // Combine 'ALL' with the live categories from the panel
        final List<String> liveCategories = ['ALL'];
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['name'] as String?;
          if (name != null && name.isNotEmpty) {
            liveCategories.add(name);
          }
        }

        return Container(
          height: 48,
          margin: const EdgeInsets.only(top: 12, bottom: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: liveCategories.length,
            itemBuilder: (context, index) {
              final cat = liveCategories[index];
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ChoiceChip(
                  elevation: 0,
                  pressElevation: 0,
                  showCheckmark: false,
                  avatar: Icon(
                    _getCategoryIcon(cat),
                    color: isSelected ? Colors.white : Colors.white70,
                    size: 18,
                  ),
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: const Color(0xFF6C5CE7),
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : Colors.white24,
                      width: 1.0,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  onSelected: (_) {
                    setState(() => _selectedCategory = cat);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0A24), // Rich Dark Purple Midnight
              Color(0xFF0C1122), // Deep Ocean Indigo
              Color(0xFF140D26), // Electric Purple Tint
              Color(0xFF080914), // Dark Obsidian Base
            ],
            stops: [0.0, 0.35, 0.70, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative Ambient Neon Glow Orbs
            Positioned(
              top: -60,
              left: -40,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6C5CE7).withOpacity(0.24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.24),
                      blurRadius: 100,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 260,
              right: -50,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00CFFF).withOpacity(0.18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00CFFF).withOpacity(0.18),
                      blurRadius: 110,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 140,
              left: -40,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF2D55).withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF2D55).withOpacity(0.15),
                      blurRadius: 95,
                      spreadRadius: 35,
                    ),
                  ],
                ),
              ),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('movies')
                  .where('isPublished', isEqualTo: true)
                  .snapshots(),
              builder: (context, movieSnapshot) {
                List<CmsMovieItem> rawCmsItems = [];
                if (movieSnapshot.hasData &&
                    movieSnapshot.data!.docs.isNotEmpty) {
                  rawCmsItems = movieSnapshot.data!.docs.map((doc) {
                    return CmsMovieItem.fromMap(
                        doc.id, doc.data() as Map<String, dynamic>);
                  }).toList();
                }

                final allCatalogMovies =
                    rawCmsItems.map(_cmsItemToMovie).toList();

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('home_sections')
                      .orderBy('displayOrder')
                      .snapshots(),
                  builder: (context, sectionSnapshot) {
                    List<HomeSectionModel> activeSections = [];
                    if (sectionSnapshot.hasData &&
                        sectionSnapshot.data!.docs.isNotEmpty) {
                      activeSections = sectionSnapshot.data!.docs
                          .map((doc) {
                            return HomeSectionModel.fromJson({
                              'id': doc.id,
                              ...doc.data() as Map<String, dynamic>
                            });
                          })
                          .where((s) =>
                              s.isEnabled && s.scheduling.isCurrentlyActive)
                          .toList();
                    }

                    final bool hasHeroBanner = activeSections.isNotEmpty &&
                        activeSections.first.layoutType ==
                            SectionLayoutType.heroBanner;

                    final heroSection =
                        hasHeroBanner ? activeSections.first : null;
                    final remainingSections = hasHeroBanner
                        ? activeSections.sublist(1)
                        : activeSections;

                    return CustomScrollView(
                      slivers: [
                        // App Bar / Top Navigation
                        SliverAppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          floating: true,
                          pinned: true,
                          expandedHeight: 60,
                          flexibleSpace: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF0D0A24).withOpacity(0.9),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                height: 32,
                                errorBuilder: (_, __, ___) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C5CE7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('ETHER',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'CINEMA',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2),
                              ),
                            ],
                          ),
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.search_rounded,
                                  color: Colors.white, size: 24),
                              onPressed: () {
                                Navigator.of(context).push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        SearchScreen(
                                      onSelectMovie: widget.onSelectMovie,
                                    ),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      final curved = CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutCubic,
                                      );
                                      return FadeTransition(
                                        opacity: curved,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0, .06),
                                            end: Offset.zero,
                                          ).animate(curved),
                                          child: child,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            StreamBuilder<List<AppNotification>>(
                                stream: NotificationService.notificationsStream,
                                initialData: NotificationService.notifications,
                                builder: (context, snapshot) {
                                  final unreadCount =
                                      NotificationService.unreadCount;
                                  return Stack(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.notifications_outlined,
                                            color: Colors.white,
                                            size: 24),
                                        onPressed: _openNotificationsPage,
                                        tooltip: 'Notifications',
                                      ),
                                      if (unreadCount > 0)
                                        Positioned(
                                          right: 6,
                                          top: 6,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFF2D55),
                                              shape: BoxShape.circle,
                                            ),
                                            constraints: const BoxConstraints(
                                                minWidth: 16, minHeight: 16),
                                            child: Text(
                                              '$unreadCount',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                            const SizedBox(width: 8),
                          ],
                        ),

                        // Hero Banner (Rendered FIRST at top)
                        if (heroSection != null)
                          SliverToBoxAdapter(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: SectionRenderer(
                                key: ValueKey(
                                    '${heroSection.id}_$_selectedCategory'),
                                section: heroSection,
                                movies: _getMoviesForSection(
                                    heroSection, allCatalogMovies),
                                onSelectMovie: widget.onSelectMovie,
                              ),
                            ),
                          ),

                        // Category Filter Rail (Placed RIGHT BELOW the Hero Banner!)
                        SliverToBoxAdapter(
                          child: _buildCategoryFilterRail(),
                        ),

                        if (activeSections.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6C5CE7)
                                            .withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.movie_filter_rounded,
                                        size: 48,
                                        color: Color(0xFF6C5CE7),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No Content Available Yet',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Upload movies and home sections from the Admin Panel to display them here in real-time.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final section = remainingSections[index];
                                final sectionMovies = _getMoviesForSection(
                                    section, allCatalogMovies);

                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: SectionRenderer(
                                    key: ValueKey(
                                        '${section.id}_$_selectedCategory'),
                                    section: section,
                                    movies: sectionMovies,
                                    onSelectMovie: widget.onSelectMovie,
                                  ),
                                );
                              },
                              childCount: remainingSections.length,
                            ),
                          ),

                        const SliverToBoxAdapter(child: SizedBox(height: 40)),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
