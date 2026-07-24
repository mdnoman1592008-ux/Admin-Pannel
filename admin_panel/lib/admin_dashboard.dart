import 'package:flutter/material.dart';
import 'core/admin_storage_service.dart';
import 'features/home_sections/home_sections_screen.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _selectedSidebarIndex = 0;
  final AdminStorageService _adminStorage = AdminStorageService();
  bool _hasUnsavedPlaylistChanges = false;
  String _selectedPlaylistName = 'Featured Movies';

  final List<String> _menuItems = [
    'Dynamic Home Sections',
    'Dashboard',
    'Playlist Reordering System',
    'Multi-Source Streaming Engine',
    'Netflix Series & Seasons',
    'Scheduled Publishing',
    'Notify Me Management',
    'Hero Banners Slider',
    'Dynamic Categories',
    'Users & Auth (Facebook/Google/Email)',
    'FCM Notifications',
    'Analytics',
    'Audit Logs',
    'Remote Config',
    'Storage (Automated Supabase)'
  ];

  // Playlist Reordering State
  List<Map<String, dynamic>> _playlistItems = [];

  List<Map<String, dynamic>> _initialPlaylistOrder = [];

  // Multi-Source Streaming Engine State
  final List<Map<String, dynamic>> _streamingSources = [
    {
      'id': 'src1',
      'provider': 'Dailymotion 4K',
      'urlOrId': 'x8m00bc',
      'priority': 1,
      'status': 'Active',
      'isValidated': true,
    },
    {
      'id': 'src2',
      'provider': 'YouTube Premium HD',
      'urlOrId': 'dQw4w9WgXcQ',
      'priority': 2,
      'status': 'Active',
      'isValidated': true,
    },
    {
      'id': 'src3',
      'provider': 'HLS Stream (.m3u8)',
      'urlOrId': 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
      'priority': 3,
      'status': 'Active',
      'isValidated': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initialPlaylistOrder = List<Map<String, dynamic>>.from(_playlistItems);
  }

  void _reorderItem(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _playlistItems.removeAt(oldIndex);
      _playlistItems.insert(newIndex, item);
      for (int i = 0; i < _playlistItems.length; i++) {
        _playlistItems[i]['position'] = i + 1;
      }
      _hasUnsavedPlaylistChanges = true;
    });
  }

  void _applySorting(String sortType) {
    setState(() {
      if (sortType == 'title_asc') {
        _playlistItems.sort((a, b) => (a['title'] as String).compareTo(b['title'] as String));
      } else if (sortType == 'title_desc') {
        _playlistItems.sort((a, b) => (b['title'] as String).compareTo(a['title'] as String));
      } else if (sortType == 'year_desc') {
        _playlistItems.sort((a, b) => (b['releaseYear'] as String).compareTo(a['releaseYear'] as String));
      }
      for (int i = 0; i < _playlistItems.length; i++) {
        _playlistItems[i]['position'] = i + 1;
      }
      _hasUnsavedPlaylistChanges = true;
    });
  }

  Future<void> _savePlaylistOrder() async {
    final orderedIds = _playlistItems.map((item) => item['id'] as String).toList();
    final success = await _adminStorage.savePlaylistOrder(_selectedPlaylistName, orderedIds);
    if (success) {
      setState(() {
        _hasUnsavedPlaylistChanges = false;
        _initialPlaylistOrder = List<Map<String, dynamic>>.from(_playlistItems);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Playlist order synced successfully to Firestore in realtime!'),
            backgroundColor: Color(0xFF00D4FF),
          ),
        );
      }
    }
  }

  Widget _buildPlaylistReorderingWorkspace() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Playlist: $_selectedPlaylistName',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    if (_hasUnsavedPlaylistChanges) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: const Text('UNSAVED CHANGES',
                            style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Drag and drop items to reorder playlist sequence for connected mobile devices.',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
            Row(
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort_rounded, color: Colors.white70),
                  tooltip: 'Sort Presets',
                  color: const Color(0xFF1E2538),
                  onSelected: _applySorting,
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'title_asc', child: Text('Title (A-Z)', style: TextStyle(color: Colors.white))),
                    const PopupMenuItem(value: 'title_desc', child: Text('Title (Z-A)', style: TextStyle(color: Colors.white))),
                    const PopupMenuItem(value: 'year_desc', child: Text('Release Year (Newest)', style: TextStyle(color: Colors.white))),
                  ],
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _hasUnsavedPlaylistChanges ? _savePlaylistOrder : null,
                  icon: const Icon(Icons.save_rounded, color: Colors.black),
                  label: const Text('Save Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4FF),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white24,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: _playlistItems.length,
            onReorder: _reorderItem,
            itemBuilder: (context, index) {
              final item = _playlistItems[index];
              return Container(
                key: ValueKey(item['id']),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.drag_indicator_rounded, color: Colors.white54),
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0x2200D4FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('#${item['position']}',
                          style: const TextStyle(color: Color(0xFF00D4FF), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title'] as String,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(item['synopsis'] as String,
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(item['badge'] as String,
                          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.vertical_align_top_rounded, color: Colors.white70, size: 20),
                      onPressed: () => _reorderItem(index, 0),
                      tooltip: 'Move to Top',
                    ),
                    IconButton(
                      icon: const Icon(Icons.vertical_align_bottom_rounded, color: Colors.white70, size: 20),
                      onPressed: () => _reorderItem(index, _playlistItems.length),
                      tooltip: 'Move to Bottom',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSourceWorkspace() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enterprise Multi-Source Streaming Engine',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Configure Dailymotion, YouTube, HLS (.m3u8), MP4, DASH with Drag-and-Drop Priority Fallback',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  final priority = _streamingSources.length + 1;
                  _streamingSources.add({
                    'id': 'src$priority',
                    'provider': 'MPEG-DASH (.mpd)',
                    'urlOrId': 'https://dash.akamaized.net/envivio/EnvivioDash3/manifest.mpd',
                    'priority': priority,
                    'status': 'Active',
                    'isValidated': true,
                  });
                });
              },
              icon: const Icon(Icons.add_link_rounded, color: Colors.black),
              label: const Text('Add Streaming Source'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4FF), foregroundColor: Colors.black),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: _streamingSources.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = _streamingSources.removeAt(oldIndex);
                _streamingSources.insert(newIndex, item);
                for (int i = 0; i < _streamingSources.length; i++) {
                  _streamingSources[i]['priority'] = i + 1;
                }
              });
            },
            itemBuilder: (context, index) {
              final src = _streamingSources[index];
              return Container(
                key: ValueKey(src['id']),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.drag_indicator_rounded, color: Colors.white54),
                    const SizedBox(width: 14),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0x2200D4FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Priority ${src['priority']}',
                          style: const TextStyle(color: Color(0xFF00D4FF), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(src['provider'] as String,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          SelectableText(src['urlOrId'] as String,
                              style: const TextStyle(color: Colors.white54, fontFamily: 'monospace', fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          _streamingSources.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
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
            child: _selectedSidebarIndex == 0
                ? const HomeSectionsScreen()
                : Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _menuItems[_selectedSidebarIndex],
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('Enterprise Cloud Management Portal v18.0',
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
                            child: _selectedSidebarIndex == 2
                                ? _buildPlaylistReorderingWorkspace()
                                : _selectedSidebarIndex == 3
                                    ? _buildMultiSourceWorkspace()
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
