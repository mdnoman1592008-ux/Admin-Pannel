import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/episode.dart';
import '../theme/app_colors.dart';
import 'glass_container.dart';
import 'liquid_button.dart';

class DailymotionPlayerView extends StatefulWidget {
  final Movie movie;
  final Episode? selectedEpisode;
  final VoidCallback onClose;
  final Function(Episode)? onSelectEpisode;

  const DailymotionPlayerView({
    super.key,
    required this.movie,
    this.selectedEpisode,
    required this.onClose,
    this.onSelectEpisode,
  });

  @override
  State<DailymotionPlayerView> createState() => _DailymotionPlayerViewState();
}

class _DailymotionPlayerViewState extends State<DailymotionPlayerView> {
  bool _isPlaying = true;
  bool _showControls = true;
  double _currentProgress = 0.35; // 35% watched
  double _playbackSpeed = 1.0;
  String _currentQuality = '1080p 60fps (IMAX)';
  bool _subtitlesEnabled = true;
  bool _showEpisodesDrawer = false;

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeVideoId = widget.selectedEpisode?.dailymotionVideoId ??
        widget.movie.dailymotionVideoId;
    final activeTitle = widget.selectedEpisode != null
        ? '${widget.movie.title} - ${widget.selectedEpisode!.title}'
        : widget.movie.title;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Video Frame Poster Preview with Blur
          Positioned.fill(
            child: Image.network(
              widget.selectedEpisode?.thumbnail ?? widget.movie.backdropUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: AppColors.surfaceContainerHigh),
            ),
          ),

          // Video Dark Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          // Dailymotion Video Info Watermark Overlay
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.primaryContainer),
                            ),
                            child: const Text(
                              'DAILYMOTION ADAPTIVE STREAM',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ID: $activeVideoId',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: widget.onClose,
                  ),
                ),
              ],
            ),
          ),

          // Center Play/Pause & Buffering Glow
          Center(
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.6),
                  border: Border.all(color: AppColors.primaryContainer, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.glassGlowBlue,
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),

          // Bottom Controls & Scrubber Bar
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Timeline Scrubber
                  Row(
                    children: [
                      const Text(
                        '14:20',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      Expanded(
                        child: Slider(
                          value: _currentProgress,
                          activeColor: AppColors.primaryContainer,
                          inactiveColor: Colors.white24,
                          onChanged: (val) {
                            setState(() {
                              _currentProgress = val;
                            });
                          },
                        ),
                      ),
                      const Text(
                        '45:00',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),

                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _subtitlesEnabled
                                  ? Icons.subtitles_rounded
                                  : Icons.subtitles_off_rounded,
                              color: _subtitlesEnabled
                                  ? AppColors.primaryContainer
                                  : Colors.white60,
                            ),
                            onPressed: () {
                              setState(() {
                                _subtitlesEnabled = !_subtitlesEnabled;
                              });
                            },
                          ),
                          PopupMenuButton<double>(
                            initialValue: _playbackSpeed,
                            tooltip: 'Speed',
                            onSelected: (speed) {
                              setState(() {
                                _playbackSpeed = speed;
                              });
                            },
                            itemBuilder: (context) => [0.75, 1.0, 1.25, 1.5, 2.0]
                                .map(
                                  (s) => PopupMenuItem(
                                    value: s,
                                    child: Text('${s}x Speed'),
                                  ),
                                )
                                .toList(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '${_playbackSpeed}x',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.movie.isSeries && widget.movie.episodes.isNotEmpty)
                        TextButton.icon(
                          icon: const Icon(Icons.video_library_rounded,
                              color: AppColors.primaryContainer),
                          label: const Text(
                            'EPISODES',
                            style: TextStyle(
                              color: AppColors.primaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _showEpisodesDrawer = !_showEpisodesDrawer;
                            });
                          },
                        ),
                      const Icon(Icons.fullscreen_rounded, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Episodes Drawer Sheet (if series)
          if (_showEpisodesDrawer && widget.movie.episodes.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 320,
              child: Container(
                color: Colors.black.withOpacity(0.9),
                child: GlassContainer(
                  borderRadius: 0,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Episodes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _showEpisodesDrawer = false;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.movie.episodes.length,
                          itemBuilder: (context, index) {
                            final ep = widget.movie.episodes[index];
                            final isCurrent = widget.selectedEpisode?.id == ep.id;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GlassContainer(
                                borderRadius: 16,
                                padding: const EdgeInsets.all(12),
                                borderColor: isCurrent
                                    ? AppColors.primaryContainer
                                    : AppColors.glassBorder,
                                onTap: () {
                                  if (widget.onSelectEpisode != null) {
                                    widget.onSelectEpisode!(ep);
                                  }
                                  setState(() {
                                    _showEpisodesDrawer = false;
                                  });
                                },
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        ep.thumbnail,
                                        width: 60,
                                        height: 45,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ep.title,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            ep.duration,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
