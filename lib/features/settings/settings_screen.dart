import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onOpenAdmin;

  const SettingsScreen({super.key, this.onOpenAdmin});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _tripleClickCount = 0;
  String _cacheSize = '1.8 GB';

  void _onProfileTap() {
    _tripleClickCount++;
    if (_tripleClickCount >= 3) {
      _tripleClickCount = 0;
      if (widget.onOpenAdmin != null) {
        widget.onOpenAdmin!();
      }
    }
  }

  void _clearCache() {
    setState(() {
      _cacheSize = '0 MB';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Streaming cache cleared successfully! 1.8 GB freed.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings & Account',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          GestureDetector(
            onTap: _onProfileTap,
            child: GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.liquidGradient,
                    ),
                    child: const CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.surface,
                      child: Icon(Icons.person, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alexander Vance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'VIP IMAX Member • Secret Admin Ready',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          _buildSettingTile(Icons.spatial_audio_off_rounded, 'Audio Quality', 'Dolby Atmos Spatial Audio', () {}),
          _buildSettingTile(Icons.hd_rounded, 'Video Playback', 'IMAX Enhanced 4K HDR (Dailymotion Adaptive)', () {}),
          _buildSettingTile(Icons.subtitles_rounded, 'Subtitles & Audio', 'English, Spanish, Japanese, French', () {}),
          _buildSettingTile(Icons.cleaning_services_rounded, 'Clear Stream Cache', 'Current Cache: $_cacheSize', _clearCache),
          _buildSettingTile(Icons.admin_panel_settings_rounded, 'Open Admin Dashboard', 'Manage Dailymotion Links & Catalog', () {
            if (widget.onOpenAdmin != null) {
              widget.onOpenAdmin!();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryContainer),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
