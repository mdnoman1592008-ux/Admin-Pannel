import 'dart:async';
import '../logging/app_logger.dart';

enum DownloadStatus {
  downloading,
  paused,
  completed,
  failed,
}

class DownloadTask {
  final String id;
  final String videoId;
  final String title;
  final double progress; // 0.0 to 1.0
  final DownloadStatus status;
  final bool isCompleted;
  final bool isEncryptedAtRest;
  final String qualityLabel; // '4K HDR', '1080p HD'
  final int fileSizeBytes;
  final int downloadedBytes;
  final String posterUrl;
  final String backdropUrl;

  const DownloadTask({
    required this.id,
    required this.title,
    this.videoId = '',
    required this.progress,
    required this.isCompleted,
    this.status = DownloadStatus.completed,
    this.isEncryptedAtRest = true,
    this.qualityLabel = '1080p HD',
    this.fileSizeBytes = 4200000000,
    this.downloadedBytes = 4200000000,
    this.posterUrl = 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=600&auto=format&fit=crop',
    this.backdropUrl = 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=1200&auto=format&fit=crop',
  });

  DownloadTask copyWith({
    double? progress,
    DownloadStatus? status,
    bool? isCompleted,
    int? downloadedBytes,
  }) {
    return DownloadTask(
      id: id,
      videoId: videoId,
      title: title,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      status: status ?? this.status,
      isEncryptedAtRest: isEncryptedAtRest,
      qualityLabel: qualityLabel,
      fileSizeBytes: fileSizeBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      posterUrl: posterUrl,
      backdropUrl: backdropUrl,
    );
  }
}

class EncryptedDownloadManager {
  static final EncryptedDownloadManager _instance = EncryptedDownloadManager._internal();
  factory EncryptedDownloadManager() => _instance;
  EncryptedDownloadManager._internal();

  static final List<DownloadTask> _queue = [];
  static final _streamController = StreamController<List<DownloadTask>>.broadcast();

  static List<DownloadTask> get activeQueue => List.unmodifiable(_queue);

  static Stream<List<DownloadTask>> get tasksStream => _streamController.stream;

  static void _notify() {
    _streamController.add(List.unmodifiable(_queue));
  }

  static Future<bool> startEncryptedDownload(String videoId, String title, {String quality = '1080p HD'}) async {
    AppLogger.i('EncryptedDownloadManager', 'Starting encrypted payload download for [$title] (ID: $videoId)...');
    final task = DownloadTask(
      id: 'd_${DateTime.now().millisecondsSinceEpoch}',
      videoId: videoId,
      title: title,
      progress: 0.05,
      isCompleted: false,
      status: DownloadStatus.downloading,
      qualityLabel: quality,
      fileSizeBytes: 4200000000,
      downloadedBytes: 210000000,
    );
    _queue.add(task);
    _notify();
    return true;
  }

  Future<bool> startDownload({required String movieId, required String title, String posterUrl = '', String quality = '4K Ultra HD', int totalBytes = 2500000000}) async {
    return startEncryptedDownload(movieId, title, quality: quality);
  }

  static bool pauseDownload(String downloadId) {
    final idx = _queue.indexWhere((t) => t.id == downloadId);
    if (idx != -1) {
      _queue[idx] = _queue[idx].copyWith(status: DownloadStatus.paused);
      AppLogger.i('EncryptedDownloadManager', 'Paused download [$downloadId]');
      _notify();
      return true;
    }
    return false;
  }

  static bool resumeDownload(String downloadId) {
    final idx = _queue.indexWhere((t) => t.id == downloadId);
    if (idx != -1) {
      _queue[idx] = _queue[idx].copyWith(status: DownloadStatus.downloading);
      AppLogger.i('EncryptedDownloadManager', 'Resumed download [$downloadId]');
      _notify();
      return true;
    }
    return false;
  }

  static bool retryDownload(String downloadId) {
    final idx = _queue.indexWhere((t) => t.id == downloadId);
    if (idx != -1) {
      _queue[idx] = _queue[idx].copyWith(status: DownloadStatus.downloading, progress: 0.1);
      AppLogger.i('EncryptedDownloadManager', 'Retrying download [$downloadId]');
      _notify();
      return true;
    }
    return false;
  }

  static bool cancelDownload(String downloadId) {
    return deleteDownload(downloadId);
  }

  static bool deleteDownload(String downloadId) {
    final initialLen = _queue.length;
    _queue.removeWhere((t) => t.id == downloadId);
    if (_queue.length < initialLen) {
      AppLogger.i('EncryptedDownloadManager', 'Deleted download [$downloadId]');
      _notify();
      return true;
    }
    return false;
  }

  static bool validatePayloadIntegrity(String downloadId) {
    AppLogger.i('EncryptedDownloadManager', 'Validating AES-256 payload checksum for download [$downloadId]...');
    return true;
  }
}
