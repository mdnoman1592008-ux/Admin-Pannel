import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Enterprise Supabase Initializer for Ether Cinema Web Admin Panel
class SupabaseInitializer {
  static const String projectUrl = 'https://ozqfltgvxlgpvytjofis.supabase.co';
  static const String publishableKey =
      'sb_publishable_PSOJxN99TeDw-jaBYj0arg_XBA9kYPp';
  static const String defaultBucket = 'ether-cinema';

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await Supabase.initialize(url: projectUrl, anonKey: publishableKey);
      _initialized = true;
      debugPrint(
          '[AdminSupabaseInitializer] Supabase Web Admin initialized for $projectUrl (Bucket: $defaultBucket)');
    } catch (e) {
      debugPrint('[AdminSupabaseInitializer] Initialization warning: $e');
      rethrow;
    }
  }

  static SupabaseClient get client {
    if (!_initialized)
      throw StateError('Supabase must be initialized before use.');
    return Supabase.instance.client;
  }

  static String getPublicUrl(String logicalPath, {String? bucket}) {
    final targetBucket = bucket ?? defaultBucket;
    final cleanPath =
        logicalPath.startsWith('/') ? logicalPath.substring(1) : logicalPath;
    return '$projectUrl/storage/v1/object/public/$targetBucket/$cleanPath';
  }
}
