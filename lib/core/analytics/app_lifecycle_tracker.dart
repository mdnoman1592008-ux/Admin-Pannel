import '../logging/app_logger.dart';

class AppLifecycleTracker {
  static final AppLifecycleTracker _instance = AppLifecycleTracker._internal();

  factory AppLifecycleTracker() => _instance;

  AppLifecycleTracker._internal();

  final List<String> _diagnosticTimeline = [];

  void logLifecycleEvent(String state) {
    final entry = '[${DateTime.now().toIso8601String().substring(11, 19)}] App State: $state';
    _diagnosticTimeline.add(entry);
    AppLogger.i('AppLifecycle', entry);
  }

  void logFrameMetrics(double fps, double frameTimeMs) {
    if (frameTimeMs > 16.6) {
      AppLogger.d('Observability', 'Jank detected: ${frameTimeMs}ms ($fps FPS target: 120)');
    }
  }

  List<String> get diagnosticTimeline => List.unmodifiable(_diagnosticTimeline);
}
