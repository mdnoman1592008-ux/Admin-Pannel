import 'package:flutter/material.dart';
import '../../../core/models/home_section_model.dart';
import '../../../core/models/movie.dart';
import '../../../core/widgets/movie_card.dart';

class GridRenderer extends StatelessWidget {
  final HomeSectionModel section;
  final List<Movie> movies;
  final Function(Movie) onSelectMovie;

  const GridRenderer({
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
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: movies.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.65,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return MovieCard(
                movie: movie,
                onTap: () => onSelectMovie(movie),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
