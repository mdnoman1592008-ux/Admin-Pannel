import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/liquid_button.dart';

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

  int _selectedTab = 0; // 0: Analytics, 1: Dailymotion Video Manager, 2: Push Notifications

  @override
  Widget build(BuildContext context) {
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
              'Ether Admin Portal',
              style: TextStyle(
                fontSize: 20,
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
            // Admin Navigation Tabs
            Row(
              children: [
                _buildTabButton(0, 'Analytics', Icons.analytics_rounded),
                const SizedBox(width: 8),
                _buildTabButton(1, 'Video Manager', Icons.video_library_rounded),
                const SizedBox(width: 8),
                _buildTabButton(2, 'Notifications', Icons.notifications_active_rounded),
              ],
            ),
            const SizedBox(height: 24),

            if (_selectedTab == 0) ...[
              // Analytics Overview
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
              // Dailymotion Video Link Manager
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
                        labelText: 'Dailymotion Video URL or ID (e.g. x8m00bc)',
                        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _synopsisController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Synopsis Metadata',
                        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LiquidButton(
                      label: 'Publish to Platform Catalog',
                      icon: Icons.publish_rounded,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dailymotion video link published successfully!'),
                          ),
                        );
                        _titleController.clear();
                        _dailymotionUrlController.clear();
                        _synopsisController.clear();
                      },
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Push Notification Center
              GlassContainer(
                borderRadius: 24,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Global Broadcast Notification',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                    ),
                    const SizedBox(height: 16),
                    const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Announcement Title',
                        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const TextField(
                      style: TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Notification Message Body',
                        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LiquidButton(
                      label: 'Send Push Notification',
                      icon: Icons.send_rounded,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Broadcast alert sent to all 18,490 active users!'),
                          ),
                        );
                      },
                    ),
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
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(vertical: 12),
          borderColor: isSelected ? AppColors.primaryContainer : AppColors.glassBorder,
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primaryContainer : Colors.white60, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.primaryContainer : Colors.white60,
                ),
              ),
            ],
          ),
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
