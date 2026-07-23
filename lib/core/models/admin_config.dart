class AdminConfig {
  final bool isMaintenanceMode;
  final String maintenanceNotice;
  final String remoteBannerMessage;
  final bool isRemoteBannerActive;

  const AdminConfig({
    this.isMaintenanceMode = false,
    this.maintenanceNotice = 'Ether Cinema is undergoing scheduled 3D engine upgrades. Back online shortly!',
    this.remoteBannerMessage = '✨ New IMAX 4K Releases Available Now!',
    this.isRemoteBannerActive = true,
  });

  Map<String, dynamic> toJson() => {
        'isMaintenanceMode': isMaintenanceMode,
        'maintenanceNotice': maintenanceNotice,
        'remoteBannerMessage': remoteBannerMessage,
        'isRemoteBannerActive': isRemoteBannerActive,
      };

  factory AdminConfig.fromJson(Map<String, dynamic> json) => AdminConfig(
        isMaintenanceMode: json['isMaintenanceMode'] ?? false,
        maintenanceNotice: json['maintenanceNotice'] ?? '',
        remoteBannerMessage: json['remoteBannerMessage'] ?? '',
        isRemoteBannerActive: json['isRemoteBannerActive'] ?? true,
      );
}
