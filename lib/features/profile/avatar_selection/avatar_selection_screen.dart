import 'package:flutter/material.dart';
import '../../../core/auth/auth_repository.dart';
import '../../auth/login_screen.dart';
import '../../onboarding/onboarding_widgets.dart';
import '../profile_selection/profile_selection_screen.dart';

class AvatarSelectionScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const AvatarSelectionScreen({super.key, this.onComplete});

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  final AuthRepository _authRepository = AuthRepository();
  late TextEditingController _nameController;

  final List<Map<String, String>> _avatars = [
    {
      'title': 'Cyber Gamer',
      'url': 'https://images.unsplash.com/photo-1566492031773-4f4e44671857?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'VR Visionary',
      'url': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Cool Headset',
      'url': 'https://images.unsplash.com/photo-1544717305-2782549b5136?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Valkyrie 4K',
      'url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Neon Kid',
      'url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Sci-Fi Hero',
      'url': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=600&auto=format&fit=crop',
    },
  ];

  int _selectedAvatarIndex = 0;
  bool _isEditingName = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final initialName = _authRepository.currentUser?.displayName.isNotEmpty == true
        ? _authRepository.currentUser!.displayName
        : 'Viewer Profile';
    _nameController = TextEditingController(text: initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    setState(() {
      _isSaving = true;
    });

    final selectedUrl = _avatars[_selectedAvatarIndex]['url']!;
    final name = _nameController.text.trim();

    await _authRepository.updateUserAvatarAndName(
      avatarUrl: selectedUrl,
      displayName: name,
    );

    if (mounted) {
      widget.onComplete?.call();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
            opacity: animation,
            child: const ProfileSelectionScreen(),
          ),
        ),
      );
    }
  }

  void _handleBackNavigation() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: const LoginScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedAvatar = _avatars[_selectedAvatarIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF050608),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Top Onboarding Progress Bar
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
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF00CFFF),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Choose Avatar',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Large Avatar Preview Container
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFF00CFFF),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00CFFF).withOpacity(0.4),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          selectedAvatar['url']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF161E2E),
                            child: const Icon(Icons.person, size: 80, color: Color(0xFF00CFFF)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Display Name with Edit Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isEditingName)
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: _nameController,
                        autofocus: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF00CFFF)),
                          ),
                        ),
                        onSubmitted: (_) => setState(() => _isEditingName = false),
                      ),
                    )
                  else
                    Text(
                      _nameController.text,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _isEditingName ? Icons.check_circle_rounded : Icons.edit_rounded,
                      color: const Color(0xFF00CFFF),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _isEditingName = !_isEditingName),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Horizontal Avatar Carousel
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _avatars.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedAvatarIndex;
                    final avatar = _avatars[index];

                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatarIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: isSelected ? 80 : 70,
                        height: isSelected ? 80 : 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00CFFF)
                                : Colors.white.withOpacity(0.15),
                            width: isSelected ? 2.5 : 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF00CFFF).withOpacity(0.5),
                                    blurRadius: 14,
                                  ),
                                ]
                              : [],
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                avatar['url']!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: const Color(0xFF161E2E),
                                  child: const Icon(Icons.person, color: Colors.white54),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF00CFFF),
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
                    );
                  },
                ),
              ),

              const Spacer(),

              // Actions: Next & Skip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  children: [
                    GlassPrimaryButton(
                      label: _isSaving ? 'Saving Profile...' : 'Next',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _isSaving ? () {} : _saveAndContinue,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _saveAndContinue,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFFBBC9CF),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
