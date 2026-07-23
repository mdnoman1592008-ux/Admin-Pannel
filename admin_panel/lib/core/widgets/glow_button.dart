import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Premium Glow Button — Ether Cinema Design System
/// Animated neon glow button with spring hover effects
class GlowButton extends StatefulWidget {
  const GlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.textColor,
    this.gradient,
    this.isLoading = false,
    this.isSmall = false,
    this.outlined = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final Gradient? gradient;
  final bool isLoading;
  final bool isSmall;
  final bool outlined;
  final bool fullWidth;

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _glowAnim = Tween<double>(begin: 0.3, end: 0.7).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _baseColor => widget.color ?? AppColors.primary;
  Color get _labelColor => widget.textColor ?? Colors.black;

  @override
  Widget build(BuildContext context) {
    final h = widget.isSmall ? 36.0 : 44.0;
    final hPad = widget.isSmall ? 14.0 : 20.0;
    final fontSize = widget.isSmall ? 12.0 : 14.0;

    return MouseRegion(
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              width: widget.fullWidth ? double.infinity : null,
              height: h,
              padding: EdgeInsets.symmetric(horizontal: hPad),
              decoration: BoxDecoration(
                gradient: widget.outlined ? null : (widget.gradient ?? LinearGradient(
                  colors: [_baseColor, _baseColor.withOpacity(0.8)],
                )),
                color: widget.outlined ? Colors.transparent : null,
                borderRadius: BorderRadius.circular(12),
                border: widget.outlined
                    ? Border.all(color: _baseColor.withOpacity(0.7), width: 1.5)
                    : null,
                boxShadow: widget.outlined
                    ? null
                    : [
                        BoxShadow(
                          color: _baseColor.withOpacity(_glowAnim.value),
                          blurRadius: 20,
                          spreadRadius: -4,
                        ),
                      ],
              ),
              child: widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _labelColor,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: widget.isSmall ? 14 : 16,
                            color: widget.outlined ? _baseColor : _labelColor,
                          ),
                          const SizedBox(width: 7),
                        ],
                        Text(
                          widget.label,
                          style: AppTextStyles.body().copyWith(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                            color: widget.outlined ? _baseColor : _labelColor,
                            letterSpacing: -0.2,
                          ),
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

/// Icon glow button (circle)
class GlowIconButton extends StatefulWidget {
  const GlowIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 40,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  @override
  State<GlowIconButton> createState() => _GlowIconButtonState();
}

class _GlowIconButtonState extends State<GlowIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _glow = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? AppColors.textSecond;
    Widget btn = MouseRegion(
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: AppColors.glass,
              borderRadius: BorderRadius.circular(widget.size / 2),
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: _glow.value > 0.1
                  ? [
                      BoxShadow(
                        color: c.withOpacity(_glow.value * 0.3),
                        blurRadius: 12,
                        spreadRadius: 0,
                      )
                    ]
                  : null,
            ),
            child: Icon(widget.icon, size: 18, color: c),
          ),
        ),
      ),
    );
    if (widget.tooltip != null) {
      btn = Tooltip(message: widget.tooltip!, child: btn);
    }
    return btn;
  }
}
