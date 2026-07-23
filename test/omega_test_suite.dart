import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/platform/service_registry.dart';
import 'package:ether_cinema/core/diagnostics/app_diagnostics.dart';

void main() {
  group('Omega Enterprise v5.0 Master Test Suite', () {
    test('ServiceRegistry should list all active registered platform services', () {
      final services = ServiceRegistry.allServices;
      expect(services.isNotEmpty, true);
      expect(services.any((s) => s.name == 'RuntimeOrchestrator'), true);
    });

    test('AppDiagnostics runFullAudit should verify system health status', () {
      final report = AppDiagnostics.runFullAudit();
      expect(report.overallHealth, true);
      expect(report.activeServicesCount >= 6, true);
      expect(report.securityPassed, true);
    });
  });
}
