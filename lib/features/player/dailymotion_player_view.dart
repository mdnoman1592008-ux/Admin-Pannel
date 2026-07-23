import 'package:flutter/material.dart';
import '../../core/models/movie.dart';
import '../../core/models/episode.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/liquid_button.dart';

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
  double _currentProgress = 0.35;
  double _playbackSpeed = 1.0;
  bool _subtitlesEnabled = true;
  bool _showEpisodesDrawer = false;
  bool _controlsLocked = false;
  String? _gestureFeedbackMessage;
  bool _showSkipIntro = true;

  void _togglePlayPause() {
    if (_controlsLocked) return;
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _onDoubleTapSeek(bool isForward) {
    if (_controlsLocked) return;
    setState(() {
      _currentProgress = (_currentProgress + (isForward ? 0.05 : -0.05)).clamp(0.0, 1.0);
      _gestureFeedbackMessage = isForward ? '+10 sec (Forward)' : '-10 sec (Rewind)';
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _gestureFeedbackMessage = null;
        });
      }
    });
  }

  void _showSleepTimerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sleep Timer', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [15, 30, 45, 60].map((mins) {
            return ListTile(
              title: Text('$mins minutes', style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sleep timer set for $mins minutes!')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
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
      body: GestureDetector(
        onDoubleTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx > screenWidth / 2) {
            _onDoubleTapSeek(true);
          } else {
            _onDoubleTapSeek(false);
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Frame
            Positioned.fill(
              child: Image.network(
                widget.selectedEpisode?.thumbnail ?? widget.movie.backdropUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: AppColors.surfaceContainerHigh),
              ),
            ),

            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),

            // Gesture Overlay Feedback Indicator
            if (_gestureFeedbackMessage != null)
              Center(
                child: GlassContainer(
                  borderRadius: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    _gestureFeedbackMessage!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                ),
              ),

            // Skip Intro Button
            if (_showSkipIntro && !_controlsLocked)
              Positioned(
                bottom: 120,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showSkipIntro = false;
                      _currentProgress = (_currentProgress + 0.15).clamp(0.0, 1.0);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Skipped Intro! (+90s)')),
                    );
                  },
                  child: GlassContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('SKIP INTRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        SizedBox(width: 6),
                        Icon(Icons.skip_next_rounded, color: AppColors.primaryContainer, size: 18),
                      ],
                    ),
                  ),
                ),
              ),

            // Header Watermark & Lock Button
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
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(_controlsLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                            color: _controlsLocked ? AppColors.tertiary : Colors.white),
                        onPressed: () {
                          setState(() {
                            _controlsLocked = !_controlsLocked;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.timer_rounded, color: Colors.white),
                        onPressed: _showSleepTimerDialog,
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
                ],
              ),
            ),

            // Play/Pause Button
            if (!_controlsLocked)
              Center(
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
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

            // Bottom Scrubber Bar
            if (!_controlsLocked)
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
                      Row(
                        children: [
                          const Text('14:20', style: TextStyle(fontSize: 12, color: Colors.white70)),
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
                          const Text('45:00', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
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
                                    .map((s) => PopupMenuItem(value: s, child: Text('${s}x Speed')))
                                    .toList(),
                                child: Text(
                                  '${_playbackSpeed}x',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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

            // Episodes Drawer Sheet
            if (_showEpisodesDrawer && widget.movie.episodes.isNotEmpty)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 320,
                child: Container(
                  color: Colors.black.withOpacity(0.95),
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
      ),
    );
  }
}
