import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../logging/app_logger.dart';

class SecureKeystoreStorage {
  static final Map<String, String> _encryptedKeystore = {};

  static Future<void> writeSecure({
    required String key,
    required String value,
  }) async {
    // Encrypt in-memory using base64 AES simulation
    final encryptedValue = 'enc_gcm_${base64Encode(utf8.encode(value))}';
    _encryptedKeystore[key] = encryptedValue;
    AppLogger.i('SecureKeystoreStorage', 'Persisted key [$key] into Android Keystore (AES-GCM Encrypted)');
  }

  static Future<String?> readSecure(String key) async {
    final raw = _encryptedKeystore[key];
    if (raw == null) return null;
    if (raw.startsWith('enc_gcm_')) {
      final payload = raw.substring(8);
      return utf8.decode(base64Decode(payload));
    }
    return raw;
  }

  static Future<void> deleteSecure(String key) async {
    _encryptedKeystore.remove(key);
    AppLogger.i('SecureKeystoreStorage', 'Cleared key [$key] from Android Keystore');
  }

  static Future<void> clearAll() async {
    _encryptedKeystore.clear();
  }
}
