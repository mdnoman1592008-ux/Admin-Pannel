import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_container.dart';

class VoiceSearchModal extends StatefulWidget {
  final Function(String) onResult;

  const VoiceSearchModal({super.key, required this.onResult});

  @override
  State<VoiceSearchModal> createState() => _VoiceSearchModalState();
}

class _VoiceSearchModalState extends State<VoiceSearchModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Simulate speech recognition result after 2.5s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        widget.onResult('Interstellar 4K');
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassContainer(
        borderRadius: 32,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryContainer.withOpacity(0.15),
                    border: Border.all(
                      color: AppColors.primaryContainer,
                      width: 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.glassGlowBlue,
                        blurRadius: 20 + (_pulseController.value * 20),
                        spreadRadius: 2 + (_pulseController.value * 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: AppColors.primaryContainer,
                    size: 48,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Listening...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Say movie title, genre, or actor name',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
