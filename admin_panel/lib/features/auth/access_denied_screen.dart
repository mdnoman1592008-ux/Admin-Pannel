import 'package:flutter/material.dart';
import '../../core/auth/admin_auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glow_button.dart';
import '../../core/widgets/status_badge.dart';

/// Access Denied Screen — Displayed when user role is not 'admin' or 'super_admin'
class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({
    super.key,
    required this.user,
    this.reason,
  });

  final AdminUser user;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: GlassCard(
              width: 460,
              padding: const EdgeInsets.all(36),
              glowColor: AppColors.danger,
              glowBlur: 40,
              borderColor: AppColors.danger.withOpacity(0.3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Shield icon with glow
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.danger.withOpacity(0.4), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.danger.withOpacity(0.35),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.gpp_bad_rounded,
                      color: AppColors.danger,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Access Denied 🚫',
                    style: AppTextStyles.h1().copyWith(color: AppColors.danger),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unauthorized Administrative Privileges',
                    style: AppTextStyles.bodySm().copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  // User info container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.textMuted.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  user.displayName.isNotEmpty
                                      ? user.displayName[0].toUpperCase()
                                      : 'U',
                                  style: AppTextStyles.h4().copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.displayName,
                                    style: AppTextStyles.h4().copyWith(fontSize: 13),
                                  ),
                                  Text(
                                    user.email,
                                    style: AppTextStyles.bodySm().copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge(
                              label: user.role.toValue(),
                              color: AppColors.danger,
                              icon: Icons.lock_outline_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(height: 1, color: AppColors.glassBorder),
                        const SizedBox(height: 12),
                        Text(
                          reason ??
                              'Your account does not possess administrator rights. Contact your system administrator to request privileges.',
                          style: AppTextStyles.bodySm().copyWith(
                            color: AppColors.textSecond,
                            fontSize: 12,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  GlowButton(
                    label: 'Sign Out & Return to Login',
                    icon: Icons.logout_rounded,
                    color: AppColors.danger,
                    textColor: Colors.white,
                    fullWidth: true,
                    onPressed: () {
                      AdminAuthService.instance.signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
