import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_config.dart';
import '../supabase/supabase_initializer.dart';

/// Central Upload Logger for tracking enterprise storage operations
class UploadLogger {
  static final List<String> _logs = [];

  static List<String> get logs => List.unmodifiable(_logs);

  static void logSuccess({
    required String path,
    required int sizeBytes,
    required Duration duration,
    required int attempts,
  }) {
    final entry =
        '[UPLOAD_SUCCESS] Path: $path | Size: ${(sizeBytes / 1024).toStringAsFixed(1)} KB | Duration: ${duration.inMilliseconds}ms | Attempts: $attempts';
    _logs.insert(0, entry);
    debugPrint('[UploadLogger] $entry');
  }

  static void logFailure({
    required String path,
    required String reason,
    required int attempts,
  }) {
    final entry =
        '[UPLOAD_FAILURE] Path: $path | Reason: $reason | Attempts: $attempts';
    _logs.insert(0, entry);
    debugPrint('[UploadLogger] $entry');
  }

  static void logRetry({
    required String path,
    required int attempt,
    required String error,
  }) {
    final entry =
        '[UPLOAD_RETRY] Path: $path | Attempt #$attempt | Error: $error';
    _logs.insert(0, entry);
    debugPrint('[UploadLogger] $entry');
  }
}

/// File Validation Engine for verifying formats and file sizes
class FileValidator {
  static const int maxFileSizeBytes = 52428800; // 50 MB default limit
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp'
  ];
  static const List<String> allowedSubtitleExtensions = ['srt', 'vtt'];

  static void validateImage(List<int> bytes, String extension) {
    if (bytes.length > maxFileSizeBytes) {
      throw FormatException('File size exceeds maximum limit of 50 MB');
    }
    final cleanExt = extension.toLowerCase().replaceAll('.', '');
    if (!allowedImageExtensions.contains(cleanExt)) {
      throw FormatException(
          'Invalid image extension: $cleanExt. Allowed: $allowedImageExtensions');
    }
  }

  static void validateSubtitle(List<int> bytes, String extension) {
    if (bytes.length > maxFileSizeBytes) {
      throw FormatException('File size exceeds maximum limit of 50 MB');
    }
    final cleanExt = extension.toLowerCase().replaceAll('.', '');
    if (!allowedSubtitleExtensions.contains(cleanExt)) {
      throw FormatException(
          'Invalid subtitle extension: $cleanExt. Allowed: $allowedSubtitleExtensions');
    }
  }
}

typedef UploadProgressCallback = void Function(double progress);

abstract class StorageProvider {
  Future<String> uploadPath({
    required List<int> bytes,
    required String logicalPath,
    String? contentType,
    UploadProgressCallback? onProgress,
    int maxRetries = 3,
  });

  Future<String> getPublicUrl(String logicalPath);
  Future<void> deletePath(String logicalPath);
  Future<void> deleteFileByUrl(String publicUrl);

  // Supported Upload Types
  Future<String> uploadMoviePoster({
    required List<int> bytes,
    required String movieId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  });

  Future<String> uploadMovieBanner({
    required List<int> bytes,
    required String movieId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  });

  Future<String> uploadSeriesPoster({
    required List<int> bytes,
    required String seriesId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  });

  Future<String> uploadSeriesBanner({
    required List<int> bytes,
    required String seriesId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  });

  Future<String> uploadLogo({
    required List<int> bytes,
    String extension = 'png',
    UploadProgressCallback? onProgress,
  });

  Future<String> uploadAvatar({
    required List<int> bytes,
    required String userId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  });

  Future<String> uploadSubtitle({
    required List<int> bytes,
    required String movieId,
    required String language,
    String extension = 'srt',
    UploadProgressCallback? onProgress,
  });

  Future<String> uploadTrailerThumbnail({
    required List<int> bytes,
    required String movieId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  });

  Future<String> uploadCategoryIcon({
    required List<int> bytes,
    required String categoryId,
    String extension = 'png',
    UploadProgressCallback? onProgress,
  });

  Future<String> replaceFile({
    required String oldPublicUrl,
    required List<int> newBytes,
    required String newLogicalPath,
    String? contentType,
    UploadProgressCallback? onProgress,
  });

  // Backward Compatibility Helpers
  Future<String> uploadPoster(List<int> bytes, String fileName,
      {String? contentType});
  Future<String> uploadBanner(List<int> bytes, String fileName,
      {String? contentType});
}

class SupabaseStorageService implements StorageProvider {
  String _generateUuid() {
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch}_${(100000 + (now.microsecondsSinceEpoch % 900000))}';
  }

  String _cleanExt(String ext) => ext.toLowerCase().replaceAll('.', '');

  @override
  Future<String> uploadPath({
    required List<int> bytes,
    required String logicalPath,
    String? contentType,
    UploadProgressCallback? onProgress,
    int maxRetries = 3,
  }) async {
    final cleanPath =
        logicalPath.startsWith('/') ? logicalPath.substring(1) : logicalPath;
    final stopwatch = Stopwatch()..start();
    int attempts = 0;
    bool success = false;

    while (attempts < maxRetries && !success) {
      attempts++;
      try {
        onProgress?.call(0.1);
        await SupabaseInitializer.client.storage
            .from(SupabaseInitializer.defaultBucket)
            .uploadBinary(
              cleanPath,
              Uint8List.fromList(bytes),
              fileOptions: FileOptions(contentType: contentType, upsert: false),
            );
        onProgress?.call(1.0);
        success = true;
      } catch (e) {
        UploadLogger.logRetry(
            path: cleanPath, attempt: attempts, error: e.toString());
        if (attempts >= maxRetries) {
          UploadLogger.logFailure(
              path: cleanPath, reason: e.toString(), attempts: attempts);
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: 300 * attempts));
      }
    }

    stopwatch.stop();
    final publicUrl = SupabaseInitializer.getPublicUrl(cleanPath);
    UploadLogger.logSuccess(
      path: cleanPath,
      sizeBytes: bytes.length,
      duration: stopwatch.elapsed,
      attempts: attempts,
    );
    return publicUrl;
  }

  @override
  Future<String> getPublicUrl(String logicalPath) async {
    return SupabaseInitializer.getPublicUrl(logicalPath);
  }

  @override
  Future<void> deletePath(String logicalPath) async {
    final cleanPath =
        logicalPath.startsWith('/') ? logicalPath.substring(1) : logicalPath;
    await SupabaseInitializer.client.storage
        .from(SupabaseInitializer.defaultBucket)
        .remove([cleanPath]);
    debugPrint(
        '[SupabaseStorageService] Deleted object from Supabase Storage: $cleanPath');
  }

  @override
  Future<void> deleteFileByUrl(String publicUrl) async {
    if (publicUrl.contains(
        '/storage/v1/object/public/${SupabaseInitializer.defaultBucket}/')) {
      final path = publicUrl
          .split(
              '/storage/v1/object/public/${SupabaseInitializer.defaultBucket}/')
          .last;
      await deletePath(path);
    }
  }

  @override
  Future<String> uploadMoviePoster({
    required List<int> bytes,
    required String movieId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  }) {
    FileValidator.validateImage(bytes, extension);
    final ext = _cleanExt(extension);
    final uuid = _generateUuid();
    final path = 'posters/$movieId/$uuid.$ext';
    return uploadPath(
        bytes: bytes,
        logicalPath: path,
        contentType: 'image/jpeg',
        onProgress: onProgress);
  }

  @override
  Future<String> uploadMovieBanner({
    required List<int> bytes,
    required String movieId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  }) {
    FileValidator.validateImage(bytes, extension);
    final ext = _cleanExt(extension);
    final uuid = _generateUuid();
    final path = 'banners/$movieId/$uuid.$ext';
    return uploadPath(
        bytes: bytes,
        logicalPath: path,
        contentType: 'image/jpeg',
        onProgress: onProgress);
  }

  @override
  Future<String> uploadSeriesPoster({
    required List<int> bytes,
    required String seriesId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  }) {
    FileValidator.validateImage(bytes, extension);
    final ext = _cleanExt(extension);
    final uuid = _generateUuid();
    final path = 'posters/series/$seriesId/$uuid.$ext';
    return uploadPath(
        bytes: bytes,
        logicalPath: path,
        contentType: 'image/jpeg',
        onProgress: onProgress);
  }

  @override
  Future<String> uploadSeriesBanner({
    required List<int> bytes,
    required String seriesId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  }) {
    FileValidator.validateImage(bytes, extension);
    final ext = _cleanExt(extension);
    final uuid = _generateUuid();
    final path = 'banners/series/$seriesId/$uuid.$ext';
    return uploadPath(
        bytes: bytes,
        logicalPath: path,
        contentType: 'image/jpeg',
        onProgress: onProgress);
  }

  @override
  Future<String> uploadLogo({
    required List<int> bytes,
    String extension = 'png',
    UploadProgressCallback? onProgress,
  }) {
    FileValidator.validateImage(bytes, extension);
    final ext = _cleanExt(extension);
    final uuid = _generateUuid();
    final path = 'logos/$uuid.$ext';
    return uploadPath(
        bytes: bytes,
        logicalPath: path,
        contentType: 'image/png',
        onProgress: onProgress);
  }

  @override
  Future<String> uploadAvatar({
    required List<int> bytes,
    required String userId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  }) {
    FileValidator.validateImage(bytes, extension);
    final ext = _cleanExt(extension);
    final uuid = _generateUuid();
    final path = 'avatars/$userId/$uuid.$ext';
    return uploadPath(
        bytes: bytes,
        logicalPath: path,
        contentType: 'image/jpeg',
        onProgress: onProgress);
  }

  @override
  Future<String> uploadSubtitle({
    required List<int> bytes,
    required String movieId,
    required String language,
    String extension = 'srt',
    UploadProgressCallback? onProgress,
  }) {
    FileValidator.validateSubtitle(bytes, extension);
    final ext = _cleanExt(extension);
    final path = 'subtitles/$movieId/$language.$ext';
    return uploadPath(
        bytes: bytes,
        logicalPath: path,
        contentType: 'text/plain',
        onProgress: onProgress);
  }

  @override
  Future<String> uploadTrailerThumbnail({
    required List<int> bytes,
    required String movieId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  }) {
    FileValidator.validateImage(bytes, extension);
    final ext = _cleanExt(extension);
    final uuid = _generateUuid();
    final path = 'thumbnails/$movieId/$uuid.$ext';
    return uploadPath(
        bytes: bytes,
        logicalPath: path,
        contentType: 'image/jpeg',
        onProgress: onProgress);
  }

  @override
  Future<String> uploadCategoryIcon({
    required List<int> bytes,
    required String categoryId,
    String extension = 'png',
    UploadProgressCallback? onProgress,
  }) {
    FileValidator.validateImage(bytes, extension);
    final ext = _cleanExt(extension);
    final uuid = _generateUuid();
    final path = 'categories/$categoryId/$uuid.$ext';
    return uploadPath(
        bytes: bytes,
        logicalPath: path,
        contentType: 'image/png',
        onProgress: onProgress);
  }

  @override
  Future<String> replaceFile({
    required String oldPublicUrl,
    required List<int> newBytes,
    required String newLogicalPath,
    String? contentType,
    UploadProgressCallback? onProgress,
  }) async {
    if (oldPublicUrl.isNotEmpty) {
      await deleteFileByUrl(oldPublicUrl);
    }
    return uploadPath(
      bytes: newBytes,
      logicalPath: newLogicalPath,
      contentType: contentType,
      onProgress: onProgress,
    );
  }

  @override
  Future<String> uploadPoster(List<int> bytes, String fileName,
      {String? contentType}) {
    final ext = _cleanExt(fileName);
    final uuid = _generateUuid();
    return uploadPath(
      bytes: bytes,
      logicalPath: 'posters/legacy/$uuid.$ext',
      contentType: contentType ?? 'image/jpeg',
    );
  }

  @override
  Future<String> uploadBanner(List<int> bytes, String fileName,
      {String? contentType}) {
    final ext = _cleanExt(fileName);
    final uuid = _generateUuid();
    return uploadPath(
      bytes: bytes,
      logicalPath: 'banners/legacy/$uuid.$ext',
      contentType: contentType ?? 'image/jpeg',
    );
  }
}

/// Primary StorageService with Singleton/DI access, automated Supabase Storage operations,
/// and backward-compatible local cache operations.
class StorageService {
  static StorageProvider _provider = SupabaseStorageService();
  final Map<String, dynamic> _cache = {};

  static StorageProvider get provider => _provider;

  static void setProvider(StorageProvider provider) {
    _provider = provider;
    debugPrint(
        '[StorageService] Swapped active storage provider to: ${provider.runtimeType}');
  }

  // Automated Upload Methods
  Future<String> uploadMoviePoster({
    required List<int> bytes,
    required String movieId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  }) =>
      _provider.uploadMoviePoster(
          bytes: bytes,
          movieId: movieId,
          extension: extension,
          onProgress: onProgress);

  Future<String> uploadMovieBanner({
    required List<int> bytes,
    required String movieId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  }) =>
      _provider.uploadMovieBanner(
          bytes: bytes,
          movieId: movieId,
          extension: extension,
          onProgress: onProgress);

  Future<String> uploadSeriesPoster({
    required List<int> bytes,
    required String seriesId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  }) =>
      _provider.uploadSeriesPoster(
          bytes: bytes,
          seriesId: seriesId,
          extension: extension,
          onProgress: onProgress);

  Future<String> uploadSeriesBanner({
    required List<int> bytes,
    required String seriesId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  }) =>
      _provider.uploadSeriesBanner(
          bytes: bytes,
          seriesId: seriesId,
          extension: extension,
          onProgress: onProgress);

  Future<String> uploadLogo({
    required List<int> bytes,
    String extension = 'png',
    UploadProgressCallback? onProgress,
  }) =>
      _provider.uploadLogo(
          bytes: bytes, extension: extension, onProgress: onProgress);

  Future<String> uploadAvatar({
    required List<int> bytes,
    required String userId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  }) =>
      _provider.uploadAvatar(
          bytes: bytes,
          userId: userId,
          extension: extension,
          onProgress: onProgress);

  Future<String> uploadSubtitle({
    required List<int> bytes,
    required String movieId,
    required String language,
    String extension = 'srt',
    UploadProgressCallback? onProgress,
  }) =>
      _provider.uploadSubtitle(
          bytes: bytes,
          movieId: movieId,
          language: language,
          extension: extension,
          onProgress: onProgress);

  Future<String> uploadTrailerThumbnail({
    required List<int> bytes,
    required String movieId,
    String extension = 'jpg',
    UploadProgressCallback? onProgress,
  }) =>
      _provider.uploadTrailerThumbnail(
          bytes: bytes,
          movieId: movieId,
          extension: extension,
          onProgress: onProgress);

  Future<String> uploadCategoryIcon({
    required List<int> bytes,
    required String categoryId,
    String extension = 'png',
    UploadProgressCallback? onProgress,
  }) =>
      _provider.uploadCategoryIcon(
          bytes: bytes,
          categoryId: categoryId,
          extension: extension,
          onProgress: onProgress);

  Future<String> replaceFile({
    required String oldPublicUrl,
    required List<int> newBytes,
    required String newLogicalPath,
    String? contentType,
    UploadProgressCallback? onProgress,
  }) =>
      _provider.replaceFile(
        oldPublicUrl: oldPublicUrl,
        newBytes: newBytes,
        newLogicalPath: newLogicalPath,
        contentType: contentType,
        onProgress: onProgress,
      );

  Future<void> deleteFileByUrl(String publicUrl) =>
      _provider.deleteFileByUrl(publicUrl);

  // Backward Compatible Methods
  Future<String> uploadPoster(List<int> bytes, String fileName,
          {String? contentType}) =>
      _provider.uploadPoster(bytes, fileName, contentType: contentType);

  Future<String> uploadBanner(List<int> bytes, String fileName,
          {String? contentType}) =>
      _provider.uploadBanner(bytes, fileName, contentType: contentType);

  Future<void> saveContinueWatching(String movieId, double progress) async {
    _cache['cw_$movieId'] = progress;
  }

  Future<double?> getContinueWatching(String movieId) async {
    return _cache['cw_$movieId'] as double?;
  }

  Future<void> saveAdminConfig(AdminConfig config) async {
    _cache['admin_config'] = config.toJson();
  }

  Future<AdminConfig?> getAdminConfig() async {
    final data = _cache['admin_config'];
    if (data != null && data is Map<String, dynamic>) {
      return AdminConfig.fromJson(data);
    }
    return null;
  }

  Future<void> clearCache() async {
    _cache.clear();
  }
}
