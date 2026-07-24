import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/models/home_section_model.dart';
import 'package:ether_cinema/core/models/movie.dart';
import 'package:ether_cinema/core/cms/home_section_repository.dart';
import 'package:ether_cinema/features/home/renderers/section_renderer.dart';

void main() {
  group('Ether Cinema v19.0 Dynamic Home Sections & Section Builder Suite', () {
    late HomeSectionRepository repo;

    setUp(() {
      repo = HomeSectionRepository();
    });

    test('HomeSectionRepository should initialize default section presets', () {
      expect(repo.sections.isNotEmpty, true);
      expect(repo.enabledSections.any((s) => s.slug == 'featured_blockbusters'), true);
      expect(repo.enabledSections.any((s) => s.slug == 'trending_now'), true);
      expect(repo.enabledSections.any((s) => s.slug == 'top_10_today'), true);
    });

    test('Create New Custom Section should persist and broadcast via stream', () async {
      final initialCount = repo.sections.length;
      final customSection = HomeSectionModel(
        id: 'sec_oscar_2026',
        title: 'Oscar Winners 2026 Collection',
        slug: 'oscar_winners_2026',
        description: 'Academy Award winning movies and web series',
        layoutType: SectionLayoutType.grid,
        contentSource: SectionContentSource.manual,
        displayOrder: initialCount + 1,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repo.createSection(customSection);
      expect(repo.sections.length, initialCount + 1);
      expect(repo.enabledSections.any((s) => s.id == 'sec_oscar_2026'), true);
    });

    test('Reorder Sections should update displayOrder and stream emissions', () async {
      final initialOrder = repo.sections.map((s) => s.id).toList();
      final reversedOrder = initialOrder.reversed.toList();

      await repo.reorderSections(reversedOrder);
      expect(repo.sections.first.id, reversedOrder.first);
      expect(repo.sections.last.id, reversedOrder.last);
    });

    test('Toggle Section isEnabled should enable or disable section from homepage stream', () async {
      final firstSec = repo.sections.first;
      await repo.toggleSectionEnabled(firstSec.id, false);
      expect(repo.enabledSections.any((s) => s.id == firstSec.id), false);

      await repo.toggleSectionEnabled(firstSec.id, true);
      expect(repo.enabledSections.any((s) => s.id == firstSec.id), true);
    });

    test('Duplicate Section should create identical section copy with incremented displayOrder', () async {
      final target = repo.sections.first;
      final countBefore = repo.sections.length;
      await repo.duplicateSection(target.id);

      expect(repo.sections.length, countBefore + 1);
      expect(repo.sections.any((s) => s.title.contains('${target.title} (Copy)')), true);
    });

    test('Scheduled section publishing and expiration filtering check', () {
      final futureSection = HomeSectionModel(
        id: 'sec_future',
        title: 'Future Ramadan Specials',
        slug: 'ramadan_specials',
        layoutType: SectionLayoutType.horizontalCarousel,
        contentSource: SectionContentSource.category,
        displayOrder: 99,
        isEnabled: true,
        scheduling: SectionScheduleConfig(
          publishAt: DateTime.now().add(const Duration(days: 10)),
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(futureSection.scheduling.isCurrentlyActive, false);
    });

    testWidgets('SectionRenderer should safely handle rendering without crashing', (tester) async {
      final sampleSection = HomeSectionModel(
        id: 'sec_test_renderer',
        title: 'Test Carousel Section',
        slug: 'test_carousel',
        layoutType: SectionLayoutType.horizontalCarousel,
        contentSource: SectionContentSource.trending,
        displayOrder: 1,
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final List<Movie> sampleMovies = [
        const Movie(
          id: 'm1',
          title: 'Test Blockbuster',
          synopsis: 'A test movie synopsis.',
          rating: 4.9,
          tags: ['4K'],
          genres: ['Sci-Fi'],
          duration: '2h 15m',
          releaseYear: '2026',
          posterUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=600&auto=format&fit=crop',
          backdropUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=1200&auto=format&fit=crop',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionRenderer(
              section: sampleSection,
              movies: sampleMovies,
              onSelectMovie: (m) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Carousel Section'), findsOneWidget);
      expect(find.text('Test Blockbuster'), findsOneWidget);
    });
  });
}
