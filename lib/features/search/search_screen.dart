import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../core/models/movie.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/movie_card.dart';
import '../../core/widgets/voice_search_modal.dart';
import '../../core/widgets/shimmer_loading.dart';

class SearchScreen extends StatefulWidget {
  final Function(Movie) onSelectMovie;

  const SearchScreen({super.key, required this.onSelectMovie});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _filteredMovies = MockData.searchResults;
  bool _isLoading = false;

  final List<String> _trendingTags = [
    '#NeonCyberpunk',
    'Oscar Winners 2024',
    'Interstellar 4K',
    'Modern Classics',
    'Noir Visuals',
  ];

  void _onSearchChanged(String query) {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (query.trim().isEmpty) {
            _filteredMovies = MockData.searchResults;
          } else {
            _filteredMovies = MockData.searchResults.where((movie) {
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore & Search',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          GlassContainer(
            borderRadius: 30,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.primaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Movies, Shows, or Actors...',
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

          const SizedBox(height: 24),

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

          const Text(
            'Recommended for You',
            style: TextStyle(
              fontSize: 20,
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
                childAspectRatio: 0.65,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return const GlassShimmerCard(width: double.infinity, height: 240);
              },
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: _filteredMovies.length,
              itemBuilder: (context, index) {
                final movie = _filteredMovies[index];
                return MovieCard(
                  movie: movie,
                  width: double.infinity,
                  onTap: () => widget.onSelectMovie(movie),
                );
              },
            ),
        ],
      ),
    );
  }
}
