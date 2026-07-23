import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';
import '../../core/widgets/status_badge.dart';

/// Premium Login Screen — Ether Cinema Admin Panel
/// Hero section, glass card, animated logo, social auth buttons
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onLoginSuccess});

  final VoidCallback? onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'admin@ethercinema.app');
  final _passCtrl = TextEditingController(text: '••••••••••••');
  bool _rememberMe = true;
  bool _isLoading = false;
  String _authMessage = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String provider) async {
    setState(() {
      _isLoading = true;
      _authMessage = 'Authenticating via $provider...';
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _isLoading = false;
      _authMessage = 'Authentication Successful! Redirecting...';
    });
    await Future.delayed(const Duration(milliseconds: 600));
    widget.onLoginSuccess?.call();
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
            // Background ambient glow circles
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
            // Main content center
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
                      // Animated logo
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [AppColors.glowCyan(blur: 24, opacity: 0.6)],
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
                        'Enterprise Admin Portal',
                        style: AppTextStyles.bodySm().copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 28),
                      // Social Auth Buttons
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
                              onPressed: () => _handleLogin('Facebook'),
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
                              onPressed: () => _handleLogin('Google'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: Container(height: 1, color: AppColors.glassBorder)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR EMAIL',
                              style: AppTextStyles.labelCaps(),
                            ),
                          ),
                          Expanded(child: Container(height: 1, color: AppColors.glassBorder)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Form fields
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Email Address', style: AppTextStyles.labelLg()),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailCtrl,
                        style: AppTextStyles.body().copyWith(fontSize: 14),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined, size: 18, color: AppColors.textMuted),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                          prefixIcon: Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textMuted),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (v) => setState(() => _rememberMe = v ?? true),
                            activeColor: AppColors.primary,
                          ),
                          Text('Remember me', style: AppTextStyles.bodySm()),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.bodySm().copyWith(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_authMessage.isNotEmpty) ...[
                        Text(
                          _authMessage,
                          style: AppTextStyles.bodySm().copyWith(
                            color: _authMessage.contains('Successful')
                                ? AppColors.success
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      GlowButton(
                        label: 'Sign In to Dashboard',
                        icon: Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                        fullWidth: true,
                        isLoading: _isLoading,
                        gradient: AppColors.primaryGradient,
                        onPressed: () => _handleLogin('Email'),
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
