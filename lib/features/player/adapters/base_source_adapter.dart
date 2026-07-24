import '../../../models/streaming_source.dart';

abstract class BaseVideoSourceAdapter {
  final StreamingSource source;

  BaseVideoSourceAdapter(this.source);

  StreamingProvider get provider => source.provider;
  String get streamUrlOrId => source.urlOrId;

  Future<void> initialize();
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(double positionRatio);
  Future<void> setPlaybackSpeed(double speed);
  Future<void> dispose();
}
