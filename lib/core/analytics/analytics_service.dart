import '../logging/app_logger.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() => _instance;

  AnalyticsService._internal();

  void logEvent(String eventName, [Map<String, dynamic>? parameters]) {
    AppLogger.i('Analytics', 'Event: $eventName | Params: ${parameters ?? {}}');
  }

  void trackMovieView(String movieId, String title) {
    logEvent('view_movie', {'id': movieId, 'title': title});
  }

  void trackPlaybackStart(String videoId, String title) {
    logEvent('start_playback', {'dailymotion_id': videoId, 'title': title});
  }

  void trackAdminAction(String actionName) {
    logEvent('admin_action', {'action': actionName});
  }
}
