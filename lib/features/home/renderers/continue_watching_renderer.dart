import 'package:flutter/material.dart';
import '../../../core/models/home_section_model.dart';
import '../../../core/models/movie.dart';
import '../../../core/widgets/continue_watching_card.dart';

class ContinueWatchingRenderer extends StatelessWidget {
  final HomeSectionModel section;
  final List<Movie> movies;
  final Function(Movie) onSelectMovie;

  const ContinueWatchingRenderer({
    super.key,
    required this.section,
    required this.movies,
    required this.onSelectMovie,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            children: [
              const Icon(Icons.history_rounded, color: Color(0xFF6C5CE7), size: 20),
              const SizedBox(width: 8),
              Text(
                section.title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 220,
                  child: ContinueWatchingCard(
                    movie: movie,
                    progressRatio: 0.45,
                    onTap: () => onSelectMovie(movie),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
