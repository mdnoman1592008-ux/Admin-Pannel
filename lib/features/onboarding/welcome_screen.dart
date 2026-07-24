import 'dart:ui';
import 'package:flutter/material.dart';
import 'onboarding_widgets.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onGetStarted;
  final VoidCallback? onContinueGuest;

  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
    this.onContinueGuest,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // High quality movie poster image URL
  static const String _posterUrl =
      'https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=1200&auto=format&fit=crop';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050608), // Luxury Deep Black
      body: Stack(
        children: [
          // 1. Ken Burns Top Movie Poster visual
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: KenBurnsPoster(
              imageUrl: _posterUrl,
              heightRatio: 0.52,
            ),
          ),

          // 2. Ambient Aurora Glow Accents (Royal Purple & Electric Blue)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.40,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7A5CFF).withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00CFFF).withOpacity(0.12),
              ),
            ),
          ),

          // 3. Foreground Content with Animated Entrance
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    children: [
                      // Top Spacing matching Poster center offset
                      SizedBox(height: MediaQuery.of(context).size.height * 0.36),

                      // Ether Cinema Logo Badge
                      const EtherLogoBadge(size: 64),
                      const SizedBox(height: 20),

                      // Welcome Text Header
                      const Text(
                        'Welcome to Ether Cinema',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          height: 1.15,
                          shadows: [
                            Shadow(
                              color: Color(0x9900CFFF),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      const Text(
                        'Discover blockbuster movies, exclusive series, anime, documentaries and live entertainment in one premium experience.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFBBC9CF),
                          height: 1.45,
                        ),
                      ),

                      const Spacer(),

                      // Animated Page Indicators (Active Pill + Inactive Dots)
                      const OnboardingPageIndicator(
                        totalPages: 3,
                        currentPage: 0,
                      ),
                      const SizedBox(height: 32),

                      // Primary Glass Button ("Get Started")
                      GlassPrimaryButton(
                        label: 'Get Started',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: widget.onGetStarted,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
