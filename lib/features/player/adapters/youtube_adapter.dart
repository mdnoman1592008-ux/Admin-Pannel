import 'base_source_adapter.dart';
import '../../../models/streaming_source.dart';

class YouTubeAdapter extends BaseVideoSourceAdapter {
  YouTubeAdapter(super.source);

  @override
  Future<void> initialize() async {
    // YouTube player initialization logic
  }

  @override
  Future<void> play() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> seekTo(double positionRatio) async {}

  @override
  Future<void> setPlaybackSpeed(double speed) async {}

  @override
  Future<void> dispose() async {}
}
