import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _cacheSize = '1.8 GB';

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

          GlassContainer(
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
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDzKwJZepW88E0hJiIBM4Vxba1Rpq3U50h9tkiPvp7xZJQK-mO2jMmpBbUeSRQbi8RFiA4qI7p9OGX6D5KDd63ubsU9_i6fdkW6RC-mW64KoyzIwowoe6zwbzI62x9DLZTHlWO0eABkKj5stmyuXQDPc12JQywmKdc1yNjmFOwic1xpNRC0aXvh3z81Pg_DP6CVgOLwf9QQzDXP88WrgFJo4NERkeXKJgYInTZCxEoQaioAg0i_neIHlapRuo2-ngOhlcuZFphmeA',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aether Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'subscriber@ethercinema.com',
                        style: TextStyle(
                          color: Color(0xFFBBC9CF),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00CFFF).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00CFFF).withValues(alpha: 0.5)),
                  ),
                  child: const Text(
                    'VIP 4K',
                    style: TextStyle(
                      color: Color(0xFF00CFFF),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSettingTile(
            icon: Icons.high_quality_rounded,
            title: 'Streaming Quality',
            subtitle: 'Auto (4K Ultra HD)',
            onTap: () {},
          ),
          const SizedBox(height: 12),

          _buildSettingTile(
            icon: Icons.download_for_offline_rounded,
            title: 'Download Settings',
            subtitle: 'Wi-Fi Only (1080p Full HD)',
            onTap: () {},
          ),
          const SizedBox(height: 12),

          _buildSettingTile(
            icon: Icons.cleaning_services_rounded,
            title: 'Clear Cache',
            subtitle: _cacheSize,
            trailingText: 'CLEAR',
            onTap: _clearCache,
          ),
          const SizedBox(height: 12),

          _buildSettingTile(
            icon: Icons.security_rounded,
            title: 'Privacy & Security',
            subtitle: 'Encrypted Token Storage',
            onTap: () {},
          ),
          const SizedBox(height: 12),

          _buildSettingTile(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: 'v18.0 Commercial Release (Pure Client)',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF00CFFF), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFBBC9CF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(
                  color: Color(0xFF00CFFF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }
}
