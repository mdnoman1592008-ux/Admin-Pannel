import 'dart:ui';
import 'package:flutter/material.dart';
import '../../features/auth/access_denied_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/shell/admin_shell.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/glass_card.dart';
import 'admin_auth_service.dart';

/// Enterprise Route Guard & Auth Gateway
/// Hardened security wrapper: Dashboard is NEVER mounted unless authenticated & authorized
class AuthGateway extends StatefulWidget {
  const AuthGateway({super.key});

  @override
  State<AuthGateway> createState() => _AuthGatewayState();
}

class _AuthGatewayState extends State<AuthGateway> {
  final _authService = AdminAuthService.instance;

  @override
  void initState() {
    super.initState();
    _authService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authService,
      builder: (context, _) {
        final state = _authService.state;

        switch (state.status) {
          case AuthStatus.initial:
          case AuthStatus.authenticating:
            return const _AuthLoadingSplash();

          case AuthStatus.unauthenticated:
            return const LoginScreen();

          case AuthStatus.denied:
            if (state.user != null) {
              return AccessDeniedScreen(
                user: state.user!,
                reason: state.errorMessage,
              );
            }
            return const LoginScreen();

          case AuthStatus.authorized:
            if (state.isAuthorized) {
              return const AdminShell();
            }
            return const LoginScreen();
        }
      },
    );
  }
}

/// Glassmorphism Loading Splash for Auth Gateway
class _AuthLoadingSplash extends StatelessWidget {
  const _AuthLoadingSplash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: GlassCard(
            width: 320,
            padding: const EdgeInsets.all(32),
            glowColor: AppColors.primary,
            glowBlur: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [AppColors.glowCyan(blur: 20, opacity: 0.5)],
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Ether Security Gate', style: AppTextStyles.h3()),
                const SizedBox(height: 6),
                Text(
                  'Verifying Auth & Role Credentials...',
                  style: AppTextStyles.bodySm().copyWith(fontSize: 11),
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
