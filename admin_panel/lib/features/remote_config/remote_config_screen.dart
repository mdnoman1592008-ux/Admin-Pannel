import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';

/// Remote Config Screen — Live key-value editor with JSON viewer
class RemoteConfigScreen extends StatefulWidget {
  const RemoteConfigScreen({super.key});

  @override
  State<RemoteConfigScreen> createState() => _RemoteConfigScreenState();
}

class _RemoteConfigScreenState extends State<RemoteConfigScreen> {
  final _configs = <_Config>[
    _Config('feature_4k', 'true', 'bool', 'Enable 4K streaming for all users'),
    _Config('feature_downloads', 'true', 'bool', 'Allow offline downloads'),
    _Config('max_concurrent_streams', '3', 'int', 'Max streams per account'),
    _Config('maintenance_mode', 'false', 'bool', 'Enable maintenance overlay'),
    _Config('banner_auto_rotate', '5000', 'int', 'Banner rotation interval (ms)'),
    _Config('featured_movie_id', 'm_dune2_2024', 'string', 'ID of the featured movie'),
    _Config('fcm_enabled', 'true', 'bool', 'Enable FCM push notifications'),
    _Config('analytics_sample_rate', '0.1', 'double', 'Analytics sampling rate (0-1)'),
    _Config('welcome_message', 'Welcome to Ether Cinema!', 'string', 'Home screen greeting'),
    _Config('min_app_version', '2.5.0', 'string', 'Minimum required app version'),
  ];

  int? _editingIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildEditor()),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _buildJsonView()),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppColors.accent.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.tune_rounded,
                      color: AppColors.accent, size: 18),
                ),
                const SizedBox(width: 12),
                Text('Remote Configuration', style: AppTextStyles.h3()),
                const Spacer(),
                GlowButton(
                  label: 'Add Key',
                  icon: Icons.add_rounded,
                  color: AppColors.accent,
                  textColor: Colors.black,
                  isSmall: true,
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                GlowButton(
                  label: 'Publish All',
                  icon: Icons.publish_rounded,
                  color: AppColors.success,
                  textColor: Colors.black,
                  isSmall: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.glassBorder),
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('KEY', style: AppTextStyles.tableHeader())),
                Expanded(flex: 1, child: Text('TYPE', style: AppTextStyles.tableHeader())),
                Expanded(flex: 3, child: Text('VALUE', style: AppTextStyles.tableHeader())),
                SizedBox(width: 80, child: Text('ACTIONS', style: AppTextStyles.tableHeader())),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.glassBorder),
          Expanded(
            child: ListView.separated(
              itemCount: _configs.length,
              separatorBuilder: (_, __) =>
                  Container(height: 1, color: AppColors.glassBorder.withOpacity(0.5)),
              itemBuilder: (_, i) => _buildConfigRow(_configs[i], i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigRow(_Config config, int index) {
    final isEditing = _editingIndex == index;
    final typeColor = _typeColor(config.type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      color: isEditing ? AppColors.accent.withOpacity(0.04) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(config.key, style: AppTextStyles.mono()),
                const SizedBox(height: 2),
                Text(config.description, style: AppTextStyles.bodySm().copyWith(fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: typeColor.withOpacity(0.3)),
              ),
              child: Text(config.type,
                  style: AppTextStyles.badge().copyWith(
                      color: typeColor, fontSize: 10)),
            ),
          ),
          Expanded(
            flex: 3,
            child: isEditing
                ? TextFormField(
                    initialValue: config.value,
                    style: AppTextStyles.mono().copyWith(fontSize: 12),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: AppColors.accent, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.glassBorder),
                      ),
                    ),
                    onChanged: (v) =>
                        setState(() => _configs[index] = _Config(config.key, v, config.type, config.description)),
                  )
                : GestureDetector(
                    onTap: () => setState(() => _editingIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Text(
                        config.value,
                        style: AppTextStyles.mono().copyWith(
                          fontSize: 12,
                          color: config.type == 'bool'
                              ? (config.value == 'true'
                                  ? AppColors.success
                                  : AppColors.danger)
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() =>
                      _editingIndex = isEditing ? null : index),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: (isEditing ? AppColors.success : AppColors.primary)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      isEditing ? Icons.check_rounded : Icons.edit_rounded,
                      size: 14,
                      color:
                          isEditing ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => setState(() => _configs.removeAt(index)),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(Icons.delete_rounded,
                        size: 14, color: AppColors.danger),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonView() {
    final json = StringBuffer('{\n');
    for (final c in _configs) {
      final val = c.type == 'bool' || c.type == 'int' || c.type == 'double'
          ? c.value
          : '"${c.value}"';
      json.writeln('  "${c.key}": $val,');
    }
    json.write('}');

    return GlassCard(
      borderColor: AppColors.accent.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('JSON Preview', style: AppTextStyles.h3()),
              const Spacer(),
              GlowButton(
                label: 'Copy',
                icon: Icons.copy_rounded,
                color: AppColors.accent,
                textColor: Colors.black,
                isSmall: true,
                outlined: true,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                json.toString(),
                style: AppTextStyles.mono().copyWith(
                  fontSize: 12,
                  height: 1.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'bool': return AppColors.success;
      case 'int': return AppColors.secondary;
      case 'double': return AppColors.warning;
      default: return AppColors.primary;
    }
  }
}

class _Config {
  const _Config(this.key, this.value, this.type, this.description);
  final String key, value, type, description;
}
