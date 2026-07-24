import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/auth/admin_auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';

/// Enterprise Glassmorphism Admin Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onLoginSuccess});

  final VoidCallback? onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _rememberMe = true;
  bool _isLoading = false;
  String _authMessage = '';
  bool _isError = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isError = true;
        _authMessage = 'Please enter both email and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isError = false;
      _authMessage = 'Authenticating with Firebase Auth...';
    });

    final success = await AdminAuthService.instance.signInWithEmail(
      email: email,
      password: password,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (!success) {
          _isError = true;
          _authMessage = AdminAuthService.instance.state.errorMessage ??
              'Authentication failed. Invalid credentials.';
        } else {
          _isError = false;
          _authMessage = 'Authorized! Loading Dashboard...';
          widget.onLoginSuccess?.call();
        }
      });
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _isError = false;
      _authMessage = 'Connecting to Google OAuth...';
    });

    final success = await AdminAuthService.instance.signInWithGoogle();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (!success) {
          _isError = true;
          _authMessage = AdminAuthService.instance.state.errorMessage ??
              'Google Sign-In failed.';
        } else {
          _isError = false;
          _authMessage = 'Authorized! Loading Dashboard...';
          widget.onLoginSuccess?.call();
        }
      });
    }
  }

  Future<void> _handleFacebookLogin() async {
    setState(() {
      _isLoading = true;
      _isError = false;
      _authMessage = 'Connecting to Facebook Auth...';
    });

    final success = await AdminAuthService.instance.signInWithFacebook();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (!success) {
          _isError = true;
          _authMessage = AdminAuthService.instance.state.errorMessage ??
              'Facebook Sign-In failed.';
        } else {
          _isError = false;
          _authMessage = 'Authorized! Loading Dashboard...';
          widget.onLoginSuccess?.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Background ambient light orbs
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.12),
                  boxShadow: [AppColors.glowCyan(blur: 150, opacity: 0.3)],
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withOpacity(0.12),
                  boxShadow: [AppColors.glowPurple(blur: 150, opacity: 0.3)],
                ),
              ),
            ),
            // Center glass card
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: GlassCard(
                  width: 440,
                  padding: const EdgeInsets.all(36),
                  glowColor: AppColors.primary,
                  glowBlur: 40,
                  borderColor: AppColors.primary.withOpacity(0.2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Large Animated Logo
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            AppColors.glowCyan(blur: 24, opacity: 0.6)
                          ],
                        ),
                        child: const Icon(
                          Icons.play_circle_fill_rounded,
                          color: Colors.black,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Ether Cinema', style: AppTextStyles.h1()),
                      const SizedBox(height: 6),
                      Text(
                        'Enterprise Web Admin Portal',
                        style: AppTextStyles.bodySm().copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 28),
                      // Social login buttons
                      Row(
                        children: [
                          Expanded(
                            child: GlowButton(
                              label: 'Facebook',
                              icon: Icons.facebook_rounded,
                              color: AppColors.facebook,
                              textColor: Colors.white,
                              outlined: true,
                              isSmall: true,
                              onPressed:
                                  _isLoading ? null : _handleFacebookLogin,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlowButton(
                              label: 'Google',
                              icon: Icons.g_mobiledata_rounded,
                              color: AppColors.google,
                              textColor: Colors.white,
                              outlined: true,
                              isSmall: true,
                              onPressed: _isLoading ? null : _handleGoogleLogin,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                                  height: 1, color: AppColors.glassBorder)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR EMAIL',
                              style: AppTextStyles.labelCaps(),
                            ),
                          ),
                          Expanded(
                              child: Container(
                                  height: 1, color: AppColors.glassBorder)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Email field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Email Address',
                            style: AppTextStyles.labelLg()),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: AppTextStyles.body().copyWith(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Admin email address',
                          prefixIcon: Icon(Icons.email_outlined,
                              size: 18, color: AppColors.textMuted),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Password field
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Password', style: AppTextStyles.labelLg()),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passCtrl,
                        obscureText: true,
                        style: AppTextStyles.body().copyWith(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: '••••••••••••',
                          prefixIcon: Icon(Icons.lock_outline_rounded,
                              size: 18, color: AppColors.textMuted),
                        ),
                        onSubmitted: (_) => _handleEmailLogin(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v ?? true),
                                activeColor: AppColors.primary,
                              ),
                              Text('Remember me',
                                  style: AppTextStyles.bodySm()),
                            ],
                          ),
                          Flexible(
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot Password?',
                                style: AppTextStyles.bodySm()
                                    .copyWith(color: AppColors.primary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_authMessage.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: (_isError
                                    ? AppColors.danger
                                    : AppColors.success)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: (_isError
                                      ? AppColors.danger
                                      : AppColors.success)
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isError
                                    ? Icons.error_outline_rounded
                                    : Icons.check_circle_outline_rounded,
                                color: _isError
                                    ? AppColors.danger
                                    : AppColors.success,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _authMessage,
                                  style: AppTextStyles.bodySm().copyWith(
                                    color: _isError
                                        ? AppColors.danger
                                        : AppColors.success,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      GlowButton(
                        label: 'Sign In to Dashboard',
                        icon: Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                        fullWidth: true,
                        isLoading: _isLoading,
                        gradient: AppColors.primaryGradient,
                        onPressed: _handleEmailLogin,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
