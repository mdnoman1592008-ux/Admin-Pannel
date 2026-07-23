import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/liquid_button.dart';

class OnboardingFlowScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingFlowScreen({super.key, required this.onComplete});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  int _currentStep = 0; // 0: Welcome, 1: Features, 2: Auth, 3: Profile, 4: Genres, 5: Recommendation

  final List<String> _avatars = [
    'Alexander VIP',
    'Cyber Kids',
    'Neo Streamer',
    'Valkyrie 4K',
  ];
  int _selectedAvatarIndex = 0;

  final List<String> _genres = [
    'Sci-Fi', 'Action', 'Drama', 'IMAX Shorts', 'Cyberpunk', 'Anime', 'Documentary', 'Thriller'
  ];
  final Set<String> _selectedGenres = {'Sci-Fi', 'IMAX Shorts'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background ambient gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.4),
                  radius: 1.2,
                  colors: [
                    Color(0x3300D4FF),
                    Color(0x227000FF),
                    Color(0xFF050505),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Step Indicator
                  Row(
                    children: List.generate(6, (idx) {
                      final isActive = idx <= _currentStep;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primaryContainer : Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  Expanded(
                    child: _buildCurrentStepContent(),
                  ),

                  // Bottom Action Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        TextButton(
                          onPressed: () => setState(() => _currentStep--),
                          child: const Text('Back', style: TextStyle(color: Colors.white70)),
                        )
                      else
                        const SizedBox.shrink(),
                      
                      LiquidButton(
                        label: _currentStep == 5 ? 'Launch Cinema' : 'Continue',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () {
                          if (_currentStep < 5) {
                            setState(() => _currentStep++);
                          } else {
                            widget.onComplete();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.primaryContainer, size: 72),
            const SizedBox(height: 24),
            const Text(
              'Ether Cinema VisionOS',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.extrabold, color: Colors.white, tracking: 1.2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Experience AAA 4K IMAX Streaming with 3D Glassmorphic Motion',
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        );
      case 1:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassContainer(
              borderRadius: 24,
              padding: const EdgeInsets.all(24),
              child: const Column(
                children: [
                  Icon(Icons.tv_rounded, color: AppColors.tertiary, size: 48),
                  SizedBox(height: 16),
                  Text('IMAX 4K & Spatial Sound', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 8),
                  Text('Dailymotion ultra-low latency playback with Dolby spatial audio simulations.', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center),
                ],
              ),
            ),
          ],
        );
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Choose Access Mode', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(16),
              child: const ListTile(
                leading: Icon(Icons.person, color: AppColors.primaryContainer),
                title: Text('Continue as Guest', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('100% Open Access • Zero Subscription', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
              ),
            ),
          ],
        );
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Choose Your 3D Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(_avatars.length, (idx) {
                final isSelected = _selectedAvatarIndex == idx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatarIndex = idx),
                  child: GlassContainer(
                    borderRadius: 20,
                    borderColor: isSelected ? AppColors.primaryContainer : AppColors.glassBorder,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(idx == 1 ? Icons.child_care : Icons.face, color: isSelected ? AppColors.primaryContainer : Colors.white60, size: 40),
                        const SizedBox(height: 8),
                        Text(_avatars[idx], style: TextStyle(color: isSelected ? AppColors.primaryContainer : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      case 4:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Select Favorite Genres', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _genres.map((g) {
                final isSel = _selectedGenres.contains(g);
                return FilterChip(
                  label: Text(g, style: TextStyle(color: isSel ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  selected: isSel,
                  selectedColor: AppColors.primaryContainer,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedGenres.add(g);
                      } else {
                        _selectedGenres.remove(g);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.tertiary, size: 80),
            const SizedBox(height: 20),
            const Text('Personalized Feed Ready!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Text('Curated ${_selectedGenres.join(", ")} catalog primed for 120 FPS playback.', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13), textAlign: TextAlign.center),
          ],
        );
    }
  }
}
