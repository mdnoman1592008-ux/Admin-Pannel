import 'package:flutter/material.dart';
import '../../../core/models/home_section_model.dart';
import '../../../core/models/movie.dart';
import '../../../core/widgets/movie_card.dart';

class Top10Renderer extends StatelessWidget {
  final HomeSectionModel section;
  final List<Movie> movies;
  final Function(Movie) onSelectMovie;

  const Top10Renderer({
    super.key,
    required this.section,
    required this.movies,
    required this.onSelectMovie,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    final topList = movies.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('TOP 10', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Text(
                section.title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: topList.length,
            itemBuilder: (context, index) {
              final movie = topList[index];
              final rank = index + 1;

              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    // Rank Number Shadow/Text
                    Positioned(
                      left: 0,
                      bottom: -10,
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 100,
                          fontWeight: FontWeight.w900,
                          color: Colors.white.withOpacity(0.12),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    // Movie Poster Shifted Right
                    Positioned(
                      right: 0,
                      top: 10,
                      bottom: 10,
                      width: 130,
                      child: MovieCard(
                        movie: movie,
                        onTap: () => onSelectMovie(movie),
                      ),
                    ),
                  ],
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
