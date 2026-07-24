import 'package:flutter/material.dart';
import '../../../core/models/home_section_model.dart';
import '../../../core/models/movie.dart';
import 'hero_banner_renderer.dart';
import 'horizontal_carousel_renderer.dart';
import 'top10_renderer.dart';
import 'billboard_renderer.dart';
import 'continue_watching_renderer.dart';
import 'upcoming_renderer.dart';
import 'grid_renderer.dart';
import 'vertical_list_renderer.dart';
import 'masonry_grid_renderer.dart';

class SectionRenderer extends StatelessWidget {
  final HomeSectionModel section;
  final List<Movie> movies;
  final Function(Movie) onSelectMovie;

  const SectionRenderer({
    super.key,
    required this.section,
    required this.movies,
    required this.onSelectMovie,
  });

  @override
  Widget build(BuildContext context) {
    if (!section.isEnabled || !section.scheduling.isCurrentlyActive) {
      return const SizedBox.shrink();
    }

    try {
      switch (section.layoutType) {
        case SectionLayoutType.heroBanner:
          return HeroBannerRenderer(
            section: section,
            movies: movies,
            onSelectMovie: onSelectMovie,
          );
        case SectionLayoutType.top10:
          return Top10Renderer(
            section: section,
            movies: movies,
            onSelectMovie: onSelectMovie,
          );
        case SectionLayoutType.billboard:
          return BillboardRenderer(
            section: section,
            movies: movies,
            onSelectMovie: onSelectMovie,
          );
        case SectionLayoutType.continueWatching:
          return ContinueWatchingRenderer(
            section: section,
            movies: movies,
            onSelectMovie: onSelectMovie,
          );
        case SectionLayoutType.comingSoon:
          return UpcomingRenderer(
            section: section,
            movies: movies,
            onSelectMovie: onSelectMovie,
          );
        case SectionLayoutType.grid:
          return GridRenderer(
            section: section,
            movies: movies,
            onSelectMovie: onSelectMovie,
          );
        case SectionLayoutType.verticalList:
          return VerticalListRenderer(
            section: section,
            movies: movies,
            onSelectMovie: onSelectMovie,
          );
        case SectionLayoutType.masonryGrid:
          return MasonryGridRenderer(
            section: section,
            movies: movies,
            onSelectMovie: onSelectMovie,
          );
        case SectionLayoutType.horizontalCarousel:
        default:
          return HorizontalCarouselRenderer(
            section: section,
            movies: movies,
            onSelectMovie: onSelectMovie,
          );
      }
    } catch (e, stack) {
      debugPrint('[SectionRenderer] Error rendering section ${section.title} (${section.layoutType.name}): $e\n$stack');
      // Fallback renderer to prevent app crashes
      return HorizontalCarouselRenderer(
        section: section,
        movies: movies,
        onSelectMovie: onSelectMovie,
      );
    }
  }
}
