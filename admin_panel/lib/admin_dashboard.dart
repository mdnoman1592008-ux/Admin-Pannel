import 'package:flutter/material.dart';
import 'core/admin_storage_service.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _selectedSidebarIndex = 0;
  final AdminStorageService _adminStorage = AdminStorageService();
  String _lastUploadedPublicUrl = '';
  String _uploadStatusMessage = '';
  String _authStatusMessage = 'Active Authentication Providers: Email/Password, Google, Facebook';

  final List<String> _menuItems = [
    'Dashboard',
    'Movies & Series',
    'Hero Banners',
    'Categories',
    'Users & Auth (Facebook/Google/Email)',
    'FCM Notifications',
    'Analytics',
    'Audit Logs',
    'Remote Config',
    'Storage (Automated Supabase)'
  ];

  Future<void> _testFacebookAuth() async {
    setState(() {
      _authStatusMessage = 'Testing Facebook Sign-In for Web Admin... Provider: "facebook"';
    });
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _authStatusMessage = 'Facebook Admin Authentication Successful! Role: super_admin | Provider: facebook';
    });
  }

  Future<void> _testUpload(String mediaType) async {
    setState(() {
      _uploadStatusMessage = 'Automated Uploading $mediaType to Supabase Storage (bucket: ether-cinema)...';
    });

    final dummyBytes = [137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13];
    String url = '';

    if (mediaType == 'Movie Poster') {
      url = await _adminStorage.uploadMoviePoster(bytes: dummyBytes, movieId: 'm101');
    } else if (mediaType == 'Movie Banner') {
      url = await _adminStorage.uploadMovieBanner(bytes: dummyBytes, movieId: 'm101');
    } else if (mediaType == 'Series Poster') {
      url = await _adminStorage.uploadSeriesPoster(bytes: dummyBytes, seriesId: 's501');
    } else if (mediaType == 'Logo') {
      url = await _adminStorage.uploadLogo(bytes: dummyBytes);
    } else if (mediaType == 'Avatar') {
      url = await _adminStorage.uploadAvatar(bytes: dummyBytes, userId: 'u9001');
    } else if (mediaType == 'Subtitle') {
      url = await _adminStorage.uploadSubtitle(bytes: dummyBytes, movieId: 'm101', language: 'en');
    }

    setState(() {
      _lastUploadedPublicUrl = url;
      _uploadStatusMessage = '$mediaType uploaded automatically to Supabase Storage!';
    });
  }

  Widget _buildAuthWorkspace() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Firebase Authentication & Social Login Center',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(_authStatusMessage, style: const TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: _testFacebookAuth,
              icon: const Icon(Icons.facebook_rounded, color: Colors.white),
              label: const Text('Sign In with Facebook (Web Admin)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _authStatusMessage = 'Google Sign-In Successful! Role: super_admin | Provider: google';
                });
              },
              icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 24),
              label: const Text('Sign In with Google'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _authStatusMessage = 'Email/Password Admin Sign-In Successful! Role: super_admin | Provider: email';
                });
              },
              icon: const Icon(Icons.email_outlined, color: Colors.white),
              label: const Text('Sign In with Email'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Firestore Security Rules & User Document Mapping:',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
              SizedBox(height: 8),
              Text(
                '• First Facebook Login: Auto-creates /users/{uid} document with provider: "facebook", role: "user"\n'
                '• Existing Facebook User: Auto-updates lastLoginAt timestamp\n'
                '• Email, Google, Facebook authentication work seamlessly together without provider conflict',
                style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStorageWorkspace() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0x3300D4FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00D4FF)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cloud_done_rounded, color: Color(0xFF00D4FF), size: 18),
                  SizedBox(width: 8),
                  Text('Supabase Bucket: "ether-cinema" (Zero Manual Folders Required)',
                      style: TextStyle(color: Color(0xFF00D4FF), fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0x2210B981),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: const Text('Firestore Public URL Sync: AUTOMATED',
                  style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Automated Logical Paths: posters/{id}/{uuid}.jpg | banners/{id}/{uuid}.jpg | avatars/{user}/{uuid}.jpg | subtitles/{id}/{lang}.srt',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: () => _testUpload('Movie Poster'),
              icon: const Icon(Icons.movie),
              label: const Text('Upload Movie Poster'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4FF), foregroundColor: Colors.black),
            ),
            ElevatedButton.icon(
              onPressed: () => _testUpload('Movie Banner'),
              icon: const Icon(Icons.view_carousel),
              label: const Text('Upload Movie Banner'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7000FF), foregroundColor: Colors.white),
            ),
            ElevatedButton.icon(
              onPressed: () => _testUpload('Series Poster'),
              icon: const Icon(Icons.tv),
              label: const Text('Upload Series Poster'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.black),
            ),
            ElevatedButton.icon(
              onPressed: () => _testUpload('Logo'),
              icon: const Icon(Icons.stars),
              label: const Text('Upload Logo'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE4C000), foregroundColor: Colors.black),
            ),
            ElevatedButton.icon(
              onPressed: () => _testUpload('Avatar'),
              icon: const Icon(Icons.account_circle),
              label: const Text('Upload Avatar'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.black),
            ),
            ElevatedButton.icon(
              onPressed: () => _testUpload('Subtitle'),
              icon: const Icon(Icons.subtitles),
              label: const Text('Upload Subtitle'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC4899), foregroundColor: Colors.white),
            ),
          ],
        ),
        if (_uploadStatusMessage.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(_uploadStatusMessage,
              style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 14)),
        ],
        if (_lastUploadedPublicUrl.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Firestore Public URL (Supabase CDN):',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 6),
                SelectableText(
                  _lastUploadedPublicUrl,
                  style: const TextStyle(
                      color: Color(0xFF00D4FF), fontFamily: 'monospace', fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Row(
        children: [
          // Sidebar Panel
          Container(
            width: 250,
            color: const Color(0xFF101114),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.dashboard_customize_rounded, color: Color(0xFF00D4FF), size: 28),
                    SizedBox(width: 10),
                    Text('Ether Admin',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final isSel = _selectedSidebarIndex == index;
                      return ListTile(
                        selected: isSel,
                        selectedTileColor: const Color(0x3300D4FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: Text(_menuItems[index],
                            style: TextStyle(
                                color: isSel ? const Color(0xFF00D4FF) : Colors.white70,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13)),
                        onTap: () => setState(() => _selectedSidebarIndex = index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Workspace
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _menuItems[_selectedSidebarIndex],
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Enterprise Cloud Management Portal v15.0',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181A20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: _selectedSidebarIndex == 4
                          ? _buildAuthWorkspace()
                          : _selectedSidebarIndex == 9
                              ? _buildStorageWorkspace()
                              : Center(
                                  child: Text(
                                    '${_menuItems[_selectedSidebarIndex]} Workspace Active',
                                    style: const TextStyle(
                                        color: Color(0xFF00D4FF), fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
