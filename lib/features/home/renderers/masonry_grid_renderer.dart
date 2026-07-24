import 'package:flutter/material.dart';
import '../../../core/models/home_section_model.dart';
import '../../../core/models/movie.dart';
import '../../../core/widgets/movie_card.dart';

class MasonryGridRenderer extends StatelessWidget {
  final HomeSectionModel section;
  final List<Movie> movies;
  final Function(Movie) onSelectMovie;

  const MasonryGridRenderer({
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
          child: Text(
            section.title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: movies.map((movie) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 42) / 2,
                height: 200,
                child: MovieCard(
                  movie: movie,
                  onTap: () => onSelectMovie(movie),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
