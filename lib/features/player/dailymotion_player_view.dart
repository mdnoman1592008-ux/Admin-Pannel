import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/movie.dart';
import '../../core/models/episode.dart';
import '../../core/models/streaming_source.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/liquid_button.dart';

enum PlayerSubMenu { none, quality, subtitles, speed, episodes, sources }

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

class _DailymotionPlayerViewState extends State<DailymotionPlayerView>
    with SingleTickerProviderStateMixin {
  // Playback State
  bool _isPlaying = true;
  double _currentProgress = 0.35; // 0.0 to 1.0
  double _bufferedProgress = 0.65;
  double _playbackSpeed = 1.0;
  String _selectedQuality = '1080p Full HD';
  String _selectedSubtitle = 'English (CC)';
  bool _subtitlesEnabled = true;
  double _subtitleSize = 16.0;

  // Multi-Source Streaming Engine State
  int _currentSourceIndex = 0;
  bool _isSwitchingSource = false;
  String? _sourceFallbackToast;
  Timer? _fallbackToastTimer;

  // Gestures & Control Overlays
  bool _showControls = true;
  PlayerSubMenu _activeSubMenu = PlayerSubMenu.none;
  Timer? _autoHideTimer;
  bool _controlsLocked = false;

  // Touch Gesture Overlays
  double _brightnessLevel = 0.8;
  double _volumeLevel = 0.7;
  String? _gestureOverlayMessage;
  IconData? _gestureOverlayIcon;
  Timer? _gestureOverlayTimer;

  // Double Tap Seek Accumulation
  int _accumulatedSeekSeconds = 0;
  bool _isSeekingForward = true;
  Timer? _doubleTapSeekTimer;

  // Player Features
  bool _showSkipIntro = true;
  bool _isPipMode = false;
  int _nextEpisodeCountdown = 15;
  Timer? _nextEpisodeTimer;

  // Animation Controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const List<String> _qualityList = [
    'Auto (Recommended)',
    '4K Ultra HD',
    '1080p Full HD',
    '720p HD',
    '480p SD',
    '360p',
    '240p'
  ];

  static const List<String> _subtitleLanguages = [
    'Off',
    'English (CC)',
    'Bengali (বাংলা)',
    'Spanish (Español)',
    'French (Français)',
    'Japanese (日本語)'
  ];

  static const List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  void initState() {
    super.initState();

    // Enable Immersive Fullscreen Mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _startAutoHideTimer();
    _startNextEpisodeCountdownIfNeeded();
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _gestureOverlayTimer?.cancel();
    _doubleTapSeekTimer?.cancel();
    _nextEpisodeTimer?.cancel();
    _fallbackToastTimer?.cancel();
    _fadeController.dispose();

    // Restore Edge to Edge System UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  List<StreamingSource> get _availableSources {
    return widget.movie.streamingSources.isNotEmpty
        ? widget.movie.streamingSources
        : const [
            StreamingSource(
              id: 'src1',
              provider: StreamingProvider.dailymotion,
              urlOrId: 'x8m00bc',
              priority: 1,
            ),
            StreamingSource(
              id: 'src2',
              provider: StreamingProvider.youtube,
              urlOrId: 'dQw4w9WgXcQ',
              priority: 2,
            ),
            StreamingSource(
              id: 'src3',
              provider: StreamingProvider.hls,
              urlOrId: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
              priority: 3,
            ),
          ];
  }

  StreamingSource get _currentSource {
    final sources = _availableSources;
    return sources[_currentSourceIndex.clamp(0, sources.length - 1)];
  }

  void _triggerAutomaticSourceFallback() {
    final sources = _availableSources;
    if (sources.length <= 1) return;

    final nextIndex = (_currentSourceIndex + 1) % sources.length;
    final nextSource = sources[nextIndex];

    setState(() {
      _isSwitchingSource = true;
      _currentSourceIndex = nextIndex;
      _sourceFallbackToast = 'Trying another streaming source (${nextSource.providerDisplayName})...';
    });

    _fallbackToastTimer?.cancel();
    _fallbackToastTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSwitchingSource = false;
          _sourceFallbackToast = null;
        });
      }
    });
  }

  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isPlaying && !_controlsLocked && _activeSubMenu == PlayerSubMenu.none) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControlsVisibility() {
    if (_controlsLocked) return;
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _startAutoHideTimer();
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      _showControls = true;
      _startAutoHideTimer();
    });
  }

  void _handleDoubleTapSeek(bool isForward, Offset tapPosition, double screenWidth) {
    if (_controlsLocked) return;

    setState(() {
      if (_doubleTapSeekTimer?.isActive ?? false) {
        _accumulatedSeekSeconds += 10;
      } else {
        _accumulatedSeekSeconds = 10;
        _isSeekingForward = isForward;
      }

      final seekFraction = _accumulatedSeekSeconds / 7200; // 2 hour baseline
      if (_isSeekingForward) {
        _currentProgress = (_currentProgress + seekFraction).clamp(0.0, 1.0);
      } else {
        _currentProgress = (_currentProgress - seekFraction).clamp(0.0, 1.0);
      }
    });

    _doubleTapSeekTimer?.cancel();
    _doubleTapSeekTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _accumulatedSeekSeconds = 0;
        });
      }
    });
  }

  void _showGestureToast(String message, IconData icon) {
    setState(() {
      _gestureOverlayMessage = message;
      _gestureOverlayIcon = icon;
    });

    _gestureOverlayTimer?.cancel();
    _gestureOverlayTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _gestureOverlayMessage = null;
          _gestureOverlayIcon = null;
        });
      }
    });
  }

  void _togglePipMode() {
    setState(() {
      _isPipMode = !_isPipMode;
    });
    if (_isPipMode) {
      _showGestureToast('Picture in Picture Active', Icons.picture_in_picture_rounded);
    }
  }

  void _startNextEpisodeCountdownIfNeeded() {
    if (_currentProgress > 0.95) {
      _nextEpisodeTimer?.cancel();
      _nextEpisodeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        if (_nextEpisodeCountdown > 0) {
          setState(() {
            _nextEpisodeCountdown--;
          });
        } else {
          timer.cancel();
          _playNextEpisode();
        }
      });
    }
  }

  void _playNextEpisode() {
    if (widget.movie.episodes.isNotEmpty && widget.onSelectEpisode != null) {
      final currentEpNum = widget.selectedEpisode?.episodeNumber ?? 1;
      final nextEp = widget.movie.episodes.firstWhere(
        (e) => e.episodeNumber == currentEpNum + 1,
        orElse: () => widget.movie.episodes.first,
      );
      widget.onSelectEpisode!(nextEp);
      setState(() {
        _currentProgress = 0.0;
        _nextEpisodeCountdown = 15;
      });
    }
  }

  String _formatTime(double progress) {
    final totalSeconds = 7200; // 2 hour duration
    final currentSeconds = (progress * totalSeconds).toInt();
    final minutes = (currentSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (currentSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final activeTitle = widget.selectedEpisode != null
        ? '${widget.movie.title} • ${widget.selectedEpisode!.title}'
        : widget.movie.title;

    return WillPopScope(
      onWillPop: () async {
        widget.onClose();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: _toggleControlsVisibility,
          onDoubleTapDown: (details) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isRightSide = details.globalPosition.dx > (screenWidth / 2);
            _handleDoubleTapSeek(isRightSide, details.globalPosition, screenWidth);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Simulated Dynamic Multi-Provider Video Engine (Dailymotion, YouTube, HLS, MP4)
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                color: Colors.black,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Video Poster Backdrop
                      Opacity(
                        opacity: _isPlaying ? 0.35 : 0.6,
                        child: Image.network(
                          widget.movie.backdropUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: const Color(0xFF0E1118)),
                        ),
                      ),

                      // Provider Active Badge Indicator
                      Positioned(
                        top: 24,
                        left: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF00CFFF)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.stream_rounded, color: Color(0xFF00CFFF), size: 14),
                              const SizedBox(width: 6),
                              Text(
                                '${_currentSource.providerDisplayName} (Priority ${_currentSource.priority})',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Automatic Source Failover Toast
              if (_sourceFallbackToast != null)
                Positioned(
                  top: 80,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: GlassContainer(
                      borderRadius: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00CFFF)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _sourceFallbackToast!,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Controls Overlay Layer
              if (_showControls)
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black87,
                              Colors.transparent,
                              Colors.black87,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Top Bar Header
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                                        onPressed: widget.onClose,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              activeTitle,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${widget.movie.releaseYear} • ${_currentSource.providerDisplayName}',
                                              style: const TextStyle(
                                                color: AppColors.onSurfaceVariant,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.speed_rounded, color: Colors.white),
                                        onPressed: _triggerAutomaticSourceFallback,
                                        tooltip: 'Simulate Source Failover',
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _controlsLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                                          color: _controlsLocked ? const Color(0xFF00CFFF) : Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _controlsLocked = !_controlsLocked;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Center Play / Pause Controls
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    iconSize: 44,
                                    icon: const Icon(Icons.replay_10_rounded, color: Colors.white),
                                    onPressed: () => _handleDoubleTapSeek(false, Offset.zero, 100),
                                  ),
                                  const SizedBox(width: 32),
                                  GestureDetector(
                                    onTap: _togglePlayPause,
                                    child: Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF00CFFF).withOpacity(0.2),
                                        border: Border.all(color: const Color(0xFF00CFFF), width: 2),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0xFF00CFFF),
                                            blurRadius: 20,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 42,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  IconButton(
                                    iconSize: 44,
                                    icon: const Icon(Icons.forward_10_rounded, color: Colors.white),
                                    onPressed: () => _handleDoubleTapSeek(true, Offset.zero, 100),
                                  ),
                                ],
                              ),
                            ),

                            // Bottom Bar (Timeline & Multi-Source Submenu Controls)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Timeline Slider
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            _formatTime(_currentProgress),
                                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                          Expanded(
                                            child: SliderTheme(
                                              data: SliderThemeData(
                                                activeTrackColor: const Color(0xFF00CFFF),
                                                inactiveTrackColor: Colors.white.withOpacity(0.2),
                                                thumbColor: const Color(0xFF00CFFF),
                                                overlayColor: const Color(0xFF00CFFF).withOpacity(0.3),
                                                trackHeight: 3.5,
                                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                              ),
                                              child: Slider(
                                                value: _currentProgress,
                                                onChanged: (val) {
                                                  setState(() {
                                                    _currentProgress = val;
                                                  });
                                                  _startAutoHideTimer();
                                                },
                                              ),
                                            ),
                                          ),
                                          Text(
                                            _formatTime(1.0),
                                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Bottom Submenu Action Buttons
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          // Streaming Source Selector
                                          TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _activeSubMenu = _activeSubMenu == PlayerSubMenu.sources
                                                    ? PlayerSubMenu.none
                                                    : PlayerSubMenu.sources;
                                              });
                                            },
                                            icon: const Icon(Icons.alt_route_rounded, color: Color(0xFF00CFFF), size: 18),
                                            label: Text(_currentSource.providerDisplayName.split(' ').first, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                          ),

                                          // Quality Selector Button
                                          TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _activeSubMenu = _activeSubMenu == PlayerSubMenu.quality
                                                    ? PlayerSubMenu.none
                                                    : PlayerSubMenu.quality;
                                              });
                                            },
                                            icon: const Icon(Icons.high_quality_rounded, color: Color(0xFF00CFFF), size: 18),
                                            label: Text(_selectedQuality.split(' ').first, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                          ),

                                          // Subtitles Selector Button
                                          TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _activeSubMenu = _activeSubMenu == PlayerSubMenu.subtitles
                                                    ? PlayerSubMenu.none
                                                    : PlayerSubMenu.subtitles;
                                              });
                                            },
                                            icon: const Icon(Icons.subtitles_rounded, color: Color(0xFF00CFFF), size: 18),
                                            label: Text(_selectedSubtitle.split(' ').first, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                          ),

                                          // Speed Selector Button
                                          TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _activeSubMenu = _activeSubMenu == PlayerSubMenu.speed
                                                    ? PlayerSubMenu.none
                                                    : PlayerSubMenu.speed;
                                              });
                                            },
                                            icon: const Icon(Icons.slow_motion_video_rounded, color: Color(0xFF00CFFF), size: 18),
                                            label: Text('${_playbackSpeed}x', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              // Drawer Submenu Panel (Sources, Quality, Subtitles, Speed)
              if (_activeSubMenu != PlayerSubMenu.none)
                Positioned(
                  right: 20,
                  bottom: 80,
                  child: GlassContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: 240,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _activeSubMenu == PlayerSubMenu.sources
                                    ? 'Streaming Provider'
                                    : _activeSubMenu == PlayerSubMenu.quality
                                        ? 'Video Quality'
                                        : _activeSubMenu == PlayerSubMenu.subtitles
                                            ? 'Subtitles'
                                            : 'Playback Speed',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _activeSubMenu = PlayerSubMenu.none;
                                  });
                                },
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white24),
                          if (_activeSubMenu == PlayerSubMenu.sources)
                            Column(
                              children: List.generate(_availableSources.length, (index) {
                                final src = _availableSources[index];
                                final isSel = index == _currentSourceIndex;
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    'Priority ${src.priority}: ${src.providerDisplayName}',
                                    style: TextStyle(
                                      color: isSel ? const Color(0xFF00CFFF) : Colors.white,
                                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  trailing: isSel ? const Icon(Icons.check_circle_rounded, color: Color(0xFF00CFFF), size: 18) : null,
                                  onTap: () {
                                    setState(() {
                                      _currentSourceIndex = index;
                                      _activeSubMenu = PlayerSubMenu.none;
                                    });
                                  },
                                );
                              }),
                            ),
                          if (_activeSubMenu == PlayerSubMenu.quality)
                            Column(
                              children: _qualityList.map((q) {
                                final isSel = q == _selectedQuality;
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    q,
                                    style: TextStyle(
                                      color: isSel ? const Color(0xFF00CFFF) : Colors.white,
                                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedQuality = q;
                                      _activeSubMenu = PlayerSubMenu.none;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
