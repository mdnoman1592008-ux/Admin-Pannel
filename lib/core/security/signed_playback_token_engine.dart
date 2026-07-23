import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../logging/app_logger.dart';

class SignedPlaybackToken {
  final String tokenId;
  final String videoId;
  final String userId;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String signature;

  SignedPlaybackToken({
    required this.tokenId,
    required this.videoId,
    required this.userId,
    required this.issuedAt,
    required this.expiresAt,
    required this.signature,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class SignedPlaybackTokenEngine {
  static const int tokenTtlSeconds = 300; // 5 minutes TTL
  static final Map<String, SignedPlaybackToken> _activeTokens = {};

  static SignedPlaybackToken issuePlaybackToken({
    required String videoId,
    required String userId,
  }) {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(seconds: tokenTtlSeconds));
    final tokenId = 'spt_${now.millisecondsSinceEpoch}_${videoId}_$userId';
    
    // Simulate server-side cryptographic HMAC-SHA256 signature
    final rawSignaturePayload = '$tokenId|$videoId|$userId|${expiresAt.millisecondsSinceEpoch}';
    final signature = base64Encode(utf8.encode(rawSignaturePayload));

    final token = SignedPlaybackToken(
      tokenId: tokenId,
      videoId: videoId,
      userId: userId,
      issuedAt: now,
      expiresAt: expiresAt,
      signature: signature,
    );

    _activeTokens[tokenId] = token;
    AppLogger.i('SignedPlaybackTokenEngine', 'Issued short-lived playback token: $tokenId (Expires in ${tokenTtlSeconds}s)');
    return token;
  }

  static bool validatePlaybackRequest({
    required String tokenId,
    required String videoId,
    required String userId,
  }) {
    final token = _activeTokens[tokenId];
    if (token == null) {
      AppLogger.w('SignedPlaybackTokenEngine', 'Playback denied: Token $tokenId not found or revoked.');
      return false;
    }

    if (token.isExpired) {
      _activeTokens.remove(tokenId);
      AppLogger.w('SignedPlaybackTokenEngine', 'Playback denied: Token $tokenId has expired.');
      return false;
    }

    if (token.videoId != videoId || token.userId != userId) {
      AppLogger.w('SignedPlaybackTokenEngine', 'Playback denied: Token identity mismatch.');
      return false;
    }

    AppLogger.i('SignedPlaybackTokenEngine', 'Playback authorized for video [$videoId] user [$userId].');
    return true;
  }

  static void revokeToken(String tokenId) {
    _activeTokens.remove(tokenId);
    AppLogger.i('SignedPlaybackTokenEngine', 'Revoked playback token: $tokenId');
  }

  static void clearExpiredTokens() {
    _activeTokens.removeWhere((id, token) => token.isExpired);
  }
}
