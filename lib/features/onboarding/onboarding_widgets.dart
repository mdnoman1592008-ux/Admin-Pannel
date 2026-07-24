import 'dart:ui';
import 'package:flutter/material.dart';

/// 1. Ken Burns Animated Movie Poster Container
class KenBurnsPoster extends StatefulWidget {
  final String imageUrl;
  final double heightRatio; // e.g. 0.52 for top 52% of screen

  const KenBurnsPoster({
    super.key,
    required this.imageUrl,
    this.heightRatio = 0.52,
  });

  @override
  State<KenBurnsPoster> createState() => _KenBurnsPosterState();
}

class _KenBurnsPosterState extends State<KenBurnsPoster>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final targetHeight = size.height * widget.heightRatio;

    return Container(
      width: double.infinity,
      height: targetHeight,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0D14),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ken Burns Scaling Image with Image.network fallback to stylized poster
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildFallbackPoster(),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildFallbackPoster();
                  },
                ),
              );
            },
          ),

          // Glass blur layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
            child: Container(color: Colors.transparent),
          ),

          // Dark Overlay (65%)
          Container(
            color: Colors.black.withOpacity(0.65),
          ),

          // Radial Soft Vignette Overlay
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.85,
                colors: [
                  Colors.transparent,
                  Color(0x99050608),
                  Color(0xFF050608),
                ],
              ),
            ),
          ),

          // Bottom Linear Gradient to seamlessly blend into #050608
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: targetHeight * 0.55,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x80050608),
                    Color(0xCC050608),
                    Color(0xFF050608),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackPoster() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF161E2E),
            Color(0xFF0D111A),
            Color(0xFF050608),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.movie_creation_rounded,
          size: 80,
          color: const Color(0xFF00CFFF).withOpacity(0.3),
        ),
      ),
    );
  }
}

/// 2. Ether Cinema Logo Badge with Glow Effect
class EtherLogoBadge extends StatelessWidget {
  final double size;

  const EtherLogoBadge({super.key, this.size = 56.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x1A00CFFF),
        border: Border.all(
          color: const Color(0xFF00CFFF).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00CFFF).withOpacity(0.4),
            blurRadius: 28,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFF7A5CFF).withOpacity(0.25),
            blurRadius: 40,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.movie_filter_rounded,
          size: size * 0.55,
          color: const Color(0xFF00CFFF),
        ),
      ),
    );
  }
}

/// 3. Modern Animated Page Indicator
class OnboardingPageIndicator extends StatelessWidget {
  final int totalPages;
  final int currentPage;

  const OnboardingPageIndicator({
    super.key,
    this.totalPages = 3,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: isActive ? 26.0 : 8.0,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF00CFFF)
                : const Color(0xFF3A4454).withOpacity(0.8),
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF00CFFF).withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }
}

/// 4. Primary Glass Button with Spring Press Animation
class GlassPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const GlassPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  State<GlassPrimaryButton> createState() => _GlassPrimaryButtonState();
}

class _GlassPrimaryButtonState extends State<GlassPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _springController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _springController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _springController.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _springController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00CFFF),
                    Color(0xFF0099FF),
                    Color(0xFF7A5CFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00CFFF).withOpacity(0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (widget.icon != null) ...[
                      const SizedBox(width: 8),
                      Icon(widget.icon, color: Colors.white, size: 20),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 5. Secondary Transparent Glass Button with Neon Border
class GlassSecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const GlassSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  State<GlassSecondaryButton> createState() => _GlassSecondaryButtonState();
}

class _GlassSecondaryButtonState extends State<GlassSecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _springController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _springController.forward(),
        onTapUp: (_) {
          _springController.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _springController.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: _isHovered
                      ? const Color(0xFF00CFFF).withOpacity(0.12)
                      : Colors.white.withOpacity(0.04),
                  border: Border.all(
                    color: _isHovered
                        ? const Color(0xFF00CFFF)
                        : const Color(0xFF00CFFF).withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    if (_isHovered)
                      BoxShadow(
                        color: const Color(0xFF00CFFF).withOpacity(0.25),
                        blurRadius: 16,
                      ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
