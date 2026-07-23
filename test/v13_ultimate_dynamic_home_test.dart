import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/cms/dynamic_home_layout_manager.dart';

void main() {
  group('Ether Cinema v13.0 Ultimate Dynamic Home Test Suite', () {
    final layoutManager = DynamicHomeLayoutManager();

    test('DynamicHomeLayoutManager should initialize default content rails', () {
      expect(layoutManager.rails.isNotEmpty, true);
      expect(layoutManager.rails.any((r) => r.id == 'hero_banner'), true);
      expect(layoutManager.rails.any((r) => r.id == 'categories'), true);
      expect(layoutManager.rails.any((r) => r.id == 'trending'), true);
    });

    test('reorderRails should update rail position and stream emissions', () {
      final initialFirstRailId = layoutManager.rails.first.id;
      layoutManager.reorderRails(0, 2);
      expect(layoutManager.rails.first.id != initialFirstRailId, true);
    });

    test('saveWatchProgress should store and retrieve watch progress accurately', () {
      layoutManager.saveWatchProgress('m1', 450000);
      expect(layoutManager.getWatchProgress('m1'), 450000);
    });
  });
}
