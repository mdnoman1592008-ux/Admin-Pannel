import '../services/storage_service.dart';

class EnterpriseSettingsRepository {
  final StorageService _storageService = StorageService();
  final Map<String, String> _firestoreSettingsUrls = {};

  Map<String, String> get firestoreUrls => Map.unmodifiable(_firestoreSettingsUrls);

  Future<String> updateAppLogoUrl({
    required List<int> logoBytes,
    String extension = 'png',
  }) async {
    final publicUrl = await _storageService.uploadLogo(
      bytes: logoBytes,
      extension: extension,
    );

    // Save ONLY the public URL in Firestore
    _firestoreSettingsUrls['app_logoUrl'] = publicUrl;
    return publicUrl;
  }
}
