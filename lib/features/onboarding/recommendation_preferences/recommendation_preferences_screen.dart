import 'package:flutter/material.dart';
import '../../../core/auth/auth_repository.dart';
import '../completion/onboarding_completion_screen.dart';
import '../onboarding_widgets.dart';

class RecommendationPreferencesScreen extends StatefulWidget {
  const RecommendationPreferencesScreen({super.key});

  @override
  State<RecommendationPreferencesScreen> createState() =>
      _RecommendationPreferencesScreenState();
}

class _RecommendationPreferencesScreenState
    extends State<RecommendationPreferencesScreen> {
  final AuthRepository _authRepository = AuthRepository();
  final Set<String> _selectedGenres = {};
  bool _isSaving = false;

  static const List<Map<String, String>> _genreCatalog = [
    {
      'name': 'Action',
      'poster': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Adventure',
      'poster': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Animation',
      'poster': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Anime',
      'poster': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Biography',
      'poster': 'https://images.unsplash.com/photo-1461360370896-922624d12aa1?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Comedy',
      'poster': 'https://images.unsplash.com/photo-1514306191717-452ec28c7814?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Crime',
      'poster': 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Documentary',
      'poster': 'https://images.unsplash.com/photo-1485846234645-a62644f84728?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Drama',
      'poster': 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Family',
      'poster': 'https://images.unsplash.com/photo-1511895426328-dc8714191300?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Fantasy',
      'poster': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Horror',
      'poster': 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Kids',
      'poster': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Korean',
      'poster': 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Mystery',
      'poster': 'https://images.unsplash.com/photo-1485846234645-a62644f84728?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Romance',
      'poster': 'https://images.unsplash.com/photo-1518199266791-5375a83190b7?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Sci-Fi',
      'poster': 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Sports',
      'poster': 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'Thriller',
      'poster': 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?q=80&w=600&auto=format&fit=crop',
    },
    {
      'name': 'War',
      'poster': 'https://images.unsplash.com/photo-1461360370896-922624d12aa1?q=80&w=600&auto=format&fit=crop',
    },
  ];

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        if (_selectedGenres.length < 10) {
          _selectedGenres.add(genre);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can select a maximum of 10 favorite genres.'),
              backgroundColor: Color(0xFF7A5CFF),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  Future<void> _savePreferencesAndProceed({bool isSkip = false}) async {
    setState(() {
      _isSaving = true;
    });

    final genresToSave = isSkip || _selectedGenres.length < 3
        ? ['Action', 'Sci-Fi', 'Thriller']
        : _selectedGenres.toList();

    try {
      await _authRepository.updateUserFavoriteGenres(genresToSave);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                FadeTransition(
              opacity: animation,
              child: const OnboardingCompletionScreen(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        _showErrorDialog(e.toString(), () => _savePreferencesAndProceed(isSkip: isSkip));
      }
    }
  }

  void _showErrorDialog(String error, VoidCallback onRetry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D111A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Save Error', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Failed to save preferences: $error', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00CFFF)),
            onPressed: () {
              Navigator.of(context).pop();
              onRetry();
            },
            child: const Text('Retry', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canProceed = _selectedGenres.length >= 3;

    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Top Step Progress Indicator (Step 3 / 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00CFFF),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00CFFF),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00CFFF),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF00CFFF),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Heading & Subtitle
            const Text(
              'Customize Your\nRecommendation Feed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose at least 3 favorite genres (${_selectedGenres.length}/10 selected)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFBBC9CF),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            // Genre Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.35,
                ),
                itemCount: _genreCatalog.length,
                itemBuilder: (context, index) {
                  final genreItem = _genreCatalog[index];
                  final genreName = genreItem['name']!;
                  final isSelected = _selectedGenres.contains(genreName);

                  return GestureDetector(
                    onTap: () => _toggleGenre(genreName),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF00CFFF)
                              : Colors.white.withOpacity(0.12),
                          width: isSelected ? 2.5 : 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF00CFFF).withOpacity(0.4),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Movie Poster Image
                            Image.network(
                              genreItem['poster']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFF161E2E),
                              ),
                            ),

                            // Dark Overlay Gradient
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.black.withOpacity(0.85),
                                  ],
                                ),
                              ),
                            ),

                            // Genre Title
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  genreName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? const Color(0xFF00CFFF) : Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.8),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Top Right Selected Check Indicator
                            if (isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF00CFFF),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF00CFFF),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Bottom Actions: Next & Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                children: [
                  GlassPrimaryButton(
                    label: _isSaving
                        ? 'Saving Feed...'
                        : canProceed
                            ? 'Next'
                            : 'Select ${3 - _selectedGenres.length} more',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _isSaving || !canProceed
                        ? () {}
                        : () => _savePreferencesAndProceed(),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isSaving ? null : () => _savePreferencesAndProceed(isSkip: true),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Color(0xFFBBC9CF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
