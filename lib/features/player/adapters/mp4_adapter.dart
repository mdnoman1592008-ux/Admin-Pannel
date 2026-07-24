import 'base_source_adapter.dart';
import '../../../models/streaming_source.dart';

class Mp4Adapter extends BaseVideoSourceAdapter {
  Mp4Adapter(super.source);

  @override
  Future<void> initialize() async {
    // Direct MP4 video stream initialization
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
