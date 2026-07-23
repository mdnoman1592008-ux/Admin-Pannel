import '../logging/app_logger.dart';

class FeatureFlagService {
  static final Map<String, bool> _flags = {
    'experimental_3d_glass': true,
    'smart_resume_player': true,
    'hyperscale_telemetry': true,
    'ai_search_suggestions': false,
    'pip_mode_enabled': true,
  };

  static bool isEnabled(String flagKey) {
    return _flags[flagKey] ?? false;
  }

  static void setFlag(String flagKey, bool value) {
    _flags[flagKey] = value;
    AppLogger.i('FeatureFlagService', 'Feature Flag [$flagKey] set to: $value');
  }

  static Map<String, bool> getAllFlags() {
    return Map.unmodifiable(_flags);
  }
}
