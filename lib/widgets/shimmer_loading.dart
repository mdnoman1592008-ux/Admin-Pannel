import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_container.dart';

class GlassShimmerCard extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const GlassShimmerCard({
    super.key,
    this.width = 160,
    this.height = 240,
    this.borderRadius = 20,
  });

  @override
  State<GlassShimmerCard> createState() => _GlassShimmerCardState();
}

class _GlassShimmerCardState extends State<GlassShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GlassContainer(
          borderRadius: widget.borderRadius,
          padding: EdgeInsets.zero,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.05),
                ],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment(-1.0 + (_controller.value * 2.0), -0.3),
                end: Alignment(1.0 + (_controller.value * 2.0), 0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: widget.width * 0.7,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: widget.width * 0.4,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
