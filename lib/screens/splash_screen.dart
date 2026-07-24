import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinishSplash;

  const SplashScreen({super.key, required this.onFinishSplash});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;
  Timer? _initTimer;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();

    // Main 2.5s Splash Sequence
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Continuous Spinner for Glass Progress Ring
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // Scale 90% -> 100%
    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.00).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Fade In 0.0 -> 1.0
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Ambient Aurora Glow Pulses
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    _mainController.forward();

    // Background Service Initialization Simulation & Auto Transition with Disposable Timer
    _runInitializationSequence();
  }

  void _runInitializationSequence() {
    _initTimer = Timer(const Duration(milliseconds: 2400), () {
      if (mounted) {
        setState(() {
          _isFinished = true;
        });
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            widget.onFinishSplash();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    _mainController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _isFinished ? 0.0 : 1.0,
      child: Scaffold(
        backgroundColor: const Color(0xFF050608), // Luxury Deep Black
        body: Stack(
          alignment: Alignment.center,
          children: [
            // Ambient Luxury Background - Royal Purple (#7A5CFF) Top Left Glow
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Positioned(
                  top: -120,
                  left: -120,
                  child: Container(
                    width: 380,
                    height: 380,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF7A5CFF).withValues(alpha: 0.18 * _glowAnimation.value),
                    ),
                  ),
                );
              },
            ),

            // Ambient Luxury Background - Electric Blue (#00CFFF) Bottom Right Glow
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Positioned(
                  bottom: -120,
                  right: -120,
                  child: Container(
                    width: 380,
                    height: 380,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00CFFF).withValues(alpha: 0.18 * _glowAnimation.value),
                    ),
                  ),
                );
              },
            ),

            // Subtle Central Backdrop Blur
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.transparent),
            ),

            // Center Logo & Loading Progress Ring Sequence
            Center(
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Central Icon Container with Electric Blue (#00CFFF) Glow
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0x1A00CFFF),
                              border: Border.all(
                                color: const Color(0xFF00CFFF).withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00CFFF).withValues(alpha: 0.4 * _glowAnimation.value),
                                  blurRadius: 36,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: const Color(0xFF7A5CFF).withValues(alpha: 0.2 * _glowAnimation.value),
                                  blurRadius: 50,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.movie_filter_rounded,
                                size: 52,
                                color: Color(0xFF00CFFF),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Brand Title & Tagline
                          const Text(
                            'ETHER CINEMA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4.0,
                              color: Colors.white,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  color: Color(0x9900CFFF),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'NEXT-GENERATION OTT EXPERIENCE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFBBC9CF),
                              letterSpacing: 2.0,
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Thin Animated Glass Progress Ring Loader (No CircularProgressIndicator)
                          RotationTransition(
                            turns: _rotationController,
                            child: SizedBox(
                              width: 34,
                              height: 34,
                              child: CustomPaint(
                                painter: _ThinGlassProgressRingPainter(
                                  gradient: const SweepGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0x3300CFFF),
                                      Color(0xFF00CFFF),
                                      Color(0xFF7A5CFF),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Thin Glass Progress Ring Painter
class _ThinGlassProgressRingPainter extends CustomPainter {
  final SweepGradient gradient;

  _ThinGlassProgressRingPainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect.deflate(2),
      0,
      5.2, // ~300 degrees arc
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
