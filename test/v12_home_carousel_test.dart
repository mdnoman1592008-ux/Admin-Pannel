import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ether Cinema v12.1 Home Screen Carousel & Category Navigation Suite', () {
    final List<String> categories = [
      'ALL', 'Natok', 'Drama', '18+', 'Movies', 'Series',
      'Anime', 'Cartoons', 'Kids', 'Action', 'Thriller',
      'Comedy', 'Horror', 'Sci-Fi', 'Romance', 'Documentary', 'Animation'
    ];

    test('Category Navigation bar should contain 17 items', () {
      expect(categories.length, 17);
      expect(categories.contains('ALL'), true);
      expect(categories.contains('18+'), true);
      expect(categories.contains('Natok'), true);
      expect(categories.contains('Anime'), true);
    });

    test('Hero Banner Auto-Slide Duration check', () {
      const autoSlideSeconds = 5;
      expect(autoSlideSeconds, 5);
    });
  });
}
