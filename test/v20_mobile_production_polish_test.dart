import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/downloads/encrypted_download_manager.dart';
import 'package:ether_cinema/features/downloads/downloads_screen.dart';
import 'package:ether_cinema/core/models/movie.dart';
import 'package:ether_cinema/features/player/dailymotion_player_view.dart';

void main() {
  group('Ether Cinema v20.0 Mobile Production Polish & Premium Experience Suite', () {
    test('EncryptedDownloadManager task state transition operations', () {
      // Start new download task
      EncryptedDownloadManager.startEncryptedDownload('m100', 'Quantum Abyss 4K', quality: '4K HDR');
      expect(EncryptedDownloadManager.activeQueue.any((t) => t.title == 'Quantum Abyss 4K'), true);

      final task = EncryptedDownloadManager.activeQueue.firstWhere((t) => t.title == 'Quantum Abyss 4K');

      // Pause task
      final paused = EncryptedDownloadManager.pauseDownload(task.id);
      expect(paused, true);
      expect(EncryptedDownloadManager.activeQueue.firstWhere((t) => t.id == task.id).status, DownloadStatus.paused);

      // Resume task
      final resumed = EncryptedDownloadManager.resumeDownload(task.id);
      expect(resumed, true);
      expect(EncryptedDownloadManager.activeQueue.firstWhere((t) => t.id == task.id).status, DownloadStatus.downloading);

      // Delete task
      final deleted = EncryptedDownloadManager.deleteDownload(task.id);
      expect(deleted, true);
      expect(EncryptedDownloadManager.activeQueue.any((t) => t.id == task.id), false);
    });

    testWidgets('DownloadsScreen should render header and filter chips cleanly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DownloadsScreen(),
        ),
      );

      expect(find.text('Offline Downloads'), findsOneWidget);
      expect(find.text('Downloaded movies and episodes for offline viewing'), findsOneWidget);
      expect(find.text('ALL'), findsOneWidget);
      expect(find.text('DOWNLOADING'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
    });

    testWidgets('DailymotionPlayerView should render interactive player controls cleanly', (tester) async {
      const sampleMovie = Movie(
        id: 'm_test_player',
        title: 'Cyberpunk 2099',
        synopsis: 'A test cyberpunk movie.',
        rating: 4.9,
        tags: ['4K', 'HDR'],
        genres: ['Sci-Fi'],
        duration: '2h 15m',
        releaseYear: '2026',
        posterUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=600&auto=format&fit=crop',
        backdropUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=1200&auto=format&fit=crop',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DailymotionPlayerView(
              movie: sampleMovie,
              onClose: () {},
            ),
          ),
        ),
      );

      expect(find.text('Cyberpunk 2099'), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsWidgets);
    });
  });
}
