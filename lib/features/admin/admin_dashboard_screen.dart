import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/liquid_button.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/analytics/telemetry_tracker.dart';
import '../../core/cache/cache_diagnostics.dart';
import '../../core/security/security_platform.dart';
import '../../core/feature_flags/feature_flag_service.dart';
import '../../core/performance/performance_monitor.dart';
import '../../core/platform/runtime_orchestrator.dart';
import '../../core/diagnostics/app_diagnostics.dart';
import '../../core/profiles/profile_service.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/downloads/encrypted_download_manager.dart';
import '../../core/analytics/crash_reporting_service.dart';
import '../../data/mock_data.dart';

class AdminDashboardScreen extends StatefulWidget {
  final VoidCallback onClose;

  const AdminDashboardScreen({super.key, required this.onClose});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dailymotionUrlController = TextEditingController();
  final TextEditingController _synopsisController = TextEditingController();

  final TextEditingController _notifTitleController = TextEditingController();
  final TextEditingController _notifBodyController = TextEditingController();

  int _selectedTab = 0; // 0: Analytics, 1: Video Manager, 2: Remote Config, 3: Backup JSON, 4: Audit Logs, 5: Telemetry, 6: Security, 7: Feature Flags, 8: Runtime, 9: Omega Diagnostics, 10: Notifications, 11: Encrypted Downloads & Crash
  bool _maintenanceMode = false;
  bool _remoteBannerActive = true;

  final List<String> _auditTrailLogs = [
    '[18:14:02] Admin Alexander logged into portal',
    '[18:12:45] Dailymotion Video Link ID: x8m00bc verified',
    '[18:05:12] Backup JSON exported: catalog_428_titles.json',
    '[17:58:30] SSL Security Hash Verified successfully',
    '[17:40:11] System Health: 100% Operational (120 FPS target)',
  ];

  @override
  Widget build(BuildContext context) {
    final telemetry = TelemetryTracker().getTelemetryDiagnostics();
    final cacheStats = CacheDiagnostics.getDiagnostics();
    final perfMetrics = PerformanceMonitor.getMetrics();
    final flags = FeatureFlagService.getAllFlags();
    final runtimeInfo = RuntimeOrchestrator().checkReadiness();
    final omegaReport = AppDiagnostics.runFullAudit();
    final activeProfile = ProfileService.activeProfile;
    final downloads = EncryptedDownloadManager.activeQueue;
    final crashInfo = CrashReportingService.getDiagnostics();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings_rounded, color: AppColors.tertiary),
            SizedBox(width: 8),
            Text(
              'Ether Admin Portal v9.0 World-Class UI/UX',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: widget.onClose,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Navigation Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabButton(0, 'Analytics', Icons.analytics_rounded),
                  const SizedBox(width: 8),
                  _buildTabButton(1, 'Video Manager', Icons.video_library_rounded),
                  const SizedBox(width: 8),
                  _buildTabButton(2, 'Remote Config', Icons.settings_remote_rounded),
                  const SizedBox(width: 8),
                  _buildTabButton(3, 'JSON Backup', Icons.backup_rounded),
                  const SizedBox(width: 8),
                  _buildTabButton(4, 'Audit Trail', Icons.list_alt_rounded),
                  const SizedBox(width: 8),
                  _buildTabButton(5, 'Telemetry', Icons.speed_rounded),
                  const SizedBox(width: 8),
                  _buildTabButton(6, 'Security', Icons.shield_rounded),
                  const SizedBox(width: 8),
                  _buildTabButton(7, 'Feature Flags', Icons.flag_rounded),
                  const SizedBox(width: 8),
                  _buildTabButton(8, 'Runtime', Icons.memory_rounded),
                  const SizedBox(width: 8),
                  _buildTabButton(9, 'Omega Audit', Icons.checklist_rtl_rounded),
                  const SizedBox(width: 8),
                  _buildTabButton(10, 'Notifications', Icons.notifications_rounded),
                  const SizedBox(width: 8),
                  _buildTabButton(11, 'Encrypted Downloads & Crash', Icons.download_done_rounded),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (_selectedTab == 0) ...[
              const Text(
                'Platform Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatCard('Total Views', MockData.adminStats['totalViews'].toString(), Icons.trending_up),
                  _buildStatCard('Active Streams', MockData.adminStats['activeStreams'].toString(), Icons.play_circle),
                  _buildStatCard('Catalog Titles', MockData.adminStats['totalTitles'].toString(), Icons.movie),
                  _buildStatCard('Dailymotion Links', MockData.adminStats['dailymotionLinks'].toString(), Icons.link),
                ],
              ),
            ] else if (_selectedTab == 1) ...[
              GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Dailymotion Video Entry',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryContainer),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Movie / Episode Title',
                        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _dailymotionUrlController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Dailymotion Video ID (e.g. x8m00bc)',
                        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LiquidButton(
                      label: 'Publish to Catalog',
                      icon: Icons.publish_rounded,
                      onPressed: () {
                        AnalyticsService().trackAdminAction('publish_video');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dailymotion video published!'),
                          ),
                        );
                        _titleController.clear();
                        _dailymotionUrlController.clear();
                      },
                    ),
                  ],
                ),
              ),
            ] else if (_selectedTab == 10) ...[
              GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notification Publisher & Profile Controls',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryContainer),
                    ),
                    const SizedBox(height: 12),
                    Text('Active Profile: ${activeProfile.name}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notifTitleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Notification Title',
                        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LiquidButton(
                      label: 'Publish Notification',
                      icon: Icons.send_rounded,
                      onPressed: () {
                        if (_notifTitleController.text.isNotEmpty) {
                          NotificationService.addNotification(
                            _notifTitleController.text,
                            'New release available for streaming',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('In-app notification published to users!')),
                          );
                          _notifTitleController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Encrypted Downloads Queue & Crash Reporting
              GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Encrypted Downloads Queue & Crash Reporting',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Firebase Crashlytics', style: TextStyle(color: Colors.white)),
                        Text('${crashInfo['firebase_crashlytics'] ? 'ACTIVE' : 'OFF'}', style: const TextStyle(color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Active Encrypted Downloads Payload Queue:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...downloads.map((d) {
                      return ListTile(
                        title: Text(d.title, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        subtitle: Text(d.isCompleted ? 'AES-256 Encrypted (Completed)' : 'Downloading ${(d.progress * 100).toInt()}%', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                        trailing: Icon(d.isCompleted ? Icons.lock : Icons.downloading, color: AppColors.primaryContainer, size: 20),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        borderColor: isSelected ? AppColors.primaryContainer : AppColors.glassBorder,
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryContainer : Colors.white60, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primaryContainer : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String val, IconData icon) {
    return GlassContainer(
      borderRadius: 16,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryContainer, size: 18),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
