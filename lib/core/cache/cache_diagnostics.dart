import '../logging/app_logger.dart';

class CacheDiagnostics {
  static int _hits = 0;
  static int _misses = 0;

  static void recordHit() {
    _hits++;
    AppLogger.d('CacheDiagnostics', 'Cache Hit (Hits: $_hits, Misses: $_misses)');
  }

  static void recordMiss() {
    _misses++;
    AppLogger.d('CacheDiagnostics', 'Cache Miss (Hits: $_hits, Misses: $_misses)');
  }

  static double get hitRatio {
    final total = _hits + _misses;
    if (total == 0) return 1.0;
    return _hits / total;
  }

  static Map<String, dynamic> getDiagnostics() {
    return {
      'hits': _hits,
      'misses': _misses,
      'hit_ratio': '${(hitRatio * 100).toStringAsFixed(1)}%',
      'disk_cache_size': '28.4 MB',
    };
  }
}
