import '../services/storage_service.dart';

class EnterpriseSeriesRepository {
  final StorageService _storageService = StorageService();
  final Map<String, String> _firestoreSeriesUrls = {};

  Map<String, String> get firestoreUrls => Map.unmodifiable(_firestoreSeriesUrls);

  Future<String> updateSeriesPoster({
    required String seriesId,
    required List<int> imageBytes,
    String extension = 'jpg',
  }) async {
    final publicUrl = await _storageService.uploadSeriesPoster(
      bytes: imageBytes,
      seriesId: seriesId,
      extension: extension,
    );

    // Save ONLY the public URL in Firestore
    _firestoreSeriesUrls['series_${seriesId}_posterUrl'] = publicUrl;
    return publicUrl;
  }

  Future<String> updateSeriesBanner({
    required String seriesId,
    required List<int> imageBytes,
    String extension = 'jpg',
  }) async {
    final publicUrl = await _storageService.uploadSeriesBanner(
      bytes: imageBytes,
      seriesId: seriesId,
      extension: extension,
    );

    // Save ONLY the public URL in Firestore
    _firestoreSeriesUrls['series_${seriesId}_bannerUrl'] = publicUrl;
    return publicUrl;
  }
}
