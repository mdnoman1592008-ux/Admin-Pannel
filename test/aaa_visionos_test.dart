import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/theme/app_colors.dart';
import 'package:ether_cinema/core/performance/performance_monitor.dart';

void main() {
  group('Ether Cinema v10.0 AAA VisionOS Test Suite', () {
    test('VisionOS Theme System Color Tokens', () {
      expect(AppColors.background.value, 0xFF050505);
      expect(AppColors.surface.value, 0xFF131313);
      expect(AppColors.surfaceContainerLow.value, 0xFF1C1B1B);
      expect(AppColors.primaryContainer.value, 0xFF00D4FF);
    });

    test('Performance Monitor 120 FPS Target', () {
      PerformanceMonitor.recordFrame(8.33);
      final metrics = PerformanceMonitor.getMetrics();
      expect(metrics.averageFps > 115, true);
    });
  });
}
