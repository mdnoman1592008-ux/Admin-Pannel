class MediaValidationResult {
  final bool isValid;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  const MediaValidationResult._({
    required this.isValid,
    this.errorMessage,
    required this.metadata,
  });

  factory MediaValidationResult.success([Map<String, dynamic>? metadata]) =>
      MediaValidationResult._(
        isValid: true,
        metadata: metadata ?? {},
      );

  factory MediaValidationResult.error(String message) =>
      MediaValidationResult._(
        isValid: false,
        errorMessage: message,
        metadata: {},
      );
}

/// Pre-Flight Media Asset & Subtitle Validator
class MediaValidationService {
  static const int maxPosterSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const int maxBannerSizeBytes = 10 * 1024 * 1024; // 10 MB

  /// Validate Poster Asset
  static MediaValidationResult validatePoster({
    required List<int> bytes,
    required String fileName,
  }) {
    if (bytes.isEmpty) {
      return MediaValidationResult.error('File bytes cannot be empty.');
    }

    if (bytes.length > maxPosterSizeBytes) {
      return MediaValidationResult.error(
        'Poster image size exceeds 5MB maximum limit (Current: ${(bytes.length / (1024 * 1024)).toStringAsFixed(1)}MB).',
      );
    }

    final ext = fileName.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
      return MediaValidationResult.error(
        'Unsupported image extension ". $ext". Allowed: .jpg, .png, .webp',
      );
    }

    return MediaValidationResult.success({
      'sizeBytes': bytes.length,
      'extension': ext,
      'aspectRatio': '2:3 Poster Standard',
    });
  }

  /// Validate Subtitle File
  static MediaValidationResult validateSubtitle({
    required String fileName,
    required List<int> bytes,
  }) {
    if (bytes.isEmpty) {
      return MediaValidationResult.error('Subtitle file cannot be empty.');
    }

    final ext = fileName.split('.').last.toLowerCase();
    if (ext != 'vtt' && ext != 'srt') {
      return MediaValidationResult.error(
        'Invalid subtitle file format ".$ext". Only WebVTT (.vtt) and SubRip (.srt) formats are supported.',
      );
    }

    return MediaValidationResult.success({
      'format': ext.toUpperCase(),
      'sizeBytes': bytes.length,
    });
  }
}
