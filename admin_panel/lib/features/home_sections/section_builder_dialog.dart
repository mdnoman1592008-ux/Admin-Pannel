import 'package:flutter/material.dart';
import '../../core/models/home_section_model.dart';

class SectionBuilderDialog extends StatefulWidget {
  final HomeSectionModel? existingSection;
  final Function(HomeSectionModel) onSave;

  const SectionBuilderDialog({
    super.key,
    this.existingSection,
    required this.onSave,
  });

  @override
  State<SectionBuilderDialog> createState() => _SectionBuilderDialogState();
}

class _SectionBuilderDialogState extends State<SectionBuilderDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _slugController;
  late TextEditingController _descController;
  late TextEditingController _bannerUrlController;
  late TextEditingController _filterController;
  late TextEditingController _maxItemsController;

  late SectionLayoutType _selectedLayout;
  late SectionContentSource _selectedSource;
  late SectionVisibilityRule _selectedVisibility;
  String _selectedIcon = 'star_rounded';

  bool _isEnabled = true;
  bool _enableGlass = false;
  bool _autoScroll = false;

  DateTime? _publishAt;
  DateTime? _expireAt;

  final List<Map<String, dynamic>> _templates = [
    {
      'title': 'Hero Banner',
      'layout': SectionLayoutType.heroBanner,
      'source': SectionContentSource.trending,
      'icon': 'star_rounded',
      'maxItems': 5,
    },
    {
      'title': 'Trending Now',
      'layout': SectionLayoutType.horizontalCarousel,
      'source': SectionContentSource.trending,
      'icon': 'local_fire_department_rounded',
      'maxItems': 12,
    },
    {
      'title': 'Top 10 Today',
      'layout': SectionLayoutType.top10,
      'source': SectionContentSource.highestRated,
      'icon': 'leaderboard_rounded',
      'maxItems': 10,
    },
    {
      'title': 'Coming Soon',
      'layout': SectionLayoutType.comingSoon,
      'source': SectionContentSource.comingSoon,
      'icon': 'schedule_rounded',
      'maxItems': 8,
    },
    {
      'title': 'Continue Watching',
      'layout': SectionLayoutType.continueWatching,
      'source': SectionContentSource.continueWatching,
      'icon': 'play_circle_fill',
      'maxItems': 10,
    },
    {
      'title': 'Custom Collection',
      'layout': SectionLayoutType.grid,
      'source': SectionContentSource.manual,
      'icon': 'category_rounded',
      'maxItems': 12,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    final sec = widget.existingSection;
    _titleController = TextEditingController(text: sec?.title ?? '');
    _slugController = TextEditingController(text: sec?.slug ?? '');
    _descController = TextEditingController(text: sec?.description ?? '');
    _bannerUrlController = TextEditingController(text: sec?.bannerUrl ?? '');
    _filterController = TextEditingController(
      text: sec?.filters['category'] ?? sec?.filters['genre'] ?? sec?.filters['tag'] ?? '',
    );
    _maxItemsController = TextEditingController(text: (sec?.maxItems ?? 10).toString());

    _selectedLayout = sec?.layoutType ?? SectionLayoutType.horizontalCarousel;
    _selectedSource = sec?.contentSource ?? SectionContentSource.trending;
    _selectedVisibility = sec?.visibility ?? SectionVisibilityRule.visible;
    _selectedIcon = sec?.iconName ?? 'star_rounded';

    _isEnabled = sec?.isEnabled ?? true;
    _enableGlass = sec?.style.enableGlass ?? false;
    _autoScroll = sec?.style.autoScroll ?? false;
    _publishAt = sec?.scheduling.publishAt;
    _expireAt = sec?.scheduling.expireAt;

    _titleController.addListener(_autoGenerateSlug);
  }

  void _autoGenerateSlug() {
    if (widget.existingSection != null) return;
    final text = _titleController.text.trim().toLowerCase();
    final slug = text.replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_|_$'), '');
    _slugController.text = slug;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _slugController.dispose();
    _descController.dispose();
    _bannerUrlController.dispose();
    _filterController.dispose();
    _maxItemsController.dispose();
    super.dispose();
  }

  void _applyTemplate(Map<String, dynamic> tmpl) {
    setState(() {
      _titleController.text = tmpl['title'];
      _selectedLayout = tmpl['layout'];
      _selectedSource = tmpl['source'];
      _selectedIcon = tmpl['icon'];
      _maxItemsController.text = tmpl['maxItems'].toString();
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final filtersMap = <String, dynamic>{};
    final filterVal = _filterController.text.trim();
    if (filterVal.isNotEmpty) {
      if (_selectedSource == SectionContentSource.category) filtersMap['category'] = filterVal;
      if (_selectedSource == SectionContentSource.genre) filtersMap['genre'] = filterVal;
      if (_selectedSource == SectionContentSource.tag) filtersMap['tag'] = filterVal;
    }

    final maxItems = int.tryParse(_maxItemsController.text.trim()) ?? 10;

    final updated = HomeSectionModel(
      id: widget.existingSection?.id ?? '',
      title: _titleController.text.trim(),
      slug: _slugController.text.trim().isEmpty ? 'section_${DateTime.now().millisecondsSinceEpoch}' : _slugController.text.trim(),
      description: _descController.text.trim(),
      layoutType: _selectedLayout,
      contentSource: _selectedSource,
      filters: filtersMap,
      manualItemIds: widget.existingSection?.manualItemIds ?? const [],
      bannerUrl: _bannerUrlController.text.trim(),
      iconName: _selectedIcon,
      displayOrder: widget.existingSection?.displayOrder ?? 0,
      maxItems: maxItems,
      isEnabled: _isEnabled,
      visibility: _selectedVisibility,
      style: SectionStyleConfig(
        enableGlass: _enableGlass,
        autoScroll: _autoScroll,
      ),
      scheduling: SectionScheduleConfig(
        publishAt: _publishAt,
        expireAt: _expireAt,
      ),
      createdAt: widget.existingSection?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingSection != null;

    return Dialog(
      backgroundColor: const Color(0xFF131722),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 850,
        height: 650,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isEdit ? Icons.edit_note_rounded : Icons.add_to_photos_rounded,
                    color: const Color(0xFF6C5CE7),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? 'Edit Homepage Section' : 'Dynamic Section Builder',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEdit ? 'Update layout, data source & scheduling' : 'Build a custom homepage section for connected mobile apps',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white60),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Templates bar (if new)
            if (!isEdit) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _templates.map((t) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        backgroundColor: const Color(0xFF1E2538),
                        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                        avatar: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF6C5CE7), size: 14),
                        label: Text(t['title']),
                        onPressed: () => _applyTemplate(t),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Tabs
            TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF6C5CE7),
              labelColor: const Color(0xFF6C5CE7),
              unselectedLabelColor: Colors.white54,
              tabs: const [
                Tab(text: 'General'),
                Tab(text: 'Layout & Style'),
                Tab(text: 'Data Source'),
                Tab(text: 'Visibility'),
                Tab(text: 'Scheduling'),
              ],
            ),
            const SizedBox(height: 16),

            // Tab Content
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralTab(),
                    _buildLayoutTab(),
                    _buildDataSourceTab(),
                    _buildVisibilityTab(),
                    _buildSchedulingTab(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Footer Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const TextStyle(color: Colors.white60) == null
                      ? const SizedBox()
                      : const Text('Cancel', style: TextStyle(color: Colors.white60)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  label: Text(isEdit ? 'Save Changes' : 'Create Section', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Section Name *', 'e.g. Oscar Winners 2026'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a section name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _slugController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Internal Slug *', 'e.g. oscar_winners_2026'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Slug is required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Subtitle / Description', 'Short subtitle shown to app users'),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _bannerUrlController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Cover Banner URL', 'https://example.com/banner.jpg'),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Layout Type:', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<SectionLayoutType>(
            value: _selectedLayout,
            dropdownColor: const Color(0xFF1E2538),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Layout Format', ''),
            items: SectionLayoutType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.name),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedLayout = val);
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Enable Glassmorphism Overlay', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Apply translucent frosted glass backdrop in app', style: TextStyle(color: Colors.white54, fontSize: 12)),
            value: _enableGlass,
            activeColor: const Color(0xFF6C5CE7),
            onChanged: (v) => setState(() => _enableGlass = v),
          ),
          SwitchListTile(
            title: const Text('Auto Scroll Items', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Automatically slide items every 4 seconds', style: TextStyle(color: Colors.white54, fontSize: 12)),
            value: _autoScroll,
            activeColor: const Color(0xFF6C5CE7),
            onChanged: (v) => setState(() => _autoScroll = v),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSourceTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Data Source:', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<SectionContentSource>(
            value: _selectedSource,
            dropdownColor: const Color(0xFF1E2538),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Content Source Provider', ''),
            items: SectionContentSource.values.map((src) {
              return DropdownMenuItem(
                value: src,
                child: Text(src.name),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedSource = val);
            },
          ),
          const SizedBox(height: 14),
          if (_selectedSource == SectionContentSource.category ||
              _selectedSource == SectionContentSource.genre ||
              _selectedSource == SectionContentSource.tag) ...[
            TextFormField(
              controller: _filterController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                '${_selectedSource.name} Filter Value',
                'e.g. Sci-Fi, Natok, Action',
              ),
            ),
            const SizedBox(height: 14),
          ],
          TextFormField(
            controller: _maxItemsController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: _inputDecoration('Max Items to Display', '10'),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Enable Section', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Show this section on connected mobile applications', style: TextStyle(color: Colors.white54, fontSize: 12)),
            value: _isEnabled,
            activeColor: const Color(0xFF6C5CE7),
            onChanged: (v) => setState(() => _isEnabled = v),
          ),
          const SizedBox(height: 12),
          const Text('Target Audience Rule:', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<SectionVisibilityRule>(
            value: _selectedVisibility,
            dropdownColor: const Color(0xFF1E2538),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Audience Access', ''),
            items: SectionVisibilityRule.values.map((v) {
              return DropdownMenuItem(
                value: v,
                child: Text(v.name),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedVisibility = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulingTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Automated Release & Expiration:', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 14),
          ListTile(
            tileColor: const Color(0xFF1E2538),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            leading: const Icon(Icons.calendar_today_rounded, color: Color(0xFF6C5CE7)),
            title: Text(
              _publishAt == null ? 'Publish Date: Immediately' : 'Publish Date: ${_publishAt.toString().substring(0, 16)}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            trailing: IconButton(
              icon: Icon(_publishAt == null ? Icons.add_rounded : Icons.clear_rounded, color: Colors.white70),
              onPressed: () async {
                if (_publishAt != null) {
                  setState(() => _publishAt = null);
                } else {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (d != null) setState(() => _publishAt = d);
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            tileColor: const Color(0xFF1E2538),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            leading: const Icon(Icons.event_busy_rounded, color: Colors.amber),
            title: Text(
              _expireAt == null ? 'Expiration: Never' : 'Expiration: ${_expireAt.toString().substring(0, 16)}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            trailing: IconButton(
              icon: Icon(_expireAt == null ? Icons.add_rounded : Icons.clear_rounded, color: Colors.white70),
              onPressed: () async {
                if (_expireAt != null) {
                  setState(() => _expireAt = null);
                } else {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (d != null) setState(() => _expireAt = d);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white30),
      filled: true,
      fillColor: const Color(0xFF1E2538),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
