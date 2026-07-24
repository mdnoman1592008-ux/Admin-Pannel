import 'base_source_adapter.dart';
import '../../../models/streaming_source.dart';

class HlsAdapter extends BaseVideoSourceAdapter {
  HlsAdapter(super.source);

  @override
  Future<void> initialize() async {
    // HLS .m3u8 adaptive stream initialization
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
