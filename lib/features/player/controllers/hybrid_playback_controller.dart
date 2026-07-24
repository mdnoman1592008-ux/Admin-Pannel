import 'package:flutter/foundation.dart';
import '../../../models/streaming_source.dart';
import '../adapters/base_source_adapter.dart';
import '../adapters/dailymotion_adapter.dart';
import '../adapters/youtube_adapter.dart';
import '../adapters/hls_adapter.dart';
import '../adapters/mp4_adapter.dart';
import '../adapters/dash_adapter.dart';
import '../adapters/vimeo_adapter.dart';

class HybridPlaybackController extends ChangeNotifier {
  final List<StreamingSource> sources;
  int _activeSourceIndex = 0;
  BaseVideoSourceAdapter? _currentAdapter;

  bool _isPlaying = true;
  double _currentProgress = 0.35;
  double _playbackSpeed = 1.0;
  String _activeQuality = '1080p Full HD';
  String _activeSubtitle = 'English (CC)';

  HybridPlaybackController({required this.sources}) {
    _initializeActiveSource();
  }

  StreamingSource get activeSource {
    final list = sources.isNotEmpty
        ? sources
        : const [
            StreamingSource(
              id: 'src1',
              provider: StreamingProvider.dailymotion,
              urlOrId: 'x8m00bc',
              priority: 1,
            ),
          ];
    return list[_activeSourceIndex.clamp(0, list.length - 1)];
  }

  bool get isPlaying => _isPlaying;
  double get currentProgress => _currentProgress;
  double get playbackSpeed => _playbackSpeed;
  String get activeQuality => _activeQuality;
  String get activeSubtitle => _activeSubtitle;
  BaseVideoSourceAdapter? get currentAdapter => _currentAdapter;

  void _initializeActiveSource() {
    _currentAdapter?.dispose();
    final source = activeSource;
    switch (source.provider) {
      case StreamingProvider.dailymotion:
        _currentAdapter = DailymotionAdapter(source);
        break;
      case StreamingProvider.youtube:
        _currentAdapter = YouTubeAdapter(source);
        break;
      case StreamingProvider.hls:
        _currentAdapter = HlsAdapter(source);
        break;
      case StreamingProvider.mp4:
        _currentAdapter = Mp4Adapter(source);
        break;
      case StreamingProvider.dash:
        _currentAdapter = DashAdapter(source);
        break;
      case StreamingProvider.vimeo:
        _currentAdapter = VimeoAdapter(source);
        break;
      case StreamingProvider.custom:
        _currentAdapter = Mp4Adapter(source);
        break;
    }
    _currentAdapter?.initialize();
    notifyListeners();
  }

  void play() {
    _isPlaying = true;
    _currentAdapter?.play();
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    _currentAdapter?.pause();
    notifyListeners();
  }

  void seekTo(double progress) {
    _currentProgress = progress.clamp(0.0, 1.0);
    _currentAdapter?.seekTo(_currentProgress);
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    _currentAdapter?.setPlaybackSpeed(speed);
    notifyListeners();
  }

  void setQuality(String quality) {
    _activeQuality = quality;
    notifyListeners();
  }

  void setSubtitle(String subtitle) {
    _activeSubtitle = subtitle;
    notifyListeners();
  }

  bool fallbackToNextSource() {
    if (sources.length <= 1) return false;
    _activeSourceIndex = (_activeSourceIndex + 1) % sources.length;
    _initializeActiveSource();
    return true;
  }

  void selectSource(int index) {
    if (index >= 0 && index < sources.length) {
      _activeSourceIndex = index;
      _initializeActiveSource();
    }
  }

  @override
  void dispose() {
    _currentAdapter?.dispose();
    super.dispose();
  }
}
