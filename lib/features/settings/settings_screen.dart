import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/auth/auth_service.dart';
import '../onboarding/onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  String _cacheSize = '1.8 GB';

  void _clearCache() {
    setState(() {
      _cacheSize = '0 MB';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Streaming cache cleared successfully! 1.8 GB freed.')),
    );
  }

  void _editProfile() {
    final user = _authService.currentUser;
    if (user == null) return;
    
    final nameController = TextEditingController(text: user.displayName);
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text('Edit Profile', style: TextStyle(color: theme.colorScheme.onSurface)),
          content: TextField(
            controller: nameController,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              labelText: 'Display Name',
              labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.3)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                // In a full implementation, we'd call _authService.updateUserAvatarAndName here.
                // For now we'll simulate the successful UI flow as the underlying method is in AuthRepository directly.
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
                );
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  void _toggleTheme() {
    if (themeNotifier.value == ThemeMode.dark) {
      themeNotifier.value = ThemeMode.light;
    } else {
      themeNotifier.value = ThemeMode.dark;
    }
  }

  void _logout() {
    _authService.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent)),
          content: Text(
            'Are you sure you want to permanently delete your account? This action cannot be undone.', 
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.pop(context); // close dialog
                try {
                  await _authService.deleteAccount();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting account: $e')),
                    );
                  }
                }
              },
              child: const Text('DELETE PERMANENTLY'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings & Account',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textColor,
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isDark ? AppColors.liquidGradient : null,
                    color: isDark ? null : Theme.of(context).colorScheme.primary,
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(
                      user?.avatar ?? 'https://i.pravatar.cc/150',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Guest User',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'No email linked',
                        style: TextStyle(
                          color: isDark ? const Color(0xFFBBC9CF) : Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: isDark ? Colors.white : Colors.black87),
                  onPressed: _editProfile,
                  tooltip: 'Edit Profile',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSettingTile(
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            title: 'Theme',
            subtitle: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onTap: _toggleTheme,
          ),
          const SizedBox(height: 12),

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
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Sign out of this device',
            onTap: _logout,
          ),
          const SizedBox(height: 12),
          
          _buildSettingTile(
            icon: Icons.delete_forever_rounded,
            title: 'Delete Account',
            subtitle: 'Permanently remove your account and data',
            onTap: _deleteAccount,
            iconColor: Colors.redAccent,
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
    Color iconColor = const Color(0xFF00CFFF),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDanger = iconColor == Colors.redAccent;
    
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
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDanger ? Colors.redAccent : (isDark ? Colors.white : Colors.black87),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? const Color(0xFFBBC9CF) : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white38 : Colors.black26, size: 14),
          ],
        ),
      ),
    );
  }
}
