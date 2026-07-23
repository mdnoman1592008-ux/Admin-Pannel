import '../../models/movie.dart';
import '../../services/movie_repository.dart';

class GetTrendingMoviesUseCase {
  final IMovieRepository repository;

  GetTrendingMoviesUseCase([IMovieRepository? repo])
      : repository = repo ?? MovieRepository();

  Future<List<Movie>> execute() async {
    return await repository.getTrending();
  }
}
