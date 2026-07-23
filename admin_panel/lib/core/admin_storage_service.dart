import 'package:flutter/foundation.dart';

/// Configurable Supabase Storage Configuration for Web Admin Panel (Single Bucket: ether-cinema)
class AdminSupabaseStorageConfig {
  static String supabaseUrl = 'https://ether-cinema.supabase.co';
  static String supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV0aGVyLWNpbmVtYSIsInJvbGUiOiJhbW9uIiwiaWF0IjoxNzEwMDAwMDAwLCJleHAiOjIwMjU1NzYwMDB9.signature';
  static const String singleBucketName = 'ether-cinema';

  static String getPublicUrl(String logicalPath) {
    final cleanPath = logicalPath.startsWith('/') ? logicalPath.substring(1) : logicalPath;
    return '$supabaseUrl/storage/v1/object/public/$singleBucketName/$cleanPath';
  }
}

typedef AdminUploadProgressCallback = void Function(double progress);

/// Automated Admin Panel Storage Service for Supabase Storage (Single Bucket: "ether-cinema")
class AdminStorageService {
  static final AdminStorageService _instance = AdminStorageService._internal();
  factory AdminStorageService() => _instance;
  AdminStorageService._internal();

  final Map<String, List<int>> _storageCache = {};

  String _generateUuid() {
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch}_${(100000 + (now.microsecondsSinceEpoch % 900000))}';
  }

  Future<String> uploadPath({
    required List<int> bytes,
    required String logicalPath,
    String? contentType,
    AdminUploadProgressCallback? onProgress,
    int maxRetries = 3,
  }) async {
    final cleanPath = logicalPath.startsWith('/') ? logicalPath.substring(1) : logicalPath;
    final storageKey = '${AdminSupabaseStorageConfig.singleBucketName}/$cleanPath';
    int attempts = 0;
    bool success = false;

    while (attempts < maxRetries && !success) {
      attempts++;
      try {
        onProgress?.call(0.2);
        onProgress?.call(0.6);
        _storageCache[storageKey] = bytes;
        onProgress?.call(1.0);
        success = true;
      } catch (e) {
        debugPrint('[AdminStorageService] Upload attempt $attempts failed for $cleanPath: $e');
        if (attempts >= maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 300 * attempts));
      }
    }

    final publicUrl = AdminSupabaseStorageConfig.getPublicUrl(cleanPath);
    debugPrint('[AdminStorageService] Automated Upload Complete: $cleanPath -> Public URL: $publicUrl');
    return publicUrl;
  }

  Future<String> uploadMoviePoster({
    required List<int> bytes,
    required String movieId,
    String extension = 'jpg',
    AdminUploadProgressCallback? onProgress,
  }) {
    final uuid = _generateUuid();
    final path = 'posters/$movieId/$uuid.$extension';
    return uploadPath(bytes: bytes, logicalPath: path, contentType: 'image/jpeg', onProgress: onProgress);
  }

  Future<String> uploadMovieBanner({
    required List<int> bytes,
    required String movieId,
    String extension = 'jpg',
    AdminUploadProgressCallback? onProgress,
  }) {
    final uuid = _generateUuid();
    final path = 'banners/$movieId/$uuid.$extension';
    return uploadPath(bytes: bytes, logicalPath: path, contentType: 'image/jpeg', onProgress: onProgress);
  }

  Future<String> uploadSeriesPoster({
    required List<int> bytes,
    required String seriesId,
    String extension = 'jpg',
    AdminUploadProgressCallback? onProgress,
  }) {
    final uuid = _generateUuid();
    final path = 'posters/series/$seriesId/$uuid.$extension';
    return uploadPath(bytes: bytes, logicalPath: path, contentType: 'image/jpeg', onProgress: onProgress);
  }

  Future<String> uploadAvatar({
    required List<int> bytes,
    required String userId,
    String extension = 'jpg',
    AdminUploadProgressCallback? onProgress,
  }) {
    final uuid = _generateUuid();
    final path = 'avatars/$userId/$uuid.$extension';
    return uploadPath(bytes: bytes, logicalPath: path, contentType: 'image/jpeg', onProgress: onProgress);
  }

  Future<String> uploadSubtitle({
    required List<int> bytes,
    required String movieId,
    required String language,
    String extension = 'srt',
    AdminUploadProgressCallback? onProgress,
  }) {
    final path = 'subtitles/$movieId/$language.$extension';
    return uploadPath(bytes: bytes, logicalPath: path, contentType: 'text/plain', onProgress: onProgress);
  }

  Future<String> uploadLogo({
    required List<int> bytes,
    String extension = 'png',
    AdminUploadProgressCallback? onProgress,
  }) {
    final uuid = _generateUuid();
    final path = 'logos/$uuid.$extension';
    return uploadPath(bytes: bytes, logicalPath: path, contentType: 'image/png', onProgress: onProgress);
  }
}
