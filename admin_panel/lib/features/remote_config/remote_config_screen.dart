import 'package:flutter/material.dart';
import '../../core/backend/backend_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';

/// Live Remote Config Screen — Connected to Firestore collection 'remote_config'
class RemoteConfigScreen extends StatefulWidget {
  const RemoteConfigScreen({super.key});

  @override
  State<RemoteConfigScreen> createState() => _RemoteConfigScreenState();
}

class _RemoteConfigScreenState extends State<RemoteConfigScreen> {
  final _backend = LiveBackendService.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _backend,
      builder: (context, _) {
        final configs = _backend.remoteConfig;

        return Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildEditor(configs)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _buildJsonView(configs)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditor(List<LiveConfigKey> configs) {
    if (configs.isEmpty) {
      return GlassCard(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.textMuted, size: 48),
              const SizedBox(height: 16),
              Text('No data available in Firestore collection "remote_config"', style: AppTextStyles.h3()),
              const SizedBox(height: 8),
              Text('Click "Add Config Key" to publish live configuration overrides.', style: AppTextStyles.bodySm()),
              const SizedBox(height: 20),
              GlowButton(
                label: 'Add Config Key',
                icon: Icons.add_rounded,
                color: AppColors.accent,
                textColor: Colors.black,
                isSmall: true,
                onPressed: _showAddKeyDialog,
              ),
            ],
          ),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Remote Config Keys', style: AppTextStyles.h3()),
              const Spacer(),
              GlowButton(
                label: 'Add Key',
                icon: Icons.add_rounded,
                color: AppColors.accent,
                textColor: Colors.black,
                isSmall: true,
                onPressed: _showAddKeyDialog,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: configs.length,
              itemBuilder: (context, i) {
                final cfg = configs[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text(cfg.key, style: AppTextStyles.mono()),
                      const SizedBox(width: 12),
                      Text('(${cfg.type})', style: AppTextStyles.bodySm()),
                      const Spacer(),
                      Text(cfg.value, style: AppTextStyles.monoSm()),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonView(List<LiveConfigKey> configs) {
    final json = StringBuffer('{\n');
    for (final c in configs) {
      json.writeln('  "${c.key}": "${c.value}",');
    }
    json.write('}');

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live JSON Config Output', style: AppTextStyles.h3()),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                json.toString(),
                style: AppTextStyles.mono().copyWith(fontSize: 12, height: 1.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddKeyDialog() {
    final keyCtrl = TextEditingController();
    final valCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Text('Add Remote Config Key to Firestore', style: AppTextStyles.h3()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyCtrl,
              decoration: const InputDecoration(hintText: 'Key (e.g. feature_4k)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valCtrl,
              decoration: const InputDecoration(hintText: 'Value (e.g. true)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          GlowButton(
            label: 'Save Key',
            icon: Icons.check_rounded,
            color: AppColors.accent,
            textColor: Colors.black,
            isSmall: true,
            onPressed: () {
              if (keyCtrl.text.isNotEmpty) {
                _backend.setConfigKey(LiveConfigKey(
                  key: keyCtrl.text.trim(),
                  value: valCtrl.text.trim(),
                  type: 'string',
                  description: 'Live Remote Config key',
                ));
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
