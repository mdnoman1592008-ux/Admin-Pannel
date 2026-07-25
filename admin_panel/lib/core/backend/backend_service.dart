import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final String synopsis;
  final String contentType;
  final String sourceProvider;
  final String sourceUrl;
  final List<String> playlistIds;
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
    this.synopsis = '',
    this.contentType = 'movie',
    this.sourceProvider = '',
    this.sourceUrl = '',
    this.playlistIds = const [],
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
      synopsis: data['synopsis'] as String? ?? '',
      contentType: data['contentType'] as String? ?? 'movie',
      sourceProvider: data['sourceProvider'] as String? ?? '',
      sourceUrl: (data['sourceUrl'] as String?) ??
          (data['dailymotionVideoId'] as String?) ??
          '',
      playlistIds: List<String>.from(data['playlistIds'] ?? const []),
      createdAt: _asDateTime(data['createdAt']),
      updatedAt: _asDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'category': category,
        'genres': [category],
        'dailymotionVideoId': sourceProvider == 'dailymotion' ? sourceUrl : '',
        'sourceProvider': sourceProvider,
        'sourceUrl': sourceUrl,
        'contentType': contentType,
        'playlistIds': playlistIds,
        'synopsis': synopsis,
        'posterUrl': posterUrl,
        'bannerUrl': bannerUrl,
        'views': views,
        'isPublished': isPublished,
        'isFeatured': isFeatured,
        'year': year,
        'releaseDate': Timestamp.fromDate(
            DateTime.tryParse('$year-01-01') ?? DateTime.now()),
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  LiveMovie copyWith({bool? isPublished, bool? isFeatured}) => LiveMovie(
        id: id,
        title: title,
        category: category,
        posterUrl: posterUrl,
        bannerUrl: bannerUrl,
        views: views,
        isPublished: isPublished ?? this.isPublished,
        isFeatured: isFeatured ?? this.isFeatured,
        year: year,
        synopsis: synopsis,
        contentType: contentType,
        sourceProvider: sourceProvider,
        sourceUrl: sourceUrl,
        playlistIds: playlistIds,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

DateTime _asDateTime(Object? value) {
  if (value is Timestamp) return value.toDate();
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
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
      createdAt: _asDateTime(data['createdAt']),
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
      createdAt: _asDateTime(data['createdAt']),
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

  factory LiveNotification.fromFirestore(
      Map<String, dynamic> data, String docId) {
    return LiveNotification(
      id: docId,
      title: data['title'] as String? ?? 'Push Notification',
      body: data['body'] as String? ?? '',
      target: data['target'] as String? ?? 'all',
      recipientCount: (data['recipientCount'] as num?)?.toInt() ?? 0,
      sentAt: _asDateTime(data['sentAt']),
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      _subscriptions = [];
  bool _started = false;

  // Local projections of Firestore's realtime collections. Firestore is the
  // source of truth; these lists are never used as a persistence layer.
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
  final _categoriesController =
      StreamController<List<LiveCategory>>.broadcast();
  final _auditLogsController = StreamController<List<LiveAuditLog>>.broadcast();
  final _notificationsController =
      StreamController<List<LiveNotification>>.broadcast();
  final _remoteConfigController =
      StreamController<List<LiveConfigKey>>.broadcast();
  final _storageFilesController =
      StreamController<List<LiveStorageFile>>.broadcast();

  // Realtime Streams exposed to UI
  Stream<List<LiveMovie>> get moviesStream => _moviesController.stream;
  Stream<List<LiveSeries>> get seriesStream => _seriesController.stream;
  Stream<List<LiveCategory>> get categoriesStream =>
      _categoriesController.stream;
  Stream<List<LiveAuditLog>> get auditLogsStream => _auditLogsController.stream;
  Stream<List<LiveNotification>> get notificationsStream =>
      _notificationsController.stream;
  Stream<List<LiveConfigKey>> get remoteConfigStream =>
      _remoteConfigController.stream;
  Stream<List<LiveStorageFile>> get storageFilesStream =>
      _storageFilesController.stream;

  List<LiveMovie> get movies => List.unmodifiable(_movies);
  List<LiveSeries> get series => List.unmodifiable(_series);
  List<LiveCategory> get categories => List.unmodifiable(_categories);
  List<LiveAuditLog> get auditLogs => List.unmodifiable(_auditLogs);
  List<LiveNotification> get notifications => List.unmodifiable(_notifications);
  List<LiveConfigKey> get remoteConfig => List.unmodifiable(_remoteConfig);
  List<LiveStorageFile> get storageFiles => List.unmodifiable(_storageFiles);

  /// Starts realtime listeners for every admin collection.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    _subscriptions.add(_firestore.collection('movies').snapshots().listen((snapshot) {
      _movies
        ..clear()
        ..addAll(snapshot.docs
            .map((doc) => LiveMovie.fromFirestore(doc.data(), doc.id)));
      _movies.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      _moviesController.add(List.unmodifiable(_movies));
      notifyListeners();
    }, onError: (Object error, StackTrace stackTrace) {
      debugPrint('[LiveBackendService] movies listener failed: $error');
    }));
    _subscriptions.add(_firestore.collection('series').snapshots().listen((snapshot) {
      _series
        ..clear()
        ..addAll(snapshot.docs.map((doc) => LiveSeries.fromFirestore(doc.data(), doc.id)));
      _series.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _seriesController.add(List.unmodifiable(_series));
      notifyListeners();
    }, onError: (Object error, StackTrace stackTrace) => debugPrint('[LiveBackendService] series listener failed: $error')));
    _subscriptions.add(_firestore.collection('categories').snapshots().listen((snapshot) {
      _categories
        ..clear()
        ..addAll(snapshot.docs.map((doc) => LiveCategory.fromFirestore(doc.data(), doc.id)));
      _categoriesController.add(List.unmodifiable(_categories));
      notifyListeners();
    }, onError: (Object error, StackTrace stackTrace) => debugPrint('[LiveBackendService] categories listener failed: $error')));
    _subscriptions.add(_firestore.collection('audit_logs').snapshots().listen((snapshot) {
      _auditLogs
        ..clear()
        ..addAll(snapshot.docs.map((doc) => LiveAuditLog.fromFirestore(doc.data(), doc.id)));
      _auditLogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _auditLogsController.add(List.unmodifiable(_auditLogs));
      notifyListeners();
    }, onError: (Object error, StackTrace stackTrace) => debugPrint('[LiveBackendService] audit listener failed: $error')));
    _subscriptions.add(_firestore.collection('notifications').snapshots().listen((snapshot) {
      _notifications
        ..clear()
        ..addAll(snapshot.docs.map((doc) => LiveNotification.fromFirestore(doc.data(), doc.id)));
      _notifications.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      _notificationsController.add(List.unmodifiable(_notifications));
      notifyListeners();
    }, onError: (Object error, StackTrace stackTrace) => debugPrint('[LiveBackendService] notifications listener failed: $error')));
    _subscriptions.add(_firestore.collection('remote_config').snapshots().listen((snapshot) {
      _remoteConfig
        ..clear()
        ..addAll(snapshot.docs.map((doc) => LiveConfigKey.fromFirestore(doc.data(), doc.id)));
      _remoteConfigController.add(List.unmodifiable(_remoteConfig));
      notifyListeners();
    }, onError: (Object error, StackTrace stackTrace) => debugPrint('[LiveBackendService] remote config listener failed: $error')));
    _subscriptions.add(_firestore.collection('storage_files').snapshots().listen((snapshot) {
      _storageFiles
        ..clear()
        ..addAll(snapshot.docs.map((doc) => LiveStorageFile(
          name: doc.data()['name'] as String? ?? doc.id,
          path: doc.data()['path'] as String? ?? '',
          sizeBytes: (doc.data()['sizeBytes'] as num?)?.toInt() ?? 0,
          folder: doc.data()['folder'] as String? ?? '',
          uploadedAt: _asDateTime(doc.data()['uploadedAt']),
        )));
      _storageFiles.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
      _storageFilesController.add(List.unmodifiable(_storageFiles));
      notifyListeners();
    }, onError: (Object error, StackTrace stackTrace) => debugPrint('[LiveBackendService] storage listener failed: $error')));
  }

  /// Add new movie to live Firestore collection
  Future<void> addMovie(LiveMovie movie) async {
    await _firestore
        .collection('movies')
        .doc(movie.id)
        .set(movie.toFirestore());
    await _writeAudit('Movie Created',
        'Movie "${movie.title}" added to Firestore collection "movies"');
  }

  Future<void> updateMovie(LiveMovie movie) async {
    await _firestore.collection('movies').doc(movie.id).set(
          movie.toFirestore()..['updatedAt'] = FieldValue.serverTimestamp(),
          SetOptions(merge: true),
        );
    await _writeAudit('Movie Updated', 'Movie "${movie.title}" was updated.');
  }

  Future<void> deleteMovie(String movieId) async {
    await _firestore.collection('movies').doc(movieId).delete();
    await _writeAudit('Movie Deleted', 'Movie "$movieId" was removed.');
  }

  /// Add new series to live Firestore collection
  Future<void> addSeries(LiveSeries s) async {
    await _firestore.collection('series').doc(s.id).set({
      'title': s.title, 'genre': s.genre, 'seasons': s.seasons,
      'episodes': s.episodes, 'status': s.status, 'isFeatured': s.isFeatured,
      'views': s.views, 'posterUrl': s.posterUrl,
      'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
    });
    await _writeAudit('Series Created', 'TV Series "${s.title}" was created.');
  }

  /// Add new category to live Firestore collection
  Future<void> addCategory(LiveCategory cat) async {
    await _firestore.collection('categories').doc(cat.id).set({
      'name': cat.name, 'iconName': cat.iconName, 'colorHex': cat.colorHex,
      'movieCount': cat.movieCount, 'updatedAt': FieldValue.serverTimestamp(),
    });
    await _writeAudit('Category Created', 'Category "${cat.name}" was created.');
  }

  Future<void> updateCategory(LiveCategory category) async {
    await _firestore.collection('categories').doc(category.id).set({
      'name': category.name,
      'iconName': category.iconName,
      'colorHex': category.colorHex,
      'movieCount': category.movieCount,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _writeAudit('Category Updated', 'Category "${category.name}" was updated.');
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).delete();
    await _writeAudit('Category Deleted', 'Category "$categoryId" was deleted.');
  }

  /// Record audit log event
  Future<void> _writeAudit(String title, String description) async {
    await _firestore.collection('audit_logs').add({
      'severity': 'info',
      'title': title,
      'description': description,
      'timestamp': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Queues a notification request. A trusted Cloud Function must deliver it
  /// and update its delivery status; the browser never sends FCM directly.
  Future<void> sendNotification(LiveNotification notif) async {
    await _firestore.collection('notifications').doc(notif.id).set({
      'title': notif.title, 'body': notif.body, 'target': notif.target,
      'recipientCount': 0, 'status': 'queued',
      'sentAt': FieldValue.serverTimestamp(),
    });
    await _writeAudit('Notification Queued', 'Push "${notif.title}" was queued for server delivery.');
  }

  /// Update Remote Config Key
  Future<void> setConfigKey(LiveConfigKey cfg) async {
    await _firestore.collection('remote_config').doc(cfg.key).set({
      'value': cfg.value, 'type': cfg.type, 'description': cfg.description,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _writeAudit('Remote Config Updated', 'Key "${cfg.key}" was updated.');
  }

  /// Record uploaded file to Supabase Storage
  Future<void> recordStorageUpload(LiveStorageFile file) async {
    await _firestore.collection('storage_files').add({
      'name': file.name, 'path': file.path, 'sizeBytes': file.sizeBytes,
      'folder': file.folder, 'uploadedAt': FieldValue.serverTimestamp(),
    });
    await _writeAudit('Media Uploaded', 'Uploaded ${file.name} to ${file.folder}.');
  }

  /// Global Search across all entity collections
  List<String> globalSearch(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return [];

    final results = <String>[];

    for (final m in _movies) {
      if (m.title.toLowerCase().contains(clean) ||
          m.category.toLowerCase().contains(clean)) {
        results.add('Movie: ${m.title} (${m.category})');
      }
    }

    for (final s in _series) {
      if (s.title.toLowerCase().contains(clean) ||
          s.genre.toLowerCase().contains(clean)) {
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
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
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
