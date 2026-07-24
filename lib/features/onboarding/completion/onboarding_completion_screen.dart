import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/services/movie_repository.dart';
import '../../main/main_screen.dart';
import '../onboarding_widgets.dart';

class OnboardingCompletionScreen extends StatefulWidget {
  const OnboardingCompletionScreen({super.key});

  @override
  State<OnboardingCompletionScreen> createState() =>
      _OnboardingCompletionScreenState();
}

class _OnboardingCompletionScreenState extends State<OnboardingCompletionScreen>
    with SingleTickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();
  final MovieRepository _movieRepository = MovieRepository();

  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  List<Map<String, String>> _previewPosters = [];
  bool _isLoadingPreview = true;
  bool _isNavigating = false;

  static const String _posterUrl =
      'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=1200&auto=format&fit=crop';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutCubic),
    );

    _loadPersonalizedPreview();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadPersonalizedPreview() async {
    final user = _authRepository.currentUser;
    final favoriteGenres = user?.favoriteGenres ?? ['Action', 'Sci-Fi', 'Thriller'];

    try {
      final allMovies = await _movieRepository.getTrending();
      final matched = allMovies.where((m) =>
          favoriteGenres.any((g) => m.genres.any((mg) => mg.toLowerCase().contains(g.toLowerCase())))).toList();

      final list = (matched.isNotEmpty ? matched : allMovies).take(5).map((m) => {
        'title': m.title,
        'poster': m.posterUrl.isNotEmpty
            ? m.posterUrl
            : 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=600&auto=format&fit=crop',
      }).toList();

      if (mounted) {
        setState(() {
          _previewPosters = list;
          _isLoadingPreview = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _previewPosters = [];
          _isLoadingPreview = false;
        });
      }
    }
  }

  Future<void> _startWatching() async {
    if (_isNavigating) return;
    setState(() {
      _isNavigating = true;
    });

    await _authRepository.completeOnboarding();

    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: Stack(
        children: [
          // 1. Full-screen Ken Burns backdrop poster
          const Positioned.fill(
            child: KenBurnsPoster(
              imageUrl: _posterUrl,
              heightRatio: 1.0,
            ),
          ),

          // 2. Dark Overlay & Ambient Aurora Lighting
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    const Color(0xFF050608).withOpacity(0.85),
                    const Color(0xFF050608),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00CFFF).withOpacity(0.18),
              ),
            ),
          ),

          // 3. Foreground Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(),

                  // Success Badge Animation (Glowing Thumbs Up Icon Pod)
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00CFFF).withOpacity(0.15),
                        border: Border.all(
                          color: const Color(0xFF00CFFF),
                          width: 2.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF00CFFF),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: Color(0xFF7A5CFF),
                            blurRadius: 50,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.thumb_up_rounded,
                          size: 54,
                          color: Color(0xFF00CFFF),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Heading
                  const Text(
                    'Congratulations!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Color(0x9900CFFF),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subtitle
                  const Text(
                    'Your recommendations are set done.\nYour personalized entertainment experience is ready.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFBBC9CF),
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Personalized Movie Posters Horizontal Preview
                  SizedBox(
                    height: 150,
                    child: _isLoadingPreview
                        ? _buildSkeletonPreview()
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: _previewPosters.length,
                            itemBuilder: (context, index) {
                              final item = _previewPosters[index];
                              return Container(
                                width: 105,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.18),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    item['poster']!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(color: const Color(0xFF161E2E)),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  const Spacer(),

                  // Primary Button: Start Watching / Done
                  GlassPrimaryButton(
                    label: _isNavigating ? 'Opening Ether Cinema...' : 'Start Watching',
                    icon: Icons.play_arrow_rounded,
                    onPressed: _startWatching,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonPreview() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      itemBuilder: (context, index) => Container(
        width: 105,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
      ),
    );
  }
}
