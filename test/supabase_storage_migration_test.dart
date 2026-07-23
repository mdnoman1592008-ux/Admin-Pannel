import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/supabase/supabase_initializer.dart';
import 'package:ether_cinema/core/services/storage_service.dart';
import 'package:ether_cinema/core/repositories/movie_repository.dart';
import 'package:ether_cinema/core/repositories/series_repository.dart';
import 'package:ether_cinema/core/repositories/profile_repository.dart';
import 'package:ether_cinema/core/repositories/settings_repository.dart';
import 'package:ether_cinema/core/repositories/banner_repository.dart';
import 'package:ether_cinema/core/repositories/category_repository.dart';

void main() {
  group('Enterprise Supabase Storage Migration Test Suite', () {
    final storageService = StorageService();

    test('SupabaseInitializer should initialize project URL and publishable key', () async {
      await SupabaseInitializer.initialize();
      expect(SupabaseInitializer.isInitialized, true);
      expect(SupabaseInitializer.projectUrl, 'https://ozqfltgvxlgpvytjofis.supabase.co');
      expect(SupabaseInitializer.publishableKey, 'sb_publishable_PSOJxN99TeDw-jaBYj0arg_XBA9kYPp');

      final publicUrl = SupabaseInitializer.getPublicUrl('posters/m1/uuid.jpg');
      expect(
        publicUrl,
        'https://ozqfltgvxlgpvytjofis.supabase.co/storage/v1/object/public/ether-cinema/posters/m1/uuid.jpg',
      );
    });

    test('FileValidator should accept valid image & subtitle extensions and reject invalid ones', () {
      final validImageBytes = [1, 2, 3, 4];
      expect(() => FileValidator.validateImage(validImageBytes, 'jpg'), returnsNormally);
      expect(() => FileValidator.validateImage(validImageBytes, 'webp'), returnsNormally);
      expect(() => FileValidator.validateImage(validImageBytes, 'png'), returnsNormally);
      expect(() => FileValidator.validateImage(validImageBytes, 'exe'), throwsFormatException);

      final validSubBytes = [83, 82, 84];
      expect(() => FileValidator.validateSubtitle(validSubBytes, 'srt'), returnsNormally);
      expect(() => FileValidator.validateSubtitle(validSubBytes, 'vtt'), returnsNormally);
      expect(() => FileValidator.validateSubtitle(validSubBytes, 'txt'), throwsFormatException);
    });

    test('UploadLogger should log upload events and metrics', () async {
      final dummyBytes = [1, 2, 3, 4];
      await storageService.uploadMoviePoster(bytes: dummyBytes, movieId: 'log_m1');
      expect(UploadLogger.logs.isNotEmpty, true);
      expect(UploadLogger.logs.first.contains('UPLOAD_SUCCESS'), true);
    });

    test('Automated Upload Types should format logical paths correctly on bucket "ether-cinema"', () async {
      final dummyBytes = [255, 216, 255, 224];

      final moviePoster = await storageService.uploadMoviePoster(bytes: dummyBytes, movieId: 'm100');
      expect(moviePoster.contains('ether-cinema/posters/m100/'), true);

      final movieBanner = await storageService.uploadMovieBanner(bytes: dummyBytes, movieId: 'm100');
      expect(movieBanner.contains('ether-cinema/banners/m100/'), true);

      final seriesPoster = await storageService.uploadSeriesPoster(bytes: dummyBytes, seriesId: 's200');
      expect(seriesPoster.contains('ether-cinema/posters/series/s200/'), true);

      final seriesBanner = await storageService.uploadSeriesBanner(bytes: dummyBytes, seriesId: 's200');
      expect(seriesBanner.contains('ether-cinema/banners/series/s200/'), true);

      final avatar = await storageService.uploadAvatar(bytes: dummyBytes, userId: 'u500');
      expect(avatar.contains('ether-cinema/avatars/u500/'), true);

      final subtitle = await storageService.uploadSubtitle(
          bytes: [83, 82, 84], movieId: 'm100', language: 'en', extension: 'srt');
      expect(subtitle.contains('ether-cinema/subtitles/m100/en.srt'), true);

      final thumbnail = await storageService.uploadTrailerThumbnail(bytes: dummyBytes, movieId: 'm100');
      expect(thumbnail.contains('ether-cinema/thumbnails/m100/'), true);

      final categoryIcon = await storageService.uploadCategoryIcon(bytes: dummyBytes, categoryId: 'cat_scifi');
      expect(categoryIcon.contains('ether-cinema/categories/cat_scifi/'), true);

      final logo = await storageService.uploadLogo(bytes: dummyBytes);
      expect(logo.contains('ether-cinema/logos/'), true);
    });

    test('Enterprise Repositories should update Firestore with ONLY Public URLs', () async {
      final dummyBytes = [1, 2, 3, 4];

      final movieRepo = EnterpriseMovieRepository();
      final posterUrl = await movieRepo.updateMoviePoster(movieId: 'm1', imageBytes: dummyBytes);
      expect(posterUrl.startsWith('https://ozqfltgvxlgpvytjofis.supabase.co'), true);
      expect(movieRepo.firestoreUrls['movie_m1_posterUrl'], posterUrl);

      final seriesRepo = EnterpriseSeriesRepository();
      final seriesUrl = await seriesRepo.updateSeriesPoster(seriesId: 's1', imageBytes: dummyBytes);
      expect(seriesUrl.startsWith('https://ozqfltgvxlgpvytjofis.supabase.co'), true);
      expect(seriesRepo.firestoreUrls['series_s1_posterUrl'], seriesUrl);

      final profileRepo = EnterpriseProfileRepository();
      final avatarUrl = await profileRepo.updateAvatarUrl(userId: 'u1', avatarBytes: dummyBytes);
      expect(avatarUrl.startsWith('https://ozqfltgvxlgpvytjofis.supabase.co'), true);
      expect(profileRepo.firestoreUrls['user_u1_avatarUrl'], avatarUrl);

      final settingsRepo = EnterpriseSettingsRepository();
      final logoUrl = await settingsRepo.updateAppLogoUrl(logoBytes: dummyBytes);
      expect(logoUrl.startsWith('https://ozqfltgvxlgpvytjofis.supabase.co'), true);
      expect(settingsRepo.firestoreUrls['app_logoUrl'], logoUrl);

      final bannerRepo = EnterpriseBannerRepository();
      final bannerUrl = await bannerRepo.updateHeroBannerUrl(bannerId: 'b1', bannerBytes: dummyBytes);
      expect(bannerUrl.startsWith('https://ozqfltgvxlgpvytjofis.supabase.co'), true);
      expect(bannerRepo.firestoreUrls['banner_b1_imageUrl'], bannerUrl);

      final categoryRepo = EnterpriseCategoryRepository();
      final catUrl = await categoryRepo.updateCategoryIconUrl(categoryId: 'c1', iconBytes: dummyBytes);
      expect(catUrl.startsWith('https://ozqfltgvxlgpvytjofis.supabase.co'), true);
      expect(categoryRepo.firestoreUrls['category_c1_iconUrl'], catUrl);
    });
  });
}
