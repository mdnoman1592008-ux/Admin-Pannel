import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Premium Glassmorphism Card — Ether Cinema Design System
/// Floating glass surface with backdrop blur, neon border, soft glow
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.blur = 24.0,
    this.borderRadius = 24.0,
    this.borderColor,
    this.glowColor,
    this.glowBlur = 0,
    this.backgroundColor,
    this.onTap,
    this.hoverable = false,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double blur;
  final double borderRadius;
  final Color? borderColor;
  final Color? glowColor;
  final double glowBlur;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool hoverable;
  final Gradient? gradient;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: widget.hoverable ? (_) {
        setState(() => _hovered = true);
        _controller.forward();
      } : null,
      onExit: widget.hoverable ? (_) {
        setState(() => _hovered = false);
        _controller.reverse();
      } : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: widget.hoverable ? _scaleAnim.value : 1.0,
          child: child,
        ),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                AppColors.softShadow(),
                if (widget.glowColor != null && widget.glowBlur > 0)
                  BoxShadow(
                    color: widget.glowColor!.withOpacity(
                      widget.hoverable ? 0.25 + (_glowAnim.value * 0.15) : 0.25,
                    ),
                    blurRadius: widget.glowBlur,
                    spreadRadius: 0,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blur,
                  sigmaY: widget.blur,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: widget.padding ?? const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    gradient: widget.gradient,
                    color: widget.gradient == null
                        ? (widget.backgroundColor ??
                            (_hovered
                                ? AppColors.glassHover
                                : AppColors.glass))
                        : null,
                    border: Border.all(
                      color: widget.borderColor ??
                          (_hovered
                              ? AppColors.glassBorder.withOpacity(0.3)
                              : AppColors.glassBorder),
                      width: 1.0,
                    ),
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin glass divider
class GlassDivider extends StatelessWidget {
  const GlassDivider({super.key, this.horizontal = true});
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: horizontal ? double.infinity : 1,
      height: horizontal ? 1 : double.infinity,
      color: AppColors.glassBorder,
    );
  }
}
