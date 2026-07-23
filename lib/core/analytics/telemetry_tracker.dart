import '../logging/app_logger.dart';

class TelemetryTracker {
  static final TelemetryTracker _instance = TelemetryTracker._internal();

  factory TelemetryTracker() => _instance;

  TelemetryTracker._internal();

  int _sessionPlaybackCount = 0;
  double _totalBufferDurationSec = 0.0;

  void trackPlaybackSession(String movieId, String videoId, double durationSec) {
    _sessionPlaybackCount++;
    AppLogger.i('Telemetry', 'Playback Session #$_sessionPlaybackCount: Movie $movieId (${durationSec}s) via Dailymotion $videoId');
  }

  void trackBufferDelay(double delaySec) {
    _totalBufferDurationSec += delaySec;
    AppLogger.d('Telemetry', 'Buffer Delay: ${delaySec}s | Cumulative: ${_totalBufferDurationSec}s');
  }

  Map<String, dynamic> getTelemetryDiagnostics() {
    return {
      'session_playbacks': _sessionPlaybackCount,
      'total_buffer_sec': _totalBufferDurationSec,
      'status': 'healthy',
      'target_fps': 120,
    };
  }
}
