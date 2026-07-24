import 'package:flutter/material.dart';
import '../features/movie_details/movie_details_screen.dart' as feature_details;
import '../models/movie.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;
  final VoidCallback onBack;
  final Function(Movie) onSelectMovie;

  const MovieDetailsScreen({
    super.key,
    required this.movie,
    required this.onBack,
    required this.onSelectMovie,
  });

  @override
  Widget build(BuildContext context) {
    return feature_details.MovieDetailsScreen(
      movie: movie,
      onBack: onBack,
      onSelectMovie: onSelectMovie,
    );
  }
}
