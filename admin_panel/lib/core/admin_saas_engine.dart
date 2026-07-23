import 'package:flutter/foundation.dart';

class SaaSAnalyticsMetrics {
  final int activeConcurrentStreams;
  final double storageUsageGb;
  final double bandwidthUsageTb;
  final double crashRatePercent;
  final int dailyActiveUsers;

  const SaaSAnalyticsMetrics({
    required this.activeConcurrentStreams,
    required this.storageUsageGb,
    required this.bandwidthUsageTb,
    required this.crashRatePercent,
    required this.dailyActiveUsers,
  });
}

class SaaSAnalyticsEngine {
  static SaaSAnalyticsMetrics fetchRealtimeMetrics() {
    return const SaaSAnalyticsMetrics(
      activeConcurrentStreams: 14280,
      storageUsageGb: 412.8,
      bandwidthUsageTb: 18.4,
      crashRatePercent: 0.01,
      dailyActiveUsers: 85400,
    );
  }
}

class PermissionMatrix {
  static bool hasPermission(String role, String permission) {
    if (role == 'super_admin') return true;
    if (role == 'admin') {
      return permission != 'DELETE_ADMIN' && permission != 'SECURITY_OVERRIDE';
    }
    if (role == 'moderator') {
      return permission == 'EDIT_METADATA' || permission == 'MODERATE_REPORT' || permission == 'VIEW_ANALYTICS';
    }
    return false;
  }
}

class GlobalAdminSearch {
  static List<String> searchEntity(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return [];

    final mockEntities = [
      'Movie: Nebula Drift (x8m00bc)',
      'Movie: Quantum Abyss 4K',
      'User: admin@ethercinema.com (Super Admin)',
      'User: alexander_vip (Adult Profile)',
      'Category: Sci-Fi & Cyberpunk',
      'Report: Content Flag #1042',
    ];

    return mockEntities.where((e) => e.toLowerCase().contains(clean)).toList();
  }
}
