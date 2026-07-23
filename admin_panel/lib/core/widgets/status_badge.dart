import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Status Badge — Ether Cinema Admin Panel
/// Role chips, provider badges, status chips, category tags
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.size = BadgeSize.medium,
  });

  final String label;
  final Color? color;
  final IconData? icon;
  final BadgeSize size;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    final fontSize = size == BadgeSize.small ? 10.0 : 11.0;
    final hPad = size == BadgeSize.small ? 7.0 : 9.0;
    final vPad = size == BadgeSize.small ? 3.0 : 4.0;
    final iconSize = size == BadgeSize.small ? 10.0 : 12.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: c),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.badge().copyWith(
              color: c,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // Preset factories
  factory StatusBadge.published() => const StatusBadge(
        label: 'Published',
        color: AppColors.success,
        icon: Icons.check_circle_outline_rounded,
      );

  factory StatusBadge.draft() => const StatusBadge(
        label: 'Draft',
        color: AppColors.warning,
        icon: Icons.edit_outlined,
      );

  factory StatusBadge.archived() => const StatusBadge(
        label: 'Archived',
        color: AppColors.textMuted,
        icon: Icons.archive_outlined,
      );

  factory StatusBadge.featured() => const StatusBadge(
        label: 'Featured',
        color: AppColors.gold,
        icon: Icons.star_rounded,
      );

  factory StatusBadge.facebook() => const StatusBadge(
        label: 'Facebook',
        color: AppColors.facebook,
        icon: Icons.facebook_rounded,
      );

  factory StatusBadge.google() => const StatusBadge(
        label: 'Google',
        color: AppColors.google,
        icon: Icons.g_mobiledata_rounded,
      );

  factory StatusBadge.email() => const StatusBadge(
        label: 'Email',
        color: AppColors.email,
        icon: Icons.email_outlined,
      );

  factory StatusBadge.admin() => StatusBadge(
        label: 'Admin',
        color: AppColors.secondary,
        icon: Icons.shield_rounded,
      );

  factory StatusBadge.superAdmin() => StatusBadge(
        label: 'Super Admin',
        color: AppColors.gold,
        icon: Icons.security_rounded,
      );

  factory StatusBadge.user() => const StatusBadge(
        label: 'User',
        color: AppColors.textMuted,
        icon: Icons.person_outline_rounded,
      );
}

enum BadgeSize { small, medium }

/// Toggle switch with label
class LabeledToggle extends StatelessWidget {
  const LabeledToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor ?? AppColors.primary,
      inactiveThumbColor: AppColors.textMuted,
      inactiveTrackColor: AppColors.glassBorder,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// Search input field
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    this.hint = 'Search...',
    this.controller,
    this.onChanged,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.body().copyWith(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body().copyWith(
              fontSize: 13, color: AppColors.textMuted),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 18,
            color: AppColors.textMuted,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          isDense: true,
        ),
      ),
    );
  }
}
