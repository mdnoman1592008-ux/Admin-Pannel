import '../logging/app_logger.dart';

class ServiceInfo {
  final String name;
  final String version;
  final bool isHealthy;

  const ServiceInfo({
    required this.name,
    required this.version,
    required this.isHealthy,
  });
}

class ServiceRegistry {
  static final Map<String, ServiceInfo> _registry = {};

  static void register(String name, String version, {bool isHealthy = true}) {
    _registry[name] = ServiceInfo(name: name, version: version, isHealthy: isHealthy);
    AppLogger.d('ServiceRegistry', 'Registered service: $name (v$version)');
  }

  static ServiceInfo? getService(String name) => _registry[name];

  static List<ServiceInfo> get allServices {
    if (_registry.isEmpty) {
      // Auto-register core platform services
      register('RuntimeOrchestrator', '4.0.0');
      register('TelemetryTracker', '2.3.0');
      register('CacheDiagnostics', '2.3.0');
      register('SecurityPlatform', '3.0.0');
      register('PerformanceMonitor', '3.5.0');
      register('FeatureFlagService', '3.5.0');
    }
    return _registry.values.toList();
  }
}
