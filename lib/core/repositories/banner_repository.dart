import '../services/storage_service.dart';

class EnterpriseBannerRepository {
  final StorageService _storageService = StorageService();
  final Map<String, String> _firestoreBannerUrls = {};

  Map<String, String> get firestoreUrls => Map.unmodifiable(_firestoreBannerUrls);

  Future<String> updateHeroBannerUrl({
    required String bannerId,
    required List<int> bannerBytes,
    String extension = 'jpg',
  }) async {
    final publicUrl = await _storageService.uploadMovieBanner(
      bytes: bannerBytes,
      movieId: bannerId,
      extension: extension,
    );

    // Save ONLY the public URL in Firestore
    _firestoreBannerUrls['banner_${bannerId}_imageUrl'] = publicUrl;
    return publicUrl;
  }
}
