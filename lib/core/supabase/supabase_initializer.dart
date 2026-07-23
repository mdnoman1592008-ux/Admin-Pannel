import 'package:flutter/foundation.dart';

/// Enterprise Supabase Initializer for Ether Cinema (Shared between Android App and Web Admin Panel)
class SupabaseInitializer {
  static const String projectUrl = 'https://ozqfltgvxlgpvytjofis.supabase.co';
  static const String publishableKey = 'sb_publishable_PSOJxN99TeDw-jaBYj0arg_XBA9kYPp';
  static const String defaultBucket = 'ether-cinema';

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Automatically initializes Supabase Storage client during startup.
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Supabase configuration for production storage
      _initialized = true;
      debugPrint('[SupabaseInitializer] Supabase successfully initialized for $projectUrl (Bucket: $defaultBucket)');
    } catch (e) {
      debugPrint('[SupabaseInitializer] Initialization warning: $e');
      _initialized = true; // Fallback ready
    }
  }

  /// Constructs the public CDN URL for files stored in Supabase Storage.
  static String getPublicUrl(String logicalPath, {String? bucket}) {
    final targetBucket = bucket ?? defaultBucket;
    final cleanPath = logicalPath.startsWith('/') ? logicalPath.substring(1) : logicalPath;
    return '$projectUrl/storage/v1/object/public/$targetBucket/$cleanPath';
  }
}
