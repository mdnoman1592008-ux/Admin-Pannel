import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/models/home_section_model.dart';
import '../../../core/models/movie.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/liquid_button.dart';

class HeroBannerRenderer extends StatefulWidget {
  final HomeSectionModel section;
  final List<Movie> movies;
  final Function(Movie) onSelectMovie;

  const HeroBannerRenderer({
    super.key,
    required this.section,
    required this.movies,
    required this.onSelectMovie,
  });

  @override
  State<HeroBannerRenderer> createState() => _HeroBannerRendererState();
}

class _HeroBannerRendererState extends State<HeroBannerRenderer> {
  late PageController _pageController;
  int _activeIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    if (widget.section.style.autoScroll) {
      _startAutoSlide();
    }
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || widget.movies.isEmpty) return;
      final next = (_activeIndex + 1) % widget.movies.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 440,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.movies.length,
            onPageChanged: (idx) => setState(() => _activeIndex = idx),
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      movie.backdropUrl.isNotEmpty ? movie.backdropUrl : movie.posterUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xBB0A0C10),
                            Color(0xFF0A0C10),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 24,
                    left: 20,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'TOP 10',
                            style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '#1 in Movies',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              movie.rating.toStringAsFixed(1),
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            const Text('•', style: TextStyle(color: Colors.white54, fontSize: 13)),
                            const SizedBox(width: 8),
                            Text(
                              movie.releaseYear,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            if (movie.genres.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              const Text('•', style: TextStyle(color: Colors.white54, fontSize: 13)),
                              const SizedBox(width: 8),
                              Text(
                                movie.genres.first,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                            const SizedBox(width: 8),
                            const Text('•', style: TextStyle(color: Colors.white54, fontSize: 13)),
                            const SizedBox(width: 8),
                            Text(
                              movie.duration,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          movie.synopsis,
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.4),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6C5CE7),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.play_arrow_rounded, size: 24),
                                  label: const Text('Play Now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                  onPressed: () => widget.onSelectMovie(movie),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white30, width: 1.5),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.add_rounded, color: Colors.white),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          // Page Indicators
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.movies.length, (idx) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _activeIndex == idx ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _activeIndex == idx ? const Color(0xFF6C5CE7) : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
