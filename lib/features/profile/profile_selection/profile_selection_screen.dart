import 'package:flutter/material.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/models/user_profile.dart';
import '../../auth/login_screen.dart';
import '../../main/main_screen.dart';
import '../../onboarding/onboarding_widgets.dart';
import '../../onboarding/recommendation_preferences/recommendation_preferences_screen.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  final AuthRepository _authRepository = AuthRepository();
  late List<UserProfile> _profiles;
  bool _isEditingMode = false;
  String? _selectedProfileId;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  void _loadProfiles() {
    final user = _authRepository.currentUser;
    if (user != null && user.profiles.isNotEmpty) {
      _profiles = List<UserProfile>.from(user.profiles);
      _selectedProfileId = _profiles.first.id;
    } else {
      _profiles = [
        UserProfile(
          id: 'p_1',
          displayName: user?.displayName.isNotEmpty == true ? user!.displayName : 'Dima',
          avatarUrl: user?.avatar.isNotEmpty == true
              ? user!.avatar
              : 'https://images.unsplash.com/photo-1544717305-2782549b5136?q=80&w=600&auto=format&fit=crop',
        ),
      ];
      _selectedProfileId = _profiles.first.id;
    }
  }

  void _selectProfile(UserProfile profile) {
    _authRepository.setActiveProfile(profile);

    final user = _authRepository.currentUser;
    final TargetWidget = (user != null && !user.preferencesCompleted)
        ? const RecommendationPreferencesScreen()
        : const MainScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: TargetWidget,
        ),
      ),
    );
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

  void _showAddProfileModal() {
    final nameController = TextEditingController();
    bool isKids = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D111A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add a New Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Profile Name (e.g. Alex, Kids)',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    activeColor: const Color(0xFF00CFFF),
                    title: const Text('Kids Profile', style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Filters out 18+ content', style: TextStyle(color: Colors.white38, fontSize: 11)),
                    value: isKids,
                    onChanged: (val) => setModalState(() => isKids = val),
                  ),
                  const SizedBox(height: 20),
                  GlassPrimaryButton(
                    label: 'Create Profile',
                    onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isNotEmpty) {
                        final newP = UserProfile(
                          id: 'p_${DateTime.now().millisecondsSinceEpoch}',
                          displayName: name,
                          avatarUrl: isKids
                              ? 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=600&auto=format&fit=crop'
                              : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=600&auto=format&fit=crop',
                          isKids: isKids,
                        );
                        final updated = await _authRepository.addProfile(newP);
                        if (mounted) {
                          setState(() {
                            _profiles = updated;
                          });
                          Navigator.of(context).pop();
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditProfileModal(UserProfile profile) {
    final nameController = TextEditingController(text: profile.displayName);
    bool isKids = profile.isKids;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D111A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Profile: ${profile.displayName}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Profile Name',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    activeThumbColor: const Color(0xFF00CFFF),
                    title: const Text('Kids Profile', style: TextStyle(color: Colors.white)),
                    value: isKids,
                    onChanged: (val) => setModalState(() => isKids = val),
                  ),
                  const SizedBox(height: 20),
                  GlassPrimaryButton(
                    label: 'Save Changes',
                    onPressed: () async {
                      final updatedP = profile.copyWith(
                        displayName: nameController.text.trim(),
                        isKids: isKids,
                      );
                      final updatedList = await _authRepository.updateProfile(updatedP);
                      if (mounted) {
                        setState(() {
                          _profiles = updatedList;
                        });
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      final updatedList = await _authRepository.deleteProfile(profile.id);
                      if (mounted) {
                        setState(() {
                          _profiles = updatedList;
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Delete Profile', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF050608),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Ether Cinema Logo Header
                const EtherLogoBadge(size: 60),
                const SizedBox(height: 16),

                // Title
                const Text(
                  "Who's Watching",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Color(0x9900CFFF),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // Profiles Grid / Cards Container
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _profiles.length + 1, // Profiles + Add Profile card
                    itemBuilder: (context, index) {
                      if (index < _profiles.length) {
                        final profile = _profiles[index];
                        final isSelected = profile.id == _selectedProfileId;

                        return GestureDetector(
                          onTap: () {
                            if (_isEditingMode) {
                              _showEditProfileModal(profile);
                            } else {
                              setState(() => _selectedProfileId = profile.id);
                              _selectProfile(profile);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: BoxDecoration(
                              color: const Color(0xCC0D111A),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00CFFF)
                                    : Colors.white.withValues(alpha: 0.12),
                                width: isSelected ? 2.5 : 1.2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF00CFFF).withValues(alpha: 0.4),
                                        blurRadius: 20,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Image.network(
                                      profile.avatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: const Color(0xFF161E2E),
                                        child: const Icon(Icons.person, size: 50, color: Color(0xFF00CFFF)),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  profile.displayName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (profile.isKids) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00CFFF).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('KIDS', style: TextStyle(color: Color(0xFF00CFFF), fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      } else {
                        // Add Profile Card
                        return GestureDetector(
                          onTap: _showAddProfileModal,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 1.2,
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_add_alt_1_rounded, size: 48, color: Colors.white54),
                                SizedBox(height: 10),
                                Text(
                                  'Add a new profile',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),

                // Edit Profiles Button
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditingMode = !_isEditingMode;
                    });
                  },
                  icon: Icon(
                    _isEditingMode ? Icons.check_circle_rounded : Icons.edit_rounded,
                    color: const Color(0xFF00CFFF),
                    size: 18,
                  ),
                  label: Text(
                    _isEditingMode ? 'Done Editing' : 'Edit Profiles',
                    style: const TextStyle(
                      color: Color(0xFF00CFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Primary "Done" Button & "Skip" Link
                GlassPrimaryButton(
                  label: 'Done',
                  onPressed: () {
                    if (_profiles.isNotEmpty) {
                      _selectProfile(_profiles.first);
                    } else {
                      final user = _authRepository.currentUser;
                      final nextScreen = (user != null && !user.preferencesCompleted)
                          ? const RecommendationPreferencesScreen()
                          : const MainScreen();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => nextScreen),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    final user = _authRepository.currentUser;
                    final nextScreen = (user != null && !user.preferencesCompleted)
                        ? const RecommendationPreferencesScreen()
                        : const MainScreen();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => nextScreen),
                    );
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Color(0xFFBBC9CF), fontSize: 13),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
