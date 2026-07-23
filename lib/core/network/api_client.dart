import 'dart:async';
import '../constants/app_constants.dart';

class ApiNetworkException implements Exception {
  final String message;
  final int? statusCode;

  ApiNetworkException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiNetworkException: $message (Code: $statusCode)';
}

class ApiClient {
  final String baseUrl;
  final Duration timeout;

  ApiClient({
    this.baseUrl = AppConstants.apiBaseUrl,
    this.timeout = const Duration(seconds: 10),
  });

  Future<T> executeWithRetry<T>(Future<T> Function() apiCall, {int retries = 3}) async {
    int attempt = 0;
    while (attempt < retries) {
      try {
        return await apiCall().timeout(timeout);
      } catch (e) {
        attempt++;
        if (attempt >= retries) {
          throw ApiNetworkException('Failed after $retries attempts: ${e.toString()}');
        }
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
    throw ApiNetworkException('Unexpected network error');
  }

  Future<Map<String, dynamic>> fetchDailymotionVideoMetadata(String videoId) async {
    return executeWithRetry(() async {
      // Simulate Dailymotion video metadata retrieval
      return {
        'id': videoId,
        'title': 'Stream metadata for $videoId',
        'provider': 'Dailymotion Adaptive Stream',
        'status': 'ready',
      };
    });
  }
}
