import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/core/security/app_integrity_guard.dart';
import 'package:ether_cinema/core/security/signed_playback_token_engine.dart';
import 'package:ether_cinema/core/security/network_security_guard.dart';
import 'package:ether_cinema/core/security/secure_keystore_storage.dart';
import 'package:ether_cinema/core/security/security_service.dart';

void main() {
  group('Enterprise Android Defensive Security Hardening Test Suite', () {
    test('Android R8 Shrinking & ProGuard Configuration should exist and contain rules', () {
      final proguardFile = File('android/app/proguard-rules.pro');
      expect(proguardFile.existsSync(), true);

      final content = proguardFile.readAsStringSync();
      expect(content.contains('com.google.firebase'), true);
      expect(content.contains('io.flutter'), true);
      expect(content.contains('-assumenosideeffects class android.util.Log'), true);

      final gradleFile = File('android/app/build.gradle.kts');
      expect(gradleFile.existsSync(), true);
      final gradleContent = gradleFile.readAsStringSync();
      expect(gradleContent.contains('isMinifyEnabled = true'), true);
      expect(gradleContent.contains('isShrinkResources = true'), true);
    });

    test('AppIntegrityGuard should verify signature hash and detect tampering', () {
      final report = AppIntegrityGuard.verifyAppIntegrity();
      expect(report.isValidSignature, true);
      expect(report.isTampered, false);
      expect(report.isSecure, true);

      final tamperedReport = AppIntegrityGuard.verifyAppIntegrity(simulateTamper: true);
      expect(tamperedReport.isTampered, true);
      expect(tamperedReport.isSecure, false);
    });

    test('AppIntegrityGuard should enable FLAG_SECURE screenshot protection', () {
      AppIntegrityGuard.enableScreenshotProtection();
      expect(AppIntegrityGuard.isScreenshotProtectionEnabled, true);
    });

    test('SignedPlaybackTokenEngine should issue and validate short-lived signed tokens', () {
      final token = SignedPlaybackTokenEngine.issuePlaybackToken(
        videoId: 'v101_quantum',
        userId: 'u9001',
      );

      expect(token.tokenId.startsWith('spt_'), true);
      expect(token.videoId, 'v101_quantum');
      expect(token.userId, 'u9001');
      expect(token.signature.isNotEmpty, true);
      expect(token.isExpired, false);

      final isValid = SignedPlaybackTokenEngine.validatePlaybackRequest(
        tokenId: token.tokenId,
        videoId: 'v101_quantum',
        userId: 'u9001',
      );
      expect(isValid, true);

      final isInvalidMismatch = SignedPlaybackTokenEngine.validatePlaybackRequest(
        tokenId: token.tokenId,
        videoId: 'wrong_video',
        userId: 'u9001',
      );
      expect(isInvalidMismatch, false);
    });

    test('SignedPlaybackTokenEngine should reject revoked and expired tokens', () {
      final token = SignedPlaybackTokenEngine.issuePlaybackToken(
        videoId: 'v202',
        userId: 'u55',
      );

      SignedPlaybackTokenEngine.revokeToken(token.tokenId);
      final isAuthorizedAfterRevoke = SignedPlaybackTokenEngine.validatePlaybackRequest(
        tokenId: token.tokenId,
        videoId: 'v202',
        userId: 'u55',
      );
      expect(isAuthorizedAfterRevoke, false);
    });

    test('NetworkSecurityGuard should enforce HTTPS and certificate pinning', () {
      expect(NetworkSecurityGuard.enforceHttps('https://ozqfltgvxlgpvytjofis.supabase.co'), true);
      expect(NetworkSecurityGuard.enforceHttps('http://insecure-endpoint.com'), false);

      final certValid = NetworkSecurityGuard.validateCertificatePinning(
        domain: 'ozqfltgvxlgpvytjofis.supabase.co',
        certificateFingerprint: 'sha256_mock_pin',
      );
      expect(certValid, true);

      final certInvalid = NetworkSecurityGuard.validateCertificatePinning(
        domain: 'ozqfltgvxlgpvytjofis.supabase.co',
        certificateFingerprint: 'bad_pin',
        simulateInvalidCert: true,
      );
      expect(certInvalid, false);
    });

    test('SecureKeystoreStorage should write and read AES-GCM encrypted local data', () async {
      await SecureKeystoreStorage.writeSecure(key: 'auth_jwt_token', value: 'secret_user_jwt_123');
      final decrypted = await SecureKeystoreStorage.readSecure('auth_jwt_token');
      expect(decrypted, 'secret_user_jwt_123');

      await SecureKeystoreStorage.deleteSecure('auth_jwt_token');
      final emptyResult = await SecureKeystoreStorage.readSecure('auth_jwt_token');
      expect(emptyResult, null);
    });

    test('SecurityService performSecurityAudit should pass defense-in-depth audit', () {
      final auditResult = SecurityService.performSecurityAudit();
      expect(auditResult, true);
    });
  });
}
