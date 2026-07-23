import 'dart:async';
import 'package:flutter/foundation.dart';

class RemoteAppConfig {
  final String appName;
  final String primaryColorHex;
  final bool maintenanceMode;
  final String minAppVersion;
  final String emergencyMessage;
  final bool forceUpdate;
  final bool heroAutoplayMuted;

  const RemoteAppConfig({
    required this.appName,
    required this.primaryColorHex,
    required this.maintenanceMode,
    required this.minAppVersion,
    required this.emergencyMessage,
    required this.forceUpdate,
    required this.heroAutoplayMuted,
  });

  RemoteAppConfig copyWith({
    String? appName,
    String? primaryColorHex,
    bool? maintenanceMode,
    String? minAppVersion,
    String? emergencyMessage,
    bool? forceUpdate,
    bool? heroAutoplayMuted,
  }) {
    return RemoteAppConfig(
      appName: appName ?? this.appName,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      minAppVersion: minAppVersion ?? this.minAppVersion,
      emergencyMessage: emergencyMessage ?? this.emergencyMessage,
      forceUpdate: forceUpdate ?? this.forceUpdate,
      heroAutoplayMuted: heroAutoplayMuted ?? this.heroAutoplayMuted,
    );
  }
}

class AppControlCenter {
  static final AppControlCenter _instance = AppControlCenter._internal();
  factory AppControlCenter() => _instance;
  AppControlCenter._internal();

  RemoteAppConfig _config = const RemoteAppConfig(
    appName: 'Ether Cinema OTT',
    primaryColorHex: '#00D4FF',
    maintenanceMode: false,
    minAppVersion: '14.0.0',
    emergencyMessage: '',
    forceUpdate: false,
    heroAutoplayMuted: true,
  );

  final _configStreamController = StreamController<RemoteAppConfig>.broadcast();

  RemoteAppConfig get config => _config;
  Stream<RemoteAppConfig> get configStream => _configStreamController.stream;

  void updateConfig(RemoteAppConfig newConfig) {
    _config = newConfig;
    _configStreamController.add(_config);
    debugPrint('[AppControlCenter] Updated Remote App Config: ${newConfig.appName} (Maintenance: ${newConfig.maintenanceMode})');
  }

  void toggleMaintenanceMode(bool enabled, String message) {
    _config = _config.copyWith(maintenanceMode: enabled, emergencyMessage: message);
    _configStreamController.add(_config);
    debugPrint('[AppControlCenter] Maintenance mode set to: $enabled');
  }
}

class ContentScheduler {
  final Map<String, DateTime> _scheduledReleases = {};

  void scheduleRelease(String contentId, DateTime releaseTime) {
    _scheduledReleases[contentId] = releaseTime;
    debugPrint('[ContentScheduler] Scheduled $contentId for ${releaseTime.toIso8601String()}');
  }

  bool isContentAvailable(String contentId) {
    final scheduled = _scheduledReleases[contentId];
    if (scheduled == null) return true;
    return DateTime.now().isAfter(scheduled);
  }
}

class UserSessionGuard {
  final Set<String> _revokedUserUids = {};

  void revokeUserSession(String uid) {
    _revokedUserUids.add(uid);
    debugPrint('[UserSessionGuard] Session revoked for user: $uid');
  }

  bool isSessionValid(String uid) {
    return !_revokedUserUids.contains(uid);
  }
}
