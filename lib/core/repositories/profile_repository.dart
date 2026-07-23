import '../services/storage_service.dart';

class EnterpriseProfileRepository {
  final StorageService _storageService = StorageService();
  final Map<String, String> _firestoreProfileUrls = {};

  Map<String, String> get firestoreUrls => Map.unmodifiable(_firestoreProfileUrls);

  Future<String> updateAvatarUrl({
    required String userId,
    required List<int> avatarBytes,
    String extension = 'jpg',
  }) async {
    final publicUrl = await _storageService.uploadAvatar(
      bytes: avatarBytes,
      userId: userId,
      extension: extension,
    );

    // Save ONLY the public URL in Firestore
    _firestoreProfileUrls['user_${userId}_avatarUrl'] = publicUrl;
    return publicUrl;
  }
}
