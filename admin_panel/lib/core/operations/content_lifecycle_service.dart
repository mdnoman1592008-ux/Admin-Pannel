import 'package:flutter/foundation.dart';

/// Content Lifecycle Status State
enum ContentLifecycleState {
  draft,
  review,
  approved,
  scheduled,
  published,
  archived,
  softDeleted,
}

extension ContentLifecycleStateExtension on ContentLifecycleState {
  String toValue() {
    switch (this) {
      case ContentLifecycleState.draft:
        return 'draft';
      case ContentLifecycleState.review:
        return 'review';
      case ContentLifecycleState.approved:
        return 'approved';
      case ContentLifecycleState.scheduled:
        return 'scheduled';
      case ContentLifecycleState.published:
        return 'published';
      case ContentLifecycleState.archived:
        return 'archived';
      case ContentLifecycleState.softDeleted:
        return 'soft_deleted';
    }
  }

  static ContentLifecycleState fromValue(String? value) {
    switch (value?.toLowerCase()) {
      case 'draft':
        return ContentLifecycleState.draft;
      case 'review':
        return ContentLifecycleState.review;
      case 'approved':
        return ContentLifecycleState.approved;
      case 'scheduled':
        return ContentLifecycleState.scheduled;
      case 'published':
        return ContentLifecycleState.published;
      case 'archived':
        return ContentLifecycleState.archived;
      case 'soft_deleted':
        return ContentLifecycleState.softDeleted;
      default:
        return ContentLifecycleState.draft;
    }
  }
}

/// Content Version Record
class ContentVersion {
  final int versionNumber;
  final String editorUid;
  final String editorEmail;
  final DateTime timestamp;
  final List<String> changedFields;
  final Map<String, dynamic> snapshot;

  const ContentVersion({
    required this.versionNumber,
    required this.editorUid,
    required this.editorEmail,
    required this.timestamp,
    required this.changedFields,
    required this.snapshot,
  });
}

/// Scheduled Content Dispatch Target
class ScheduledPublishTask {
  final String taskId;
  final String resourceType; // 'movie' | 'series' | 'banner' | 'notification'
  final String resourceId;
  final DateTime scheduledTimeUtc;
  final String adminEmail;
  bool isExecuted;

  ScheduledPublishTask({
    required this.taskId,
    required this.resourceType,
    required this.resourceId,
    required this.scheduledTimeUtc,
    required this.adminEmail,
    this.isExecuted = false,
  });
}

/// Content Lifecycle, Version History & Scheduler Engine
class ContentLifecycleService extends ChangeNotifier {
  static final ContentLifecycleService _instance = ContentLifecycleService._internal();
  factory ContentLifecycleService() => _instance;
  static ContentLifecycleService get instance => _instance;

  ContentLifecycleService._internal();

  final Map<String, List<ContentVersion>> _versionHistory = {};
  final List<ScheduledPublishTask> _scheduledTasks = [];

  List<ScheduledPublishTask> get scheduledTasks => List.unmodifiable(_scheduledTasks);

  /// Create a new version for a content item
  void recordVersion({
    required String resourceId,
    required String editorUid,
    required String editorEmail,
    required List<String> changedFields,
    required Map<String, dynamic> snapshotData,
  }) {
    final versions = _versionHistory.putIfAbsent(resourceId, () => []);
    final nextVersion = versions.length + 1;

    versions.add(
      ContentVersion(
        versionNumber: nextVersion,
        editorUid: editorUid,
        editorEmail: editorEmail,
        timestamp: DateTime.now().toUtc(),
        changedFields: changedFields,
        snapshot: Map.from(snapshotData),
      ),
    );

    notifyListeners();
  }

  /// Get version history for a resource
  List<ContentVersion> getVersionHistory(String resourceId) {
    return _versionHistory[resourceId] ?? [];
  }

  /// Schedule a resource for future publishing
  void schedulePublish({
    required String resourceType,
    required String resourceId,
    required DateTime scheduledTimeUtc,
    required String adminEmail,
  }) {
    _scheduledTasks.add(
      ScheduledPublishTask(
        taskId: 'sch_${DateTime.now().millisecondsSinceEpoch}',
        resourceType: resourceType,
        resourceId: resourceId,
        scheduledTimeUtc: scheduledTimeUtc,
        adminEmail: adminEmail,
      ),
    );
    notifyListeners();
  }
}
