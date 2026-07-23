import 'package:flutter/material.dart';
import '../../core/admin_storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';

/// Storage Screen — Supabase Storage Explorer
class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final _storage = AdminStorageService();
  String _selectedFolder = 'posters';
  String _uploadStatus = '';
  double _uploadProgress = 0;
  bool _uploading = false;
  String _lastUrl = '';

  final _folders = [
    _Folder('posters', Icons.movie_rounded, AppColors.primary, '2.4 GB', 1248),
    _Folder('banners', Icons.view_carousel_rounded, AppColors.secondary, '890 MB', 324),
    _Folder('avatars', Icons.person_rounded, AppColors.accent, '156 MB', 94721),
    _Folder('logos', Icons.stars_rounded, AppColors.gold, '12 MB', 48),
    _Folder('subtitles', Icons.subtitles_rounded, AppColors.success, '48 MB', 3842),
  ];

  Future<void> _testUpload(String type) async {
    setState(() {
      _uploading = true;
      _uploadProgress = 0;
      _uploadStatus = 'Uploading $type...';
      _lastUrl = '';
    });

    final dummyBytes = List.generate(128, (i) => i % 256);
    String url = '';

    void progress(double p) => setState(() => _uploadProgress = p);

    if (type == 'Movie Poster') {
      url = await _storage.uploadMoviePoster(
          bytes: dummyBytes, movieId: 'm${DateTime.now().millisecondsSinceEpoch}',
          onProgress: progress);
    } else if (type == 'Movie Banner') {
      url = await _storage.uploadMovieBanner(
          bytes: dummyBytes, movieId: 'm${DateTime.now().millisecondsSinceEpoch}',
          onProgress: progress);
    } else if (type == 'Avatar') {
      url = await _storage.uploadAvatar(
          bytes: dummyBytes, userId: 'u${DateTime.now().millisecondsSinceEpoch}',
          onProgress: progress);
    } else if (type == 'Logo') {
      url = await _storage.uploadLogo(bytes: dummyBytes, onProgress: progress);
    } else if (type == 'Subtitle') {
      url = await _storage.uploadSubtitle(
          bytes: dummyBytes, movieId: 'm101', language: 'en',
          onProgress: progress);
    }

    setState(() {
      _uploading = false;
      _uploadProgress = 1.0;
      _uploadStatus = '$type uploaded successfully!';
      _lastUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Folder tree
          SizedBox(width: 260, child: _buildFolderTree()),
          const SizedBox(width: 16),
          // Content area
          Expanded(child: _buildContentArea()),
        ],
      ),
    );
  }

  Widget _buildFolderTree() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.cloud_done_rounded,
                      color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ether-cinema', style: AppTextStyles.h4()),
                    Text('Supabase Storage',
                        style: AppTextStyles.bodySm().copyWith(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.glassBorder),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              children: _folders.map((f) {
                final isSelected = _selectedFolder == f.name;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFolder = f.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? f.color.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      border: isSelected
                          ? Border.all(color: f.color.withOpacity(0.3))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(f.icon,
                            size: 16,
                            color: isSelected ? f.color : AppColors.textSecond),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f.name,
                                  style: isSelected
                                      ? AppTextStyles.navItemActive().copyWith(
                                          color: f.color)
                                      : AppTextStyles.navItem()),
                              Text('${f.count} files · ${f.size}',
                                  style: AppTextStyles.bodySm()
                                      .copyWith(fontSize: 10)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(height: 1, color: AppColors.glassBorder),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('3.5 GB of 10 GB used',
                    style: AppTextStyles.bodySm()),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.glassBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.35,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    final folder = _folders.firstWhere((f) => f.name == _selectedFolder);

    return Column(
      children: [
        // Toolbar
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(folder.icon, color: folder.color, size: 20),
              const SizedBox(width: 10),
              Text('/$_selectedFolder',
                  style: AppTextStyles.mono().copyWith(color: folder.color)),
              const SizedBox(width: 12),
              Text('${folder.count} files · ${folder.size}',
                  style: AppTextStyles.bodySm()),
              const Spacer(),
              GlowButton(
                label: 'Upload Poster',
                icon: Icons.movie_rounded,
                color: AppColors.primary,
                isSmall: true,
                onPressed: () => _testUpload('Movie Poster'),
              ),
              const SizedBox(width: 8),
              GlowButton(
                label: 'Upload Banner',
                icon: Icons.view_carousel_rounded,
                color: AppColors.secondary,
                textColor: Colors.white,
                isSmall: true,
                onPressed: () => _testUpload('Movie Banner'),
              ),
              const SizedBox(width: 8),
              GlowButton(
                label: 'Upload Avatar',
                icon: Icons.person_rounded,
                color: AppColors.accent,
                textColor: Colors.black,
                isSmall: true,
                onPressed: () => _testUpload('Avatar'),
              ),
              const SizedBox(width: 8),
              GlowButton(
                label: 'Logo',
                icon: Icons.stars_rounded,
                color: AppColors.gold,
                textColor: Colors.black,
                isSmall: true,
                onPressed: () => _testUpload('Logo'),
              ),
              const SizedBox(width: 8),
              GlowButton(
                label: 'Subtitle',
                icon: Icons.subtitles_rounded,
                color: AppColors.success,
                textColor: Colors.black,
                isSmall: true,
                onPressed: () => _testUpload('Subtitle'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Upload progress
        if (_uploading || _uploadProgress > 0) ...[
          GlassCard(
            padding: const EdgeInsets.all(16),
            glowColor: _uploading ? AppColors.primary : AppColors.success,
            glowBlur: 20,
            borderColor: (_uploading ? AppColors.primary : AppColors.success)
                .withOpacity(0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (_uploading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    else
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 16),
                    const SizedBox(width: 10),
                    Text(_uploadStatus,
                        style: AppTextStyles.h4().copyWith(
                            color: _uploading
                                ? AppColors.primary
                                : AppColors.success,
                            fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: AppColors.glassBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _uploading ? AppColors.primary : AppColors.success),
                    minHeight: 4,
                  ),
                ),
                if (_lastUrl.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text('CDN URL:', style: AppTextStyles.bodySm()),
                  const SizedBox(height: 4),
                  SelectableText(
                    _lastUrl,
                    style: AppTextStyles.mono().copyWith(fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        // File grid
        Expanded(
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Text('Recent Files',
                          style: AppTextStyles.h3()),
                      const Spacer(),
                      const Icon(Icons.grid_view_rounded,
                          color: AppColors.textSecond, size: 18),
                      const SizedBox(width: 12),
                      const Icon(Icons.view_list_rounded,
                          color: AppColors.primary, size: 18),
                    ],
                  ),
                ),
                Container(height: 1, color: AppColors.glassBorder),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 15,
                    itemBuilder: (_, i) => _FilePreviewCard(
                      index: i,
                      color: folder.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Folder {
  const _Folder(this.name, this.icon, this.color, this.size, this.count);
  final String name, size;
  final IconData icon;
  final Color color;
  final int count;
}

class _FilePreviewCard extends StatefulWidget {
  const _FilePreviewCard({required this.index, required this.color});
  final int index;
  final Color color;

  @override
  State<_FilePreviewCard> createState() => _FilePreviewCardState();
}

class _FilePreviewCardState extends State<_FilePreviewCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.color.withOpacity(0.12),
              widget.color.withOpacity(0.04),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered
                ? widget.color.withOpacity(0.4)
                : AppColors.glassBorder,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Icon(Icons.image_rounded,
                    color: widget.color.withOpacity(0.5), size: 32),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('file_${widget.index + 1}.jpg',
                      style: AppTextStyles.bodySm()
                          .copyWith(fontSize: 10),
                      overflow: TextOverflow.ellipsis),
                  Text('${(128 + widget.index * 47)} KB',
                      style: AppTextStyles.bodySm()
                          .copyWith(fontSize: 9, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
