import 'package:flutter/material.dart';
import '../../core/auth/admin_auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/status_badge.dart';

/// Live Users Screen — Display real Firebase authenticated user profiles
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _authService = AdminAuthService.instance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authService,
      builder: (context, _) {
        final currentUser = _authService.state.user;

        return Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildToolbar(),
              const SizedBox(height: 16),
              _buildStats(currentUser),
              const SizedBox(height: 16),
              Expanded(child: _buildTable(currentUser)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolbar() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.people_alt_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Text('Live Firebase Authentication User Directory', style: AppTextStyles.h3()),
          const Spacer(),
          StatusBadge(label: 'Firebase Auth Connected', color: AppColors.success),
        ],
      ),
    );
  }

  Widget _buildStats(AdminUser? currentUser) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            borderColor: AppColors.primary.withOpacity(0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Authenticated Session', style: AppTextStyles.labelLg()),
                const SizedBox(height: 4),
                Text(currentUser != null ? '1 Active' : '0 Active',
                    style: AppTextStyles.h2().copyWith(color: AppColors.primary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            borderColor: AppColors.gold.withOpacity(0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Role', style: AppTextStyles.labelLg()),
                const SizedBox(height: 4),
                Text(currentUser?.role.toValue() ?? 'unauthenticated',
                    style: AppTextStyles.h2().copyWith(color: AppColors.gold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(AdminUser? currentUser) {
    if (currentUser == null) {
      return GlassCard(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off_rounded, color: AppColors.textMuted, size: 48),
              const SizedBox(height: 16),
              Text('No active Firebase user session available', style: AppTextStyles.h3()),
              const SizedBox(height: 8),
              Text('Log in via Firebase Authentication to view live user profile data.',
                  style: AppTextStyles.bodySm()),
            ],
          ),
        ),
      );
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildHeader(),
          Container(height: 1, color: AppColors.glassBorder),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      currentUser.displayName.isNotEmpty
                          ? currentUser.displayName[0].toUpperCase()
                          : 'A',
                      style: AppTextStyles.h4().copyWith(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentUser.displayName,
                          style: AppTextStyles.tableCell().copyWith(fontWeight: FontWeight.w600)),
                      Text(currentUser.email, style: AppTextStyles.bodySm()),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: StatusBadge(
                    label: currentUser.role.toValue(),
                    color: currentUser.role == AdminRole.superAdmin ? AppColors.gold : AppColors.secondary,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: StatusBadge.email(),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    currentUser.lastLoginAt.toIso8601String().substring(0, 10),
                    style: AppTextStyles.tableCell(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 48),
          Expanded(flex: 3, child: Text('USER', style: AppTextStyles.tableHeader())),
          Expanded(flex: 2, child: Text('ROLE', style: AppTextStyles.tableHeader())),
          Expanded(flex: 2, child: Text('PROVIDER', style: AppTextStyles.tableHeader())),
          Expanded(flex: 2, child: Text('LAST LOGIN', style: AppTextStyles.tableHeader())),
        ],
      ),
    );
  }
}
