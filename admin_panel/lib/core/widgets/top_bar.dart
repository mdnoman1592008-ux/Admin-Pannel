import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'status_badge.dart';

/// Premium Top Bar — Ether Cinema Admin Panel
/// Search, notifications, system health, admin avatar, workspace switcher
class TopBar extends StatefulWidget {
  const TopBar({
    super.key,
    required this.pageTitle,
    required this.pageSubtitle,
    this.actions,
  });

  final String pageTitle;
  final String pageSubtitle;
  final List<Widget>? actions;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  bool _showNotifs = false;
  int _notifCount = 3;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.glass,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              // Page title
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.pageTitle, style: AppTextStyles.h3()),
                  Text(widget.pageSubtitle,
                      style: AppTextStyles.bodySm().copyWith(fontSize: 11)),
                ],
              ),
              const Spacer(),
              // Search bar
              _SearchBar(),
              const SizedBox(width: 12),
              // Extra actions
              if (widget.actions != null) ...[
                ...widget.actions!,
                const SizedBox(width: 12),
              ],
              // System health dots
              _SystemHealthIndicator(),
              const SizedBox(width: 16),
              // Notification bell
              _NotificationButton(
                count: _notifCount,
                onTap: () => setState(() => _showNotifs = !_showNotifs),
              ),
              const SizedBox(width: 12),
              // Admin avatar
              _AdminAvatar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _focused ? 280 : 220,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focused
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.glassBorder,
          width: _focused ? 1.5 : 1,
        ),
        boxShadow: _focused
            ? [AppColors.glowCyan(blur: 12, opacity: 0.15)]
            : null,
      ),
      child: TextField(
        onTap: () => setState(() => _focused = true),
        onTapOutside: (_) => setState(() => _focused = false),
        style: AppTextStyles.body().copyWith(fontSize: 13),
        decoration: InputDecoration(
          hintText: _focused ? 'Search movies, users, categories...' : 'Search...',
          hintStyle: AppTextStyles.body().copyWith(
              fontSize: 13, color: AppColors.textMuted),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 16,
            color: _focused ? AppColors.primary : AppColors.textMuted,
          ),
          suffixIcon: _focused
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('⌘K',
                        style: AppTextStyles.monoSm()
                            .copyWith(color: AppColors.textMuted)),
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          isDense: true,
        ),
      ),
    );
  }
}

class _SystemHealthIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Firebase: OK | Supabase: OK | FCM: OK',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.success.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                boxShadow: [AppColors.glowMint(blur: 8, opacity: 0.8)],
              ),
            ),
            const SizedBox(width: 6),
            Text('All Systems',
                style: AppTextStyles.labelLg().copyWith(
                    color: AppColors.success, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.glass,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              size: 18,
              color: AppColors.textSecond,
            ),
          ),
          if (count > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger.withOpacity(0.5),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    '$count',
                    style: AppTextStyles.badge().copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AdminAvatar extends StatefulWidget {
  @override
  State<_AdminAvatar> createState() => _AdminAvatarState();
}

class _AdminAvatarState extends State<_AdminAvatar> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.glassHover : AppColors.glass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_rounded,
                  color: Colors.black, size: 16),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Super Admin',
                    style: AppTextStyles.h4().copyWith(fontSize: 11)),
                Text('Online',
                    style: AppTextStyles.bodySm().copyWith(
                        color: AppColors.success,
                        fontSize: 9,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
