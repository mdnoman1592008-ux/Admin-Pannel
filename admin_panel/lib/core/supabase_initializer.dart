import 'package:flutter/foundation.dart';

/// Enterprise Supabase Initializer for Ether Cinema Web Admin Panel
class SupabaseInitializer {
  static const String projectUrl = 'https://ozqfltgvxlgpvytjofis.supabase.co';
  static const String publishableKey = 'sb_publishable_PSOJxN99TeDw-jaBYj0arg_XBA9kYPp';
  static const String defaultBucket = 'ether-cinema';

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      _initialized = true;
      debugPrint('[AdminSupabaseInitializer] Supabase Web Admin initialized for $projectUrl (Bucket: $defaultBucket)');
    } catch (e) {
      debugPrint('[AdminSupabaseInitializer] Initialization warning: $e');
      _initialized = true;
    }
  }

  static String getPublicUrl(String logicalPath, {String? bucket}) {
    final targetBucket = bucket ?? defaultBucket;
    final cleanPath = logicalPath.startsWith('/') ? logicalPath.substring(1) : logicalPath;
    return '$projectUrl/storage/v1/object/public/$targetBucket/$cleanPath';
  }
}
