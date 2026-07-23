import '../logging/app_logger.dart';

class CacheManager {
  static final Map<String, dynamic> _memoryCache = {};
  static const int maxCacheEntries = 100;

  static void put(String key, dynamic value) {
    if (_memoryCache.length >= maxCacheEntries) {
      final firstKey = _memoryCache.keys.first;
      _memoryCache.remove(firstKey);
      AppLogger.d('CacheManager', 'Evicted oldest key: $firstKey');
    }
    _memoryCache[key] = value;
  }

  static dynamic get(String key) {
    return _memoryCache[key];
  }

  static void clearAll() {
    _memoryCache.clear();
    AppLogger.i('CacheManager', 'Cache cleared.');
  }
}
