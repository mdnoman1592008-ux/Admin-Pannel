import '../services/storage_service.dart';

class EnterpriseCategoryRepository {
  final StorageService _storageService = StorageService();
  final Map<String, String> _firestoreCategoryUrls = {};

  Map<String, String> get firestoreUrls => Map.unmodifiable(_firestoreCategoryUrls);

  Future<String> updateCategoryIconUrl({
    required String categoryId,
    required List<int> iconBytes,
    String extension = 'png',
  }) async {
    final publicUrl = await _storageService.uploadCategoryIcon(
      bytes: iconBytes,
      categoryId: categoryId,
      extension: extension,
    );

    // Save ONLY the public URL in Firestore
    _firestoreCategoryUrls['category_${categoryId}_iconUrl'] = publicUrl;
    return publicUrl;
  }
}
