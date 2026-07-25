import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/admin_storage_service.dart';
import '../../core/backend/backend_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';

/// 7-Step Content Wizard Dialog for Ether Cinema Admin Panel
class ContentWizardDialog extends StatefulWidget {
  const ContentWizardDialog({super.key});

  @override
  State<ContentWizardDialog> createState() => _ContentWizardDialogState();
}

class _ContentWizardDialogState extends State<ContentWizardDialog> {
  int _currentStep = 0;

  // Step 1: Basic Info
  final _titleCtrl = TextEditingController();
  final _originalTitleCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _synopsisCtrl = TextEditingController();
  final _runtimeCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _imdbCtrl = TextEditingController();

  // Step 2: Categories
  final _categoryCtrl = TextEditingController();
  String _contentType = 'movie';
  String _sourceProvider = 'youtube';
  bool _uploadingAsset = false;
  bool _isSaving = false;
  String? _validationMessage;
  bool _isTrending = false;
  bool _isTop10 = false;
  bool _isFeatured = false;

  // Step 3: Media
  final _posterCtrl = TextEditingController();
  final _bannerCtrl = TextEditingController();

  // Step 4: Video
  final _videoIdCtrl = TextEditingController();
  final _trailerIdCtrl = TextEditingController();

  // Step 5: Subtitles
  final _subtitleUrlCtrl = TextEditingController();

  // Step 6: SEO
  final _slugCtrl = TextEditingController();
  final _seoTitleCtrl = TextEditingController();

  // Step 7: Publishing
  String _publishStatus = 'Published';

  final _totalSteps = 7;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _originalTitleCtrl.dispose();
    _taglineCtrl.dispose();
    _synopsisCtrl.dispose();
    _runtimeCtrl.dispose();
    _yearCtrl.dispose();
    _imdbCtrl.dispose();
    _categoryCtrl.dispose();
    _posterCtrl.dispose();
    _bannerCtrl.dispose();
    _videoIdCtrl.dispose();
    _trailerIdCtrl.dispose();
    _subtitleUrlCtrl.dispose();
    _slugCtrl.dispose();
    _seoTitleCtrl.dispose();
    super.dispose();
  }

  void _onNextStep() {
    final message = _validateCurrentStep();
    if (message != null) {
      setState(() => _validationMessage = message);
      return;
    }
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _validationMessage = null;
        _currentStep++;
      });
    } else {
      _saveMovieToFirestore();
    }
  }

  String? _validateCurrentStep() {
    if (_currentStep == 0 && _titleCtrl.text.trim().isEmpty) {
      return 'Add a title before continuing.';
    }
    if (_currentStep == 1 && _categoryCtrl.text.trim().isEmpty) {
      return 'Choose a category from your live category list.';
    }
    if (_currentStep == 3 && _videoIdCtrl.text.trim().isEmpty) {
      return 'Add the video ID or stream URL.';
    }
    return null;
  }

  void _onPrevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _saveMovieToFirestore() async {
    final title = _titleCtrl.text.trim();
    final category = _categoryCtrl.text.trim();
    if (title.isEmpty || category.isEmpty || _videoIdCtrl.text.trim().isEmpty) {
      setState(() => _validationMessage = 'Title, category, and source are required.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await LiveBackendService.instance.addMovie(LiveMovie(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      posterUrl: _posterCtrl.text.trim(),
      bannerUrl: _bannerCtrl.text.trim(),
      views: 0,
      isPublished: _publishStatus == 'Published',
      isFeatured: _isFeatured,
      year: _yearCtrl.text.trim(),
      synopsis: _synopsisCtrl.text.trim(),
      contentType: _contentType,
      sourceProvider: _sourceProvider,
      sourceUrl: _videoIdCtrl.text.trim(),
      playlistIds: [
        if (_isFeatured) 'featured',
        if (_isTrending) 'trending',
        if (_isTop10) 'top10',
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      ));
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) setState(() => _validationMessage = 'Could not save: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _uploadAsset(bool isPoster) async {
    final selection = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    final file = selection?.files.single;
    if (file?.bytes == null) return;
    setState(() => _uploadingAsset = true);
    try {
      final extension = file!.extension?.toLowerCase() ?? 'jpg';
      final id = 'm_${DateTime.now().millisecondsSinceEpoch}';
      final url = isPoster
          ? await AdminStorageService().uploadMoviePoster(bytes: file.bytes!, movieId: id, extension: extension)
          : await AdminStorageService().uploadMovieBanner(bytes: file.bytes!, movieId: id, extension: extension);
      if (mounted) setState(() => isPoster ? _posterCtrl.text = url : _bannerCtrl.text = url);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $error')));
    } finally {
      if (mounted) setState(() => _uploadingAsset = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(12),
      child: GlassCard(
        width: MediaQuery.sizeOf(context).width < 920
            ? MediaQuery.sizeOf(context).width - 24
            : 920,
        height: MediaQuery.sizeOf(context).height * 0.88,
        borderColor: AppColors.primary.withOpacity(0.3),
        child: Column(
          children: [
            _buildWizardHeader(),
            const SizedBox(height: 16),
            _buildStepIndicator(),
            const SizedBox(height: 20),
            if (_validationMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(_validationMessage!, style: AppTextStyles.bodySm().copyWith(color: AppColors.danger)),
              ),
            Expanded(child: _buildStepBody()),
            const SizedBox(height: 16),
            _buildWizardFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildWizardHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              color: Colors.black, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Premium 7-Step Content Wizard', style: AppTextStyles.h2()),
            Text('Publish Live Movies & TV Series to Firestore',
                style: AppTextStyles.bodySm()),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    final stepTitles = [
      'Basic Info',
      'Categories',
      'Media Assets',
      'Video Player',
      'Subtitles',
      'SEO Metadata',
      'Publish',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
      children: List.generate(_totalSteps, (i) {
        final isActive = i == _currentStep;
        final isCompleted = i < _currentStep;
        final color = isActive
            ? AppColors.primary
            : isCompleted
                ? AppColors.success
                : AppColors.textMuted;

        return SizedBox(
          width: 104,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Column(
              children: [
                Text(
                  'STEP ${i + 1}',
                  style:
                      AppTextStyles.badge().copyWith(color: color, fontSize: 9),
                ),
                const SizedBox(height: 2),
                Text(
                  stepTitles[i],
                  style: AppTextStyles.bodySm().copyWith(
                    color:
                        isActive ? AppColors.textPrimary : AppColors.textSecond,
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }),
    ));
  }

  Widget _buildStepBody() {
    switch (_currentStep) {
      case 0:
        return _buildStep1BasicInfo();
      case 1:
        return _buildStep2Categories();
      case 2:
        return _buildStep3MediaAssets();
      case 3:
        return _buildStep4VideoPlayer();
      case 4:
        return _buildStep5Subtitles();
      case 5:
        return _buildStep6Seo();
      case 6:
        return _buildStep7Publishing();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 1: Basic Information', style: AppTextStyles.h3()),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Movie Title *',
                      hintText: 'e.g. Nebula Drift 4K'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _originalTitleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Original Title',
                      hintText: 'e.g. Nebula Drift'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _taglineCtrl,
            decoration: const InputDecoration(
                labelText: 'Tagline',
                hintText: 'e.g. Beyond the stars lies eternity'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _synopsisCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Full Synopsis',
                hintText: 'Detailed movie storyline description...'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _runtimeCtrl,
                  decoration: const InputDecoration(labelText: 'Runtime'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _yearCtrl,
                  decoration: const InputDecoration(labelText: 'Release Year'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _imdbCtrl,
                  decoration: const InputDecoration(labelText: 'IMDb Rating'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Categories() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 2: Categories & Playlists', style: AppTextStyles.h3()),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('categories').snapshots(),
            builder: (context, snapshot) {
              final categories = snapshot.data?.docs
                      .map((d) => d.data()['name'] as String? ?? '')
                      .where((name) => name.isNotEmpty).toList() ?? const <String>[];
              return DropdownButtonFormField<String>(
                value: categories.contains(_categoryCtrl.text) ? _categoryCtrl.text : null,
                decoration: const InputDecoration(labelText: 'Primary Category *'),
                hint: Text(categories.isEmpty ? 'Create categories in Categories first' : 'Select a category'),
                items: categories.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
                onChanged: categories.isEmpty ? null : (value) => setState(() => _categoryCtrl.text = value ?? ''),
              );
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _contentType,
            decoration: const InputDecoration(labelText: 'Content type'),
            items: const [DropdownMenuItem(value: 'movie', child: Text('Movie')), DropdownMenuItem(value: 'series', child: Text('Series'))],
            onChanged: (value) => setState(() => _contentType = value ?? 'movie'),
          ),
          const SizedBox(height: 24),
          Text('Playlist Feature Toggles', style: AppTextStyles.h4()),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Featured Hero Carousel'),
            subtitle: const Text('Display on main hero banner carousel'),
            value: _isFeatured,
            onChanged: (v) => setState(() => _isFeatured = v),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            title: const Text('Trending Now Playlist'),
            subtitle: const Text('Include in Trending Movies section'),
            value: _isTrending,
            onChanged: (v) => setState(() => _isTrending = v),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            title: const Text('Top 10 Playlist'),
            subtitle: const Text('Rank in Top 10 Today list'),
            value: _isTop10,
            onChanged: (v) => setState(() => _isTop10 = v),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3MediaAssets() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 3: Media Assets',
              style: AppTextStyles.h3()),
          const SizedBox(height: 16),
          TextField(controller: _posterCtrl, decoration: InputDecoration(labelText: 'Poster image URL (2:3)', suffixIcon: IconButton(icon: const Icon(Icons.upload), onPressed: _uploadingAsset ? null : () => _uploadAsset(true)))),
          const SizedBox(height: 16),
          TextField(controller: _bannerCtrl, decoration: InputDecoration(labelText: 'Banner / backdrop URL (16:9)', suffixIcon: IconButton(icon: const Icon(Icons.upload), onPressed: _uploadingAsset ? null : () => _uploadAsset(false)))),
          const SizedBox(height: 24),
          if (_uploadingAsset) const Padding(padding: EdgeInsets.only(top: 14), child: LinearProgressIndicator()),
          const SizedBox(height: 14),
          Text('Live Asset Preview Card', style: AppTextStyles.h4()),
          const SizedBox(height: 12),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.horizontal(left: Radius.circular(12)),
                  ),
                  child: const Center(
                    child: Icon(Icons.movie_rounded,
                        color: Colors.black, size: 32),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          _titleCtrl.text.isEmpty
                              ? 'Movie Title Preview'
                              : _titleCtrl.text,
                          style: AppTextStyles.h3()),
                      const SizedBox(height: 4),
                      Text(
                          'Category: ${_categoryCtrl.text} | Year: ${_yearCtrl.text}',
                          style: AppTextStyles.bodySm()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4VideoPlayer() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 4: Video Player & Stream Sources',
              style: AppTextStyles.h3()),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _sourceProvider,
            decoration: const InputDecoration(labelText: 'Playback source *'),
            items: const [
              DropdownMenuItem(value: 'youtube', child: Text('YouTube')),
              DropdownMenuItem(value: 'dailymotion', child: Text('Dailymotion')),
              DropdownMenuItem(value: 'hls', child: Text('HLS (.m3u8)')),
              DropdownMenuItem(value: 'dash', child: Text('MPEG-DASH (.mpd)')),
              DropdownMenuItem(value: 'mp4', child: Text('Direct MP4')),
            ],
            onChanged: (value) => setState(() => _sourceProvider = value ?? 'youtube'),
          ),
          const SizedBox(height: 16),
          TextField(controller: _videoIdCtrl, decoration: InputDecoration(labelText: _sourceProvider == 'youtube' || _sourceProvider == 'dailymotion' ? 'Video ID or full URL *' : 'Stream URL *')),
          const SizedBox(height: 16),
          TextField(
            controller: _trailerIdCtrl,
            decoration:
                const InputDecoration(labelText: 'Trailer Video Stream ID'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5Subtitles() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 5: Subtitles & Localization', style: AppTextStyles.h3()),
          const SizedBox(height: 16),
          TextField(
            controller: _subtitleUrlCtrl,
            decoration: const InputDecoration(
                labelText: 'English WebVTT / SRT Subtitle URL (.vtt, .srt)'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep6Seo() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 6: SEO & Metadata', style: AppTextStyles.h3()),
          const SizedBox(height: 16),
          TextField(
            controller: _slugCtrl,
            decoration: const InputDecoration(
                labelText: 'SEO URL Slug (e.g. nebula-drift-4k)'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _seoTitleCtrl,
            decoration: const InputDecoration(labelText: 'SEO Page Meta Title'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep7Publishing() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step 7: Final Review & Publishing', style: AppTextStyles.h3()),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _publishStatus,
            decoration:
                const InputDecoration(labelText: 'Publishing Status State'),
            items: ['Draft', 'Review', 'Approved', 'Scheduled', 'Published']
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) => setState(() => _publishStatus = v ?? 'Published'),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ready to push live record to Firestore collection "movies" with realtime sync.',
                    style:
                        AppTextStyles.body().copyWith(color: AppColors.success),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWizardFooter() {
    return Row(
      children: [
        if (_currentStep > 0)
          TextButton.icon(
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text('Back'),
            onPressed: _onPrevStep,
          ),
        const Spacer(),
        GlowButton(
          label: _isSaving ? 'Publishing...' : _currentStep == _totalSteps - 1
              ? (_publishStatus == 'Published' ? 'Publish live' : 'Save content')
              : 'Continue Step',
          icon: _currentStep == _totalSteps - 1
              ? Icons.cloud_upload_rounded
              : Icons.arrow_forward_rounded,
          color: AppColors.primary,
          isSmall: true,
          isLoading: _isSaving,
          onPressed: _isSaving ? null : _onNextStep,
        ),
      ],
    );
  }
}
