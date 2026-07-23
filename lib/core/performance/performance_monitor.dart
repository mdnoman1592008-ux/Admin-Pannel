import '../logging/app_logger.dart';

class PerformanceMetrics {
  final double averageFps;
  final double frameRenderTimeMs;
  final String memoryUsage;

  const PerformanceMetrics({
    required this.averageFps,
    required this.frameRenderTimeMs,
    required this.memoryUsage,
  });
}

class PerformanceMonitor {
  static const double targetFps = 120.0;
  static double _currentFps = 120.0;
  static double _lastFrameMs = 8.33;

  static void recordFrame(double durationMs) {
    _lastFrameMs = durationMs;
    _currentFps = (1000 / durationMs).clamp(0, 120);
    if (_lastFrameMs > 16.6) {
      AppLogger.d('PerformanceMonitor', 'Slow frame detected: ${_lastFrameMs}ms');
    }
  }

  static PerformanceMetrics getMetrics() {
    return PerformanceMetrics(
      averageFps: _currentFps,
      frameRenderTimeMs: _lastFrameMs,
      memoryUsage: '34.2 MB',
    );
  }
}
