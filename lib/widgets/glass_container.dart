import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassContainer extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final Color fillColor;
  final Color borderColor;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.padding,
    this.margin,
    this.blur = 24.0,
    this.fillColor = AppColors.glassFill,
    this.borderColor = AppColors.glassBorder,
    this.onTap,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> {
  bool _isHoveredOrPressed = false;

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHoveredOrPressed
                ? Colors.white.withValues(alpha: 0.09)
                : widget.fillColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: _isHoveredOrPressed
                  ? AppColors.primaryContainer.withValues(alpha: 0.5)
                  : widget.borderColor,
              width: 1.0,
            ),
            gradient: const LinearGradient(
              colors: [
                Color(0x1FFFFFFF),
                Color(0x05FFFFFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: widget.child,
        ),
      ),
    );

    if (widget.margin != null) {
      content = Padding(padding: widget.margin!, child: content);
    }

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isHoveredOrPressed = true),
        onTapUp: (_) => setState(() => _isHoveredOrPressed = false),
        onTapCancel: () => setState(() => _isHoveredOrPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHoveredOrPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: content,
        ),
      );
    }

    return content;
  }
}
