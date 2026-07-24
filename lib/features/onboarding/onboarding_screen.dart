import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../main/main_screen.dart';
import 'onboarding_widgets.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _navigateToLogin() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: LoginScreen(
            onLoginSuccess: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainScreen()),
                (route) => false,
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToGuestMain() {
    widget.onComplete?.call();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: const MainScreen(),
        ),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          // Page 0: Welcome Screen
          WelcomeScreen(
            onGetStarted: _nextPage,
          ),

          // Page 1: Feature Showcase 1 (IMAX 4K & Spatial Sound)
          _buildFeaturePage(
            posterUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=1200&auto=format&fit=crop',
            title: '4K Ultra HD & Spatial Sound',
            subtitle: 'Experience cinema-grade visual fidelity with ultra-low latency streaming and immersive audio.',
            pageIndex: 1,
          ),

          // Page 2: Feature Showcase 2 (Personalized Cinema)
          _buildFeaturePage(
            posterUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?q=80&w=1200&auto=format&fit=crop',
            title: 'Unlimited Blockbuster Access',
            subtitle: 'Watch your favorite movies, web series, and anime anywhere, anytime across all your devices.',
            pageIndex: 2,
            isLastPage: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePage({
    required String posterUrl,
    required String title,
    required String subtitle,
    required int pageIndex,
    bool isLastPage = false,
  }) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: KenBurnsPoster(
            imageUrl: posterUrl,
            heightRatio: 0.54,
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.38),
                const EtherLogoBadge(size: 60),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFBBC9CF),
                    height: 1.45,
                  ),
                ),
                const Spacer(),
                OnboardingPageIndicator(
                  totalPages: 3,
                  currentPage: pageIndex,
                ),
                const SizedBox(height: 32),
                GlassPrimaryButton(
                  label: isLastPage ? 'Login & Registration' : 'Continue',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _nextPage,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
