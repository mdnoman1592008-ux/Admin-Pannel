import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/auth/auth_repository.dart';
import '../../core/auth/auth_service.dart';
import '../../core/services/permission_service.dart';
import '../onboarding/onboarding_widgets.dart';
import '../profile/avatar_selection/avatar_selection_screen.dart';
import '../profile/profile_selection/profile_selection_screen.dart';
import '../main/main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _showEmailInputs = false;
  String? _errorMessage;

  late AnimationController _rotationController;

  static const String _posterUrl =
      'https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=1200&auto=format&fit=crop';

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _startLoadingAnimation() {
    _rotationController.repeat();
  }

  void _stopLoadingAnimation() {
    _rotationController.stop();
  }

  void _navigatePostLogin(UserDocument user) async {
    // Request native notification permissions post-login
    if (context.mounted) {
      await PermissionService().requestNotificationPermission(context);
    }

    if (!context.mounted) return;

    if (widget.onLoginSuccess != null) {
      widget.onLoginSuccess!();
      return;
    }

    Widget targetScreen;
    if (!user.hasCompletedOnboarding) {
      targetScreen = const AvatarSelectionScreen();
    } else if (user.profiles.length > 1) {
      targetScreen = const ProfileSelectionScreen();
    } else {
      targetScreen = const MainScreen();
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: targetScreen,
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _handleFacebookLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _startLoadingAnimation();

    try {
      final user = await _authService.signInWithFacebook();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Welcome back, ${user.displayName}! Signed in via Facebook.'),
            backgroundColor: const Color(0xFF1877F2),
          ),
        );
        _navigatePostLogin(user);
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().contains('cancelled') ||
              e.toString().contains('canceled')) {
            _errorMessage = 'Facebook sign-in was cancelled.';
          } else if (e.toString().contains('network') ||
              e.toString().contains('SocketException')) {
            _errorMessage =
                'Network error during Facebook authentication. Please check your internet connection.';
          } else {
            _errorMessage = 'Facebook Sign-In failed: $e';
          }
        });
      }
    } finally {
      if (mounted) {
        _stopLoadingAnimation();
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _startLoadingAnimation();

    try {
      final user = await _authService.signInWithGoogle();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Welcome back, ${user.displayName}! Signed in via Google.'),
            backgroundColor: const Color(0xFF4285F4),
          ),
        );
        _navigatePostLogin(user);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().contains('cancelled') ||
              e.toString().contains('canceled')) {
            _errorMessage = 'Google sign-in was cancelled.';
          } else if (e.toString().contains('network') ||
              e.toString().contains('SocketException')) {
            _errorMessage =
                'Network error during Google authentication. Please check your connection.';
          } else {
            _errorMessage = 'Google Sign-In failed: $e';
          }
        });
      }
    } finally {
      if (mounted) {
        _stopLoadingAnimation();
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both your email address and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _startLoadingAnimation();

    try {
      final user = await _authService.signInWithEmailPassword(email, password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${user.displayName}!'),
            backgroundColor: const Color(0xFF00CFFF),
          ),
        );
        _navigatePostLogin(user);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().contains('invalid-credential') ||
              e.toString().contains('user-not-found') ||
              e.toString().contains('wrong-password')) {
            _errorMessage = 'Invalid email address or password credentials.';
          } else if (e.toString().contains('network')) {
            _errorMessage = 'Network error. Please verify your connection.';
          } else {
            _errorMessage = 'Authentication failed: $e';
          }
        });
      }
    } finally {
      if (mounted) {
        _stopLoadingAnimation();
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final controller =
        TextEditingController(text: _emailController.text.trim());
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset password'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Email address'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Send link'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (email == null || email.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _authService.sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'If an account exists, a password-reset link has been sent.')),
      );
    } on AuthException catch (error) {
      if (mounted) setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: RegisterScreen(
            onRegisterSuccess: () {
              final user = _authService.currentUser;
              if (user != null) {
                _navigatePostLogin(user);
              } else {
                widget.onLoginSuccess?.call();
              }
            },
            onBackToLogin: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
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
              heightRatio: 0.50,
            ),
          ),

          // 2. Ambient Aurora Glow Accents (Royal Purple & Electric Blue)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
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
            bottom: 30,
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

          // 3. Foreground Auth Form Content
          SafeArea(
            child: Column(
              children: [
                // Back button row
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.28),

                        // Ether Cinema Logo Badge
                        const EtherLogoBadge(size: 64),
                        const SizedBox(height: 18),

                        // Heading
                        const Text(
                          'Start Streaming with Ether Cinema',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            height: 1.18,
                            shadows: [
                              Shadow(
                                color: Color(0x9900CFFF),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Subtitle
                        const Text(
                          'Sign in to access your personalized movies, continue watching, favorites, and premium entertainment.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFBBC9CF),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Elegant Error Card Display
                        if (_errorMessage != null) ...[
                          _buildGlassErrorCard(_errorMessage!),
                          const SizedBox(height: 16),
                        ],

                        // Loading Overlay Indicator (Custom Glass Loader)
                        if (_isLoading) ...[
                          _buildGlassLoaderCard(),
                          const SizedBox(height: 16),
                        ],

                        // ① Social Button 1: Continue with Google
                        _buildGoogleLoginButton(),
                        const SizedBox(height: 12),

                        // ② Social Button 2: Continue with Facebook (NO APPLE LOGIN)
                        _buildFacebookLoginButton(),
                        const SizedBox(height: 20),

                        // Divider: ──────── OR ────────
                        Row(
                          children: [
                            Expanded(
                                child: Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.12))),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14.0),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Color(0xFF8B9BAE),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.12))),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Email Input Drawer (Expandable when Sign In is clicked)
                        if (_showEmailInputs) ...[
                          _buildEmailInputFields(),
                          const SizedBox(height: 14),
                        ],

                        // Primary Button: Sign In with Email
                        GlassPrimaryButton(
                          label: 'Sign In with Email',
                          icon: Icons.login_rounded,
                          onPressed: () {
                            if (!_showEmailInputs) {
                              setState(() {
                                _showEmailInputs = true;
                              });
                            } else {
                              _handleEmailLogin();
                            }
                          },
                        ),
                        if (_showEmailInputs)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed:
                                  _isLoading ? null : _showForgotPasswordDialog,
                              child: const Text('Forgot password?'),
                            ),
                          ),
                        const SizedBox(height: 20),

                        // Bottom Link: Don't have an account? Sign Up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Color(0xFFBBC9CF),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            GestureDetector(
                              onTap: _navigateToRegister,
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFF00CFFF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ① Glass Card: Continue with Google Button (White button with 4-color Google G icon)
  Widget _buildGoogleLoginButton() {
    return _SocialGlassButton(
      label: 'Continue with Google',
      customIcon: const GoogleGLogoWidget(size: 20),
      backgroundColor: Colors.white,
      borderColor: const Color(0xFFDADCE0),
      textColor: const Color(0xFF1F1F1F),
      onPressed: _isLoading ? () {} : _handleGoogleLogin,
    );
  }

  /// ② Glass Card: Continue with Facebook Button
  Widget _buildFacebookLoginButton() {
    return _SocialGlassButton(
      label: 'Continue with Facebook',
      icon: Icons.facebook_rounded,
      iconColor: Colors.white,
      backgroundColor: const Color(0xFF1877F2).withOpacity(0.85),
      borderColor: const Color(0xFF1877F2),
      glowColor: const Color(0xFF1877F2),
      onPressed: _isLoading ? () {} : _handleFacebookLogin,
    );
  }

  /// Email & Password Text Fields Container
  Widget _buildEmailInputFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xCC0D111A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00CFFF).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Email Address',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
              prefixIcon: const Icon(Icons.email_outlined,
                  color: Color(0xFF00CFFF), size: 20),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Password',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
              prefixIcon: const Icon(Icons.lock_outline_rounded,
                  color: Color(0xFF00CFFF), size: 20),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Elegant Error Glass Card
  Widget _buildGlassErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x33FF3B30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x80FF3B30), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FF3B30),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFFF3B30), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom Thin Glass Loader Card
  Widget _buildGlassLoaderCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0x990D111A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00CFFF).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _rotationController,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CustomPaint(
                painter: _LoaderRingPainter(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Authenticating account...',
            style: TextStyle(
              color: Color(0xFF00CFFF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialGlassButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color? glowColor;
  final VoidCallback onPressed;

  const _SocialGlassButton({
    required this.label,
    this.icon,
    this.customIcon,
    this.iconColor = Colors.white,
    required this.backgroundColor,
    required this.borderColor,
    this.textColor = Colors.white,
    this.glowColor,
    required this.onPressed,
  });

  @override
  State<_SocialGlassButton> createState() => _SocialGlassButtonState();
}

class _SocialGlassButtonState extends State<_SocialGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 54,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(27),
                  color: widget.backgroundColor,
                  border: Border.all(color: widget.borderColor, width: 1.2),
                  boxShadow: [
                    if (widget.glowColor != null || _isHovered)
                      BoxShadow(
                        color: (widget.glowColor ?? widget.borderColor)
                            .withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.customIcon != null)
                        widget.customIcon!
                      else if (widget.icon != null)
                        Icon(widget.icon, color: widget.iconColor, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
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
    );
  }
}

class GoogleGLogoWidget extends StatelessWidget {
  final double size;

  const GoogleGLogoWidget({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleGLogoPainter(),
      ),
    );
  }
}

class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final double strokeWidth = size.width * 0.22;
    final Rect rect =
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Red (Top arc)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -3.14159 * 0.75, 3.14159 * 0.65, false, paint);

    // Yellow (Left arc)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -3.14159 * 1.25, 3.14159 * 0.5, false, paint);

    // Green (Bottom arc)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 3.14159 * 0.15, 3.14159 * 0.6, false, paint);

    // Blue (Right arc & crossbar)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -3.14159 * 0.15, 3.14159 * 0.3, false, paint);

    // Blue crossbar
    final Paint fillBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(radius, radius - strokeWidth / 2, size.width,
          radius + strokeWidth / 2),
      fillBlue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoaderRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Colors.transparent,
          Color(0x3300CFFF),
          Color(0xFF00CFFF),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect.deflate(2), 0, 5.0, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
