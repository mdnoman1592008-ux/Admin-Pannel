import '../services/storage_service.dart';

class EnterpriseMovieRepository {
  final StorageService _storageService = StorageService();
  final Map<String, String> _firestoreMovieUrls = {};

  Map<String, String> get firestoreUrls => Map.unmodifiable(_firestoreMovieUrls);

  /// Uploads a movie poster to Supabase Storage and updates the Firestore posterUrl property.
  Future<String> updateMoviePoster({
    required String movieId,
    required List<int> imageBytes,
    String extension = 'jpg',
  }) async {
    final publicUrl = await _storageService.uploadMoviePoster(
      bytes: imageBytes,
      movieId: movieId,
      extension: extension,
    );

    // Save ONLY the public URL in Firestore
    _firestoreMovieUrls['movie_${movieId}_posterUrl'] = publicUrl;
    return publicUrl;
  }

  /// Uploads a movie banner to Supabase Storage and updates the Firestore bannerUrl property.
  Future<String> updateMovieBanner({
    required String movieId,
    required List<int> imageBytes,
    String extension = 'jpg',
  }) async {
    final publicUrl = await _storageService.uploadMovieBanner(
      bytes: imageBytes,
      movieId: movieId,
      extension: extension,
    );

    // Save ONLY the public URL in Firestore
    _firestoreMovieUrls['movie_${movieId}_bannerUrl'] = publicUrl;
    return publicUrl;
  }

  /// Uploads a subtitle file to Supabase Storage and updates the Firestore subtitleUrl property.
  Future<String> updateMovieSubtitle({
    required String movieId,
    required String language,
    required List<int> subtitleBytes,
    String extension = 'srt',
  }) async {
    final publicUrl = await _storageService.uploadSubtitle(
      bytes: subtitleBytes,
      movieId: movieId,
      language: language,
      extension: extension,
    );

    // Save ONLY the public URL in Firestore
    _firestoreMovieUrls['movie_${movieId}_subtitleUrl_$language'] = publicUrl;
    return publicUrl;
  }
}
