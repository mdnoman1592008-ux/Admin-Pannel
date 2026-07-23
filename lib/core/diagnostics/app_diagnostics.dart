import '../performance/performance_monitor.dart';
import '../cache/cache_diagnostics.dart';
import '../platform/service_registry.dart';
import '../security/security_service.dart';

class SystemAuditReport {
  final bool overallHealth;
  final int activeServicesCount;
  final String hitRatio;
  final double averageFps;
  final bool securityPassed;

  const SystemAuditReport({
    required this.overallHealth,
    required this.activeServicesCount,
    required this.hitRatio,
    required this.averageFps,
    required this.securityPassed,
  });
}

class AppDiagnostics {
  static SystemAuditReport runFullAudit() {
    final services = ServiceRegistry.allServices;
    final cacheStats = CacheDiagnostics.getDiagnostics();
    final perf = PerformanceMonitor.getMetrics();
    final secPassed = SecurityService.performSecurityAudit();

    return SystemAuditReport(
      overallHealth: services.every((s) => s.isHealthy) && secPassed,
      activeServicesCount: services.length,
      hitRatio: cacheStats['hit_ratio'] as String,
      averageFps: perf.averageFps,
      securityPassed: secPassed,
    );
  }
}
