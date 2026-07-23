import '../models/movie.dart';

class MovieDto {
  final String id;
  final String title;
  final String synopsis;
  final double rating;
  final String posterUrl;
  final String backdropUrl;
  final String dailymotionId;

  MovieDto({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.rating,
    required this.posterUrl,
    required this.backdropUrl,
    required this.dailymotionId,
  });

  factory MovieDto.fromJson(Map<String, dynamic> json) {
    return MovieDto(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      synopsis: json['synopsis'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      posterUrl: json['poster_url'] ?? '',
      backdropUrl: json['backdrop_url'] ?? '',
      dailymotionId: json['dailymotion_id'] ?? 'x8m00bc',
    );
  }
}

class MovieMapper {
  static Movie toEntity(MovieDto dto) {
    return Movie(
      id: dto.id,
      title: dto.title,
      synopsis: dto.synopsis,
      rating: dto.rating,
      tags: ['4K', 'IMAX'],
      genres: ['Sci-Fi'],
      posterUrl: dto.posterUrl,
      backdropUrl: dto.backdropUrl,
      duration: '2h 10m',
      releaseYear: '2025',
      dailymotionVideoId: dto.dailymotionId,
    );
  }
}
