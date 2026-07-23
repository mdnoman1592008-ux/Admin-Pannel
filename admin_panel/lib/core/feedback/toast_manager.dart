import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ToastType { info, success, warning, error }

/// Global Toast & Notification Manager for Web Admin Panel
class ToastManager {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    Color accentColor;
    IconData icon;

    switch (type) {
      case ToastType.success:
        accentColor = AppColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case ToastType.warning:
        accentColor = AppColors.warning;
        icon = Icons.warning_rounded;
        break;
      case ToastType.error:
        accentColor = AppColors.danger;
        icon = Icons.error_rounded;
        break;
      case ToastType.info:
      default:
        accentColor = AppColors.primary;
        icon = Icons.info_rounded;
        break;
    }

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        title: title,
        message: message,
        accentColor: accentColor,
        icon: icon,
        onDismiss: () {
          entry.remove();
        },
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.title,
    required this.message,
    required this.accentColor,
    required this.icon,
    required this.onDismiss,
  });

  final String title;
  final String message;
  final Color accentColor;
  final IconData icon;
  final VoidCallback onDismiss;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0.2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 24,
      right: 24,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 360,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.accentColor.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withOpacity(0.25),
                    blurRadius: 24,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: widget.accentColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.title,
                            style: AppTextStyles.h4().copyWith(fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(widget.message,
                            style: AppTextStyles.bodySm().copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted, size: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
