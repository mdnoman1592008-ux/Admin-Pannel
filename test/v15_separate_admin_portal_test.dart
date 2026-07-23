import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ether Cinema v15.0 Separate Enterprise Admin Portal Architecture Suite', () {
    test('Independent admin_panel directory should exist in repository root', () {
      final adminPanelDir = Directory('admin_panel');
      expect(adminPanelDir.existsSync(), true);
    });

    test('admin_panel pubspec.yaml should define ether_cinema_admin_panel project', () {
      final pubspecFile = File('admin_panel/pubspec.yaml');
      expect(pubspecFile.existsSync(), true);
      final content = pubspecFile.readAsStringSync();
      expect(content.contains('ether_cinema_admin_panel'), true);
    });

    test('admin_panel main.dart should exist for standalone Flutter Web compilation', () {
      final mainFile = File('admin_panel/lib/main.dart');
      expect(mainFile.existsSync(), true);
    });
  });
}
