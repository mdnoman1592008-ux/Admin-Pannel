import 'dart:async';
import 'package:flutter/foundation.dart';

class SystemLatencyMetrics {
  final int firebaseAuthMs;
  final int firestoreMs;
  final int supabaseStorageMs;
  final int fcmPushMs;
  final int cdnNetworkMs;

  const SystemLatencyMetrics({
    required this.firebaseAuthMs,
    required this.firestoreMs,
    required this.supabaseStorageMs,
    required this.fcmPushMs,
    required this.cdnNetworkMs,
  });
}

class TelemetryErrorLog {
  final String id;
  final String source; // 'Firestore' | 'Supabase' | 'Auth' | 'FCM'
  final String errorMessage;
  final String stackTrace;
  final DateTime timestamp;

  const TelemetryErrorLog({
    required this.id,
    required this.source,
    required this.errorMessage,
    required this.stackTrace,
    required this.timestamp,
  });
}

/// Enterprise Observability, System Health & Telemetry Monitor
class ObservabilityService extends ChangeNotifier {
  static final ObservabilityService _instance = ObservabilityService._internal();
  factory ObservabilityService() => _instance;
  static ObservabilityService get instance => _instance;

  ObservabilityService._internal();

  final List<TelemetryErrorLog> _errorLogs = [];
  SystemLatencyMetrics _currentLatency = const SystemLatencyMetrics(
    firebaseAuthMs: 12,
    firestoreMs: 24,
    supabaseStorageMs: 42,
    fcmPushMs: 18,
    cdnNetworkMs: 85,
  );

  List<TelemetryErrorLog> get errorLogs => List.unmodifiable(_errorLogs);
  SystemLatencyMetrics get currentLatency => _currentLatency;

  int _failedUploadCount = 0;
  int get failedUploadCount => _failedUploadCount;

  int _totalNetworkRequests = 0;
  int get totalNetworkRequests => _totalNetworkRequests;

  /// Log a system telemetry error
  void recordError({
    required String source,
    required String message,
    String? stackTrace,
  }) {
    _errorLogs.insert(
      0,
      TelemetryErrorLog(
        id: 'err_${DateTime.now().millisecondsSinceEpoch}',
        source: source,
        errorMessage: message,
        stackTrace: stackTrace ?? 'No stack trace provided',
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  /// Increment failed upload telemetry counter
  void recordFailedUpload(String fileName, String reason) {
    _failedUploadCount++;
    recordError(
      source: 'Supabase Storage',
      message: 'Failed to upload $fileName: $reason',
    );
    notifyListeners();
  }

  /// Record network request telemetry
  void recordNetworkRequest() {
    _totalNetworkRequests++;
    notifyListeners();
  }

  /// Update latency metrics
  void updateLatency(SystemLatencyMetrics metrics) {
    _currentLatency = metrics;
    notifyListeners();
  }
}
