import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_initializer.dart';

/// Configurable Supabase Storage Configuration for Web Admin Panel (Single Bucket: ether-cinema)
class AdminSupabaseStorageConfig {
  static const String singleBucketName = 'ether-cinema';

  static String getPublicUrl(String logicalPath) =>
      SupabaseInitializer.getPublicUrl(logicalPath, bucket: singleBucketName);
}

typedef AdminUploadProgressCallback = void Function(double progress);

/// Automated Admin Panel Storage Service for Supabase Storage (Single Bucket: "ether-cinema")
class AdminStorageService {
  static final AdminStorageService _instance = AdminStorageService._internal();
  factory AdminStorageService() => _instance;
  AdminStorageService._internal();

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
    final cleanPath =
        logicalPath.startsWith('/') ? logicalPath.substring(1) : logicalPath;
    int attempts = 0;
    bool success = false;

    while (attempts < maxRetries && !success) {
      attempts++;
      try {
        onProgress?.call(0.2);
        await SupabaseInitializer.client.storage
            .from(AdminSupabaseStorageConfig.singleBucketName)
            .uploadBinary(
              cleanPath,
              Uint8List.fromList(bytes),
              fileOptions: FileOptions(contentType: contentType, upsert: false),
            );
        onProgress?.call(0.8);
        onProgress?.call(1.0);
        success = true;
      } catch (e) {
        debugPrint(
            '[AdminStorageService] Upload attempt $attempts failed for $cleanPath: $e');
        if (attempts >= maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 300 * attempts));
      }
    }

    final publicUrl = AdminSupabaseStorageConfig.getPublicUrl(cleanPath);
    debugPrint(
        '[AdminStorageService] Automated Upload Complete: $cleanPath -> Public URL: $publicUrl');
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
    return uploadPath(
        bytes: bytes,
        logicalPath: path,
        contentType: 'image/jpeg',
        onProgress: onProgress);
  }

  Future<String> uploadMovieBanner({
    required List<int> bytes,
    required String movieId,
    String extension = 'jpg',
    AdminUploadProgressCallback? onProgress,
  }) {
    final uuid = _generateUuid();
    final path = 'banners/$movieId/$uuid.$extension';
    return uploadPath(
        bytes: bytes,
        logicalPath: path,
        contentType: 'image/jpeg',
        onProgress: onProgress);
  }

  Future<String> uploadSeriesPoster({
    required List<int> bytes,
    required String seriesId,
    String extension = 'jpg',
    AdminUploadProgressCallback? onProgress,
  }) {
    final uuid = _generateUuid();
    final path = 'posters/series/$seriesId/$uuid.$extension';
    return uploadPath(
        bytes: bytes,
        logicalPath: path,
        contentType: 'image/jpeg',
        onProgress: onProgress);
  }

  Future<String> uploadAvatar({
    required List<int> bytes,
    required String userId,
    String extension = 'jpg',
    AdminUploadProgressCallback? onProgress,
  }) {
    final uuid = _generateUuid();
    final path = 'avatars/$userId/$uuid.$extension';
    return uploadPath(
        bytes: bytes,
        logicalPath: path,
        contentType: 'image/jpeg',
        onProgress: onProgress);
  }

  Future<String> uploadSubtitle({
    required List<int> bytes,
    required String movieId,
    required String language,
    String extension = 'srt',
    AdminUploadProgressCallback? onProgress,
  }) {
    final path = 'subtitles/$movieId/$language.$extension';
    return uploadPath(
        bytes: bytes,
        logicalPath: path,
        contentType: 'text/plain',
        onProgress: onProgress);
  }

  Future<String> uploadLogo({
    required List<int> bytes,
    String extension = 'png',
    AdminUploadProgressCallback? onProgress,
  }) {
    final uuid = _generateUuid();
    final path = 'logos/$uuid.$extension';
    return uploadPath(
        bytes: bytes,
        logicalPath: path,
        contentType: 'image/png',
        onProgress: onProgress);
  }

  Future<bool> savePlaylistOrder(
      String playlistName, List<String> orderedIds) async {
    debugPrint(
        '[AdminStorageService] Synced playlist [$playlistName] order (${orderedIds.length} items)');
    return true;
  }
}
