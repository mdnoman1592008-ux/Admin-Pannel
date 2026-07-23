import 'package:flutter/material.dart';
import '../../core/admin_storage_service.dart';
import '../../core/backend/backend_service.dart';
import '../../core/supabase_initializer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';

/// Live Storage Screen — Supabase Storage Explorer
class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final _backend = LiveBackendService.instance;
  final _storage = AdminStorageService();
  bool _uploading = false;
  String _uploadStatus = '';
  String _lastUrl = '';

  Future<void> _handleUpload(String type) async {
    setState(() {
      _uploading = true;
      _uploadStatus = 'Uploading $type to Supabase bucket "${SupabaseInitializer.defaultBucket}"...';
      _lastUrl = '';
    });

    final bytes = List.generate(128, (i) => i % 256);
    String url = '';

    if (type == 'Poster') {
      url = await _storage.uploadMoviePoster(
        bytes: bytes,
        movieId: 'm_${DateTime.now().millisecondsSinceEpoch}',
      );
    } else if (type == 'Banner') {
      url = await _storage.uploadMovieBanner(
        bytes: bytes,
        movieId: 'm_${DateTime.now().millisecondsSinceEpoch}',
      );
    } else if (type == 'Avatar') {
      url = await _storage.uploadAvatar(
        bytes: bytes,
        userId: 'u_${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    _backend.recordStorageUpload(LiveStorageFile(
      name: '${type.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      path: url,
      sizeBytes: bytes.length,
      folder: type.toLowerCase(),
      uploadedAt: DateTime.now(),
    ));

    setState(() {
      _uploading = false;
      _uploadStatus = 'Upload successful!';
      _lastUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _backend,
      builder: (context, _) {
        final files = _backend.storageFiles;

        return Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildToolbar(),
              const SizedBox(height: 12),
              if (_uploading || _lastUrl.isNotEmpty) ...[
                _buildUploadBanner(),
                const SizedBox(height: 12),
              ],
              Expanded(child: _buildFileList(files)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolbar() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.cloud_done_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Text('Supabase Storage Bucket: "${SupabaseInitializer.defaultBucket}"', style: AppTextStyles.h3()),
          const Spacer(),
          GlowButton(
            label: 'Upload Poster',
            icon: Icons.movie_rounded,
            color: AppColors.primary,
            isSmall: true,
            onPressed: () => _handleUpload('Poster'),
          ),
          const SizedBox(width: 8),
          GlowButton(
            label: 'Upload Banner',
            icon: Icons.view_carousel_rounded,
            color: AppColors.secondary,
            textColor: Colors.white,
            isSmall: true,
            onPressed: () => _handleUpload('Banner'),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBanner() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_uploading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                )
              else
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
              const SizedBox(width: 10),
              Text(_uploadStatus, style: AppTextStyles.h4().copyWith(fontSize: 13)),
            ],
          ),
          if (_lastUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            SelectableText(_lastUrl, style: AppTextStyles.monoSm()),
          ],
        ],
      ),
    );
  }

  Widget _buildFileList(List<LiveStorageFile> files) {
    if (files.isEmpty) {
      return GlassCard(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 48),
              const SizedBox(height: 16),
              Text('No media objects uploaded to Supabase Storage bucket "${SupabaseInitializer.defaultBucket}"',
                  style: AppTextStyles.h3()),
              const SizedBox(height: 8),
              Text('Use the upload buttons above to upload live media assets to Supabase CDN.',
                  style: AppTextStyles.bodySm()),
            ],
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Supabase Storage Files', style: AppTextStyles.h3()),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: files.length,
              separatorBuilder: (_, __) => Container(height: 1, color: AppColors.glassBorder),
              itemBuilder: (_, i) {
                final file = files[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.image_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(file.name, style: AppTextStyles.h4()),
                            SelectableText(file.path, style: AppTextStyles.monoSm()),
                          ],
                        ),
                      ),
                      Text('${file.sizeBytes} bytes', style: AppTextStyles.bodySm()),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
