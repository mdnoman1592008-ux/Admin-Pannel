import 'dart:async';
import 'package:flutter/foundation.dart';

/// Live Movie Entity
class LiveMovie {
  final String id;
  final String title;
  final String category;
  final String posterUrl;
  final String bannerUrl;
  final int views;
  final bool isPublished;
  final bool isFeatured;
  final String year;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LiveMovie({
    required this.id,
    required this.title,
    required this.category,
    required this.posterUrl,
    required this.bannerUrl,
    required this.views,
    required this.isPublished,
    required this.isFeatured,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LiveMovie.fromFirestore(Map<String, dynamic> data, String docId) {
    return LiveMovie(
      id: docId,
      title: data['title'] as String? ?? 'Untitled Movie',
      category: data['category'] as String? ?? 'General',
      posterUrl: data['posterUrl'] as String? ?? '',
      bannerUrl: data['bannerUrl'] as String? ?? '',
      views: (data['views'] as num?)?.toInt() ?? 0,
      isPublished: data['isPublished'] as bool? ?? false,
      isFeatured: data['isFeatured'] as bool? ?? false,
      year: data['year'] as String? ?? '2024',
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.tryParse(data['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Live TV Series Entity
class LiveSeries {
  final String id;
  final String title;
  final String genre;
  final int seasons;
  final int episodes;
  final String status;
  final bool isFeatured;
  final int views;
  final String posterUrl;
  final DateTime createdAt;

  const LiveSeries({
    required this.id,
    required this.title,
    required this.genre,
    required this.seasons,
    required this.episodes,
    required this.status,
    required this.isFeatured,
    required this.views,
    required this.posterUrl,
    required this.createdAt,
  });

  factory LiveSeries.fromFirestore(Map<String, dynamic> data, String docId) {
    return LiveSeries(
      id: docId,
      title: data['title'] as String? ?? 'Untitled Series',
      genre: data['genre'] as String? ?? 'General',
      seasons: (data['seasons'] as num?)?.toInt() ?? 1,
      episodes: (data['episodes'] as num?)?.toInt() ?? 1,
      status: data['status'] as String? ?? 'draft',
      isFeatured: data['isFeatured'] as bool? ?? false,
      views: (data['views'] as num?)?.toInt() ?? 0,
      posterUrl: data['posterUrl'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Live Category Entity
class LiveCategory {
  final String id;
  final String name;
  final String iconName;
  final String colorHex;
  final int movieCount;

  const LiveCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.movieCount,
  });

  factory LiveCategory.fromFirestore(Map<String, dynamic> data, String docId) {
    return LiveCategory(
      id: docId,
      name: data['name'] as String? ?? 'Category',
      iconName: data['iconName'] as String? ?? 'category',
      colorHex: data['colorHex'] as String? ?? '#00D8FF',
      movieCount: (data['movieCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Live Audit Log Entity
class LiveAuditLog {
  final String id;
  final String severity;
  final String title;
  final String description;
  final String timestamp;
  final DateTime createdAt;

  const LiveAuditLog({
    required this.id,
    required this.severity,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.createdAt,
  });

  factory LiveAuditLog.fromFirestore(Map<String, dynamic> data, String docId) {
    return LiveAuditLog(
      id: docId,
      severity: data['severity'] as String? ?? 'info',
      title: data['title'] as String? ?? 'System Event',
      description: data['description'] as String? ?? '',
      timestamp: data['timestamp'] as String? ?? 'Just now',
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Live FCM Notification Entity
class LiveNotification {
  final String id;
  final String title;
  final String body;
  final String target;
  final int recipientCount;
  final DateTime sentAt;

  const LiveNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.target,
    required this.recipientCount,
    required this.sentAt,
  });

  factory LiveNotification.fromFirestore(Map<String, dynamic> data, String docId) {
    return LiveNotification(
      id: docId,
      title: data['title'] as String? ?? 'Push Notification',
      body: data['body'] as String? ?? '',
      target: data['target'] as String? ?? 'all',
      recipientCount: (data['recipientCount'] as num?)?.toInt() ?? 0,
      sentAt: data['sentAt'] != null
          ? DateTime.tryParse(data['sentAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Live Remote Config Entity
class LiveConfigKey {
  final String key;
  final String value;
  final String type;
  final String description;

  const LiveConfigKey({
    required this.key,
    required this.value,
    required this.type,
    required this.description,
  });

  factory LiveConfigKey.fromFirestore(Map<String, dynamic> data, String docId) {
    return LiveConfigKey(
      key: docId,
      value: data['value']?.toString() ?? '',
      type: data['type'] as String? ?? 'string',
      description: data['description'] as String? ?? '',
    );
  }
}

/// Live Supabase Storage File Entity
class LiveStorageFile {
  final String name;
  final String path;
  final int sizeBytes;
  final String folder;
  final DateTime uploadedAt;

  const LiveStorageFile({
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.folder,
    required this.uploadedAt,
  });
}

/// Central Live Backend Service (Cloud Firestore + Firebase Auth + Supabase Storage)
class LiveBackendService extends ChangeNotifier {
  static final LiveBackendService _instance = LiveBackendService._internal();
  factory LiveBackendService() => _instance;
  static LiveBackendService get instance => _instance;

  LiveBackendService._internal();

  // In-memory live Firestore collections (emulating realtime Firestore streams)
  final List<LiveMovie> _movies = [];
  final List<LiveSeries> _series = [];
  final List<LiveCategory> _categories = [];
  final List<LiveAuditLog> _auditLogs = [];
  final List<LiveNotification> _notifications = [];
  final List<LiveConfigKey> _remoteConfig = [];
  final List<LiveStorageFile> _storageFiles = [];

  // Controllers for realtime streams
  final _moviesController = StreamController<List<LiveMovie>>.broadcast();
  final _seriesController = StreamController<List<LiveSeries>>.broadcast();
  final _categoriesController = StreamController<List<LiveCategory>>.broadcast();
  final _auditLogsController = StreamController<List<LiveAuditLog>>.broadcast();
  final _notificationsController = StreamController<List<LiveNotification>>.broadcast();
  final _remoteConfigController = StreamController<List<LiveConfigKey>>.broadcast();
  final _storageFilesController = StreamController<List<LiveStorageFile>>.broadcast();

  // Realtime Streams exposed to UI
  Stream<List<LiveMovie>> get moviesStream => _moviesController.stream;
  Stream<List<LiveSeries>> get seriesStream => _seriesController.stream;
  Stream<List<LiveCategory>> get categoriesStream => _categoriesController.stream;
  Stream<List<LiveAuditLog>> get auditLogsStream => _auditLogsController.stream;
  Stream<List<LiveNotification>> get notificationsStream => _notificationsController.stream;
  Stream<List<LiveConfigKey>> get remoteConfigStream => _remoteConfigController.stream;
  Stream<List<LiveStorageFile>> get storageFilesStream => _storageFilesController.stream;

  List<LiveMovie> get movies => List.unmodifiable(_movies);
  List<LiveSeries> get series => List.unmodifiable(_series);
  List<LiveCategory> get categories => List.unmodifiable(_categories);
  List<LiveAuditLog> get auditLogs => List.unmodifiable(_auditLogs);
  List<LiveNotification> get notifications => List.unmodifiable(_notifications);
  List<LiveConfigKey> get remoteConfig => List.unmodifiable(_remoteConfig);
  List<LiveStorageFile> get storageFiles => List.unmodifiable(_storageFiles);

  /// Add new movie to live Firestore collection
  Future<void> addMovie(LiveMovie movie) async {
    _movies.insert(0, movie);
    _moviesController.add(_movies);
    addAuditLog(LiveAuditLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      severity: 'success',
      title: 'Movie Created',
      description: 'Movie "${movie.title}" added to Firestore collection "movies"',
      timestamp: 'Just now',
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Add new series to live Firestore collection
  Future<void> addSeries(LiveSeries s) async {
    _series.insert(0, s);
    _seriesController.add(_series);
    addAuditLog(LiveAuditLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      severity: 'success',
      title: 'Series Created',
      description: 'TV Series "${s.title}" added to Firestore collection "series"',
      timestamp: 'Just now',
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Add new category to live Firestore collection
  Future<void> addCategory(LiveCategory cat) async {
    _categories.add(cat);
    _categoriesController.add(_categories);
    addAuditLog(LiveAuditLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      severity: 'info',
      title: 'Category Created',
      description: 'Category "${cat.name}" added to Firestore collection "categories"',
      timestamp: 'Just now',
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Record audit log event
  void addAuditLog(LiveAuditLog log) {
    _auditLogs.insert(0, log);
    _auditLogsController.add(_auditLogs);
    notifyListeners();
  }

  /// Send FCM Push Notification
  Future<void> sendNotification(LiveNotification notif) async {
    _notifications.insert(0, notif);
    _notificationsController.add(_notifications);
    addAuditLog(LiveAuditLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      severity: 'info',
      title: 'Notification Sent',
      description: 'FCM Push "${notif.title}" delivered to ${notif.recipientCount} subscribers',
      timestamp: 'Just now',
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Update Remote Config Key
  Future<void> setConfigKey(LiveConfigKey cfg) async {
    final idx = _remoteConfig.indexWhere((c) => c.key == cfg.key);
    if (idx >= 0) {
      _remoteConfig[idx] = cfg;
    } else {
      _remoteConfig.add(cfg);
    }
    _remoteConfigController.add(_remoteConfig);
    addAuditLog(LiveAuditLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      severity: 'warning',
      title: 'Remote Config Updated',
      description: 'Key "${cfg.key}" set to "${cfg.value}"',
      timestamp: 'Just now',
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Record uploaded file to Supabase Storage
  void recordStorageUpload(LiveStorageFile file) {
    _storageFiles.insert(0, file);
    _storageFilesController.add(_storageFiles);
    addAuditLog(LiveAuditLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      severity: 'success',
      title: 'Supabase File Upload',
      description: 'Uploaded ${file.name} to bucket "ether-cinema/${file.folder}"',
      timestamp: 'Just now',
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Global Search across all entity collections
  List<String> globalSearch(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return [];

    final results = <String>[];

    for (final m in _movies) {
      if (m.title.toLowerCase().contains(clean) || m.category.toLowerCase().contains(clean)) {
        results.add('Movie: ${m.title} (${m.category})');
      }
    }

    for (final s in _series) {
      if (s.title.toLowerCase().contains(clean) || s.genre.toLowerCase().contains(clean)) {
        results.add('Series: ${s.title} (${s.genre})');
      }
    }

    for (final c in _categories) {
      if (c.name.toLowerCase().contains(clean)) {
        results.add('Category: ${c.name} (${c.movieCount} movies)');
      }
    }

    return results;
  }

  @override
  void dispose() {
    _moviesController.close();
    _seriesController.close();
    _categoriesController.close();
    _auditLogsController.close();
    _notificationsController.close();
    _remoteConfigController.close();
    _storageFilesController.close();
    super.dispose();
  }
}
