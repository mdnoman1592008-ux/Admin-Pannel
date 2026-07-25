import 'package:flutter/material.dart';
import '../../core/models/home_section_model.dart';
import '../../core/cms/home_section_repository.dart';
import 'section_builder_dialog.dart';

class HomeSectionsScreen extends StatefulWidget {
  const HomeSectionsScreen({super.key});

  @override
  State<HomeSectionsScreen> createState() => _HomeSectionsScreenState();
}

class _HomeSectionsScreenState extends State<HomeSectionsScreen> {
  final HomeSectionRepository _repository = HomeSectionRepository();
  String _searchQuery = '';
  String _selectedStatusFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F121C),
      body: StreamBuilder<List<HomeSectionModel>>(
        stream: _repository.sectionsStream,
        initialData: _repository.sections,
        builder: (context, snapshot) {
          final allSections = _repository.sections;
          final filteredSections = allSections.where((sec) {
            final matchesSearch = sec.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                sec.slug.toLowerCase().contains(_searchQuery.toLowerCase());
            if (!matchesSearch) return false;
            if (_selectedStatusFilter == 'ENABLED') return sec.isEnabled;
            if (_selectedStatusFilter == 'DISABLED') return !sec.isEnabled;
            return true;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Action Bar
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.dashboard_customize_rounded, color: Color(0xFF6C5CE7), size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dynamic Home Sections Management',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Realtime Control over Mobile App Homepage Sections & Content Layouts',
                          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _openSectionBuilder(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      label: const Text('Create New Section', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Controls & Search Filter Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search sections by title or slug...',
                          hintStyle: const TextStyle(color: Colors.white30),
                          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white60),
                          filled: true,
                          fillColor: const Color(0xFF1E2538),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedStatusFilter,
                      dropdownColor: const Color(0xFF1E2538),
                      style: const TextStyle(color: Colors.white),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('All Sections')),
                        DropdownMenuItem(value: 'ENABLED', child: Text('Enabled Only')),
                        DropdownMenuItem(value: 'DISABLED', child: Text('Disabled Only')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatusFilter = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Reorderable Section Cards List
                Expanded(
                  child: filteredSections.isEmpty
                      ? _buildEmptyState()
                      : ReorderableListView.builder(
                          itemCount: filteredSections.length,
                          onReorder: (oldIdx, newIdx) {
                            if (oldIdx < newIdx) newIdx -= 1;
                            final currentList = List<HomeSectionModel>.from(allSections);
                            final movedItem = currentList.removeAt(oldIdx);
                            currentList.insert(newIdx, movedItem);
                            _repository.reorderSections(currentList.map((s) => s.id).toList());
                          },
                          itemBuilder: (context, index) {
                            final sec = filteredSections[index];
                            return Container(
                              key: ValueKey(sec.id),
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF191F30),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: sec.isEnabled ? const Color(0xFF6C5CE7).withOpacity(0.3) : Colors.white10,
                                ),
                              ),
                              child: Row(
                                children: [
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: const Icon(Icons.drag_indicator_rounded, color: Colors.white38),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF262E45),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '#${sec.displayOrder}',
                                      style: const TextStyle(color: Color(0xFF6C5CE7), fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              sec.title,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            const SizedBox(width: 10),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF262E45),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                sec.layoutType.name,
                                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                sec.contentSource.name,
                                                style: const TextStyle(color: Colors.blueAccent, fontSize: 11),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Slug: ${sec.slug} • Max: ${sec.maxItems} items ${sec.description.isNotEmpty ? "• ${sec.description}" : ""}',
                                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Switch Toggle
                                  Switch(
                                    value: sec.isEnabled,
                                    activeThumbColor: const Color(0xFF6C5CE7),
                                    activeTrackColor:
                                        const Color(0xFF6C5CE7).withOpacity(0.3),
                                    onChanged: (val) {
                                      _repository.toggleSectionEnabled(sec.id, val);
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  // Action Popup Menu
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white60),
                                    dropdownColor: const Color(0xFF1E2538),
                                    onSelected: (action) {
                                      if (action == 'edit') {
                                        _openSectionBuilder(context, existing: sec);
                                      } else if (action == 'duplicate') {
                                        _repository.duplicateSection(sec.id);
                                      } else if (action == 'delete') {
                                        _confirmDelete(sec);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_rounded, color: Colors.white70, size: 16),
                                            SizedBox(width: 8),
                                            Text('Edit Section', style: TextStyle(color: Colors.white)),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'duplicate',
                                        child: Row(
                                          children: [
                                            Icon(Icons.content_copy_rounded, color: Colors.white70, size: 16),
                                            SizedBox(width: 8),
                                            Text('Duplicate', style: TextStyle(color: Colors.white)),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_rounded, color: Colors.redAccent, size: 16),
                                            SizedBox(width: 8),
                                            Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard_customize_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No Home Sections Found', style: TextStyle(color: Colors.white70, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Click "Create New Section" above to build custom sections', style: TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }

  void _openSectionBuilder(BuildContext context, {HomeSectionModel? existing}) {
    showDialog(
      context: context,
      builder: (context) => SectionBuilderDialog(
        existingSection: existing,
        onSave: (sec) {
          if (existing != null) {
            _repository.updateSection(sec);
          } else {
            _repository.createSection(sec);
          }
        },
      ),
    );
  }

  void _confirmDelete(HomeSectionModel sec) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF191F30),
        title: const Text('Delete Homepage Section?', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "${sec.title}"? This change will be broadcast in realtime to all app users.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              _repository.deleteSection(sec.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
