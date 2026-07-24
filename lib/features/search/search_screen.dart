import 'package:flutter/material.dart';
import '../../core/models/movie.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/movie_card.dart';
import '../../core/widgets/voice_search_modal.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/cms/cms_repository.dart';

class SearchScreen extends StatefulWidget {
  final Function(Movie) onSelectMovie;

  const SearchScreen({super.key, required this.onSelectMovie});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final CmsRepository _cmsRepository = CmsRepository();
  List<Movie> _filteredMovies = [];
  bool _isLoading = false;

  final List<String> _trendingTags = [
    '#Cyberpunk',
    '#Sci-Fi',
    '#IMAX',
    '#BanglaNatok',
    '#AnimeMasterpiece',
  ];

  @override
  void initState() {
    super.initState();
    _filteredMovies = _getCmsMovies();

    // Auto-focus search text field and trigger keyboard immediately on page enter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Movie> _getCmsMovies() {
    return _cmsRepository.movies.map((item) {
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
      );
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        final all = _getCmsMovies();
        setState(() {
          _isLoading = false;
          if (query.trim().isEmpty) {
            _filteredMovies = all;
          } else {
            _filteredMovies = all.where((movie) {
              return movie.title.toLowerCase().contains(query.toLowerCase()) ||
                  movie.genres.any((g) => g.toLowerCase().contains(query.toLowerCase()));
            }).toList();
          }
        });
      }
    });
  }

  void _openVoiceSearch() {
    showDialog(
      context: context,
      builder: (context) => VoiceSearchModal(
        onResult: (spokenText) {
          Navigator.pop(context);
          _searchController.text = spokenText;
          _onSearchChanged(spokenText);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (Navigator.canPop(context))
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () {
                      _searchFocusNode.unfocus();
                      Navigator.pop(context);
                    },
                  ),
                const Text(
                  'Explore & Search',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hero Animated Floating Glass Search Bar with Auto Keyboard Focus
            Hero(
              tag: 'search_bar_hero_tag',
              child: Material(
                color: Colors.transparent,
                child: GlassContainer(
                  borderRadius: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.primaryContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          autofocus: true,
                          onChanged: _onSearchChanged,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'Search movies, series, actors...',
                            hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.mic_rounded, color: AppColors.primaryContainer),
                        onPressed: _openVoiceSearch,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Trending Chips
            const Text(
              'Trending Searches',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _trendingTags.map((tag) {
                return GlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  onTap: () {
                    final query = tag.replaceAll('#', '');
                    _searchController.text = query;
                    _onSearchChanged(query);
                  },
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Results Grid / Shimmer Loading
            const Text(
              'Realtime Results',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            if (_isLoading)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 4,
                itemBuilder: (context, index) => const GlassShimmerCard(
                  width: double.infinity,
                  height: 220,
                  borderRadius: 16,
                ),
              )
            else if (_filteredMovies.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Text(
                    'No titles match your search criteria.',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _filteredMovies.length,
                itemBuilder: (context, index) {
                  final movie = _filteredMovies[index];
                  return MovieCard(
                    movie: movie,
                    onTap: () => widget.onSelectMovie(movie),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
