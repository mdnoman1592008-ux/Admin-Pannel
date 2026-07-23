import '../logging/app_logger.dart';

class SmartCacheEngine {
  static final Map<String, dynamic> _priorityCache = {};
  static final List<String> _prefetchQueue = [];

  static void schedulePrefetch(String movieId) {
    if (!_prefetchQueue.contains(movieId)) {
      _prefetchQueue.add(movieId);
      AppLogger.d('SmartCacheEngine', 'Scheduled prefetch for movie: $movieId');
    }
  }

  static void cacheMetadata(String id, Map<String, dynamic> metadata) {
    _priorityCache[id] = metadata;
    AppLogger.d('SmartCacheEngine', 'Cached priority metadata for: $id');
  }

  static Map<String, dynamic>? getMetadata(String id) {
    return _priorityCache[id] as Map<String, dynamic>?;
  }
}
