import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Floating Glass Sidebar — Ether Cinema Admin Panel
/// Collapsible, animated, premium glassmorphism sidebar
class AnimatedSidebar extends StatefulWidget {
  const AnimatedSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  @override
  State<AnimatedSidebar> createState() => _AnimatedSidebarState();
}

class _AnimatedSidebarState extends State<AnimatedSidebar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _widthAnim;

  static const double _expandedWidth = 256.0;
  static const double _collapsedWidth = 72.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: widget.isCollapsed ? 0.0 : 1.0,
    );
    _widthAnim = Tween<double>(
      begin: _collapsedWidth,
      end: _expandedWidth,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(AnimatedSidebar old) {
    super.didUpdateWidget(old);
    if (widget.isCollapsed != old.isCollapsed) {
      widget.isCollapsed ? _ctrl.reverse() : _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widthAnim,
      builder: (_, __) => SizedBox(
        width: _widthAnim.value,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.glass,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.glassBorder),
                  boxShadow: [AppColors.softShadow()],
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 8),
                    _buildDivider(),
                    const SizedBox(height: 8),
                    Expanded(child: _buildNavItems()),
                    _buildDivider(),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 8, 8),
      child: Row(
        children: [
          // Logo icon with glow
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [AppColors.glowCyan(blur: 16, opacity: 0.5)],
            ),
            child: const Icon(Icons.play_circle_fill_rounded,
                color: Colors.black, size: 20),
          ),
          if (_widthAnim.value > 160) ...[
            const SizedBox(width: 10),
            Expanded(
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                    parent: _ctrl,
                    curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ether Cinema',
                        style: AppTextStyles.h4().copyWith(fontSize: 13)),
                    Text('Admin Portal',
                        style: AppTextStyles.bodySm().copyWith(fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
          GestureDetector(
            onTap: widget.onToggleCollapse,
            child: AnimatedRotation(
              turns: widget.isCollapsed ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 280),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textSecond,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: AppColors.glassBorder,
    );
  }

  Widget _buildNavItems() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      children: [
        _buildSectionLabel('Content'),
        _buildNavItem(0, Icons.dashboard_rounded, 'Dashboard'),
        _buildNavItem(1, Icons.movie_filter_rounded, 'Movies'),
        _buildNavItem(2, Icons.live_tv_rounded, 'Series'),
        _buildNavItem(3, Icons.view_carousel_rounded, 'Banners'),
        _buildNavItem(4, Icons.category_rounded, 'Categories'),
        const SizedBox(height: 8),
        _buildSectionLabel('Users'),
        _buildNavItem(5, Icons.people_alt_rounded, 'Users & Auth'),
        _buildNavItem(6, Icons.notifications_rounded, 'Notifications'),
        const SizedBox(height: 8),
        _buildSectionLabel('System'),
        _buildNavItem(7, Icons.bar_chart_rounded, 'Analytics'),
        _buildNavItem(8, Icons.cloud_upload_rounded, 'Storage'),
        _buildNavItem(9, Icons.history_rounded, 'Audit Logs'),
        _buildNavItem(10, Icons.tune_rounded, 'Remote Config'),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    if (widget.isCollapsed || _widthAnim.value < 160) {
      return const SizedBox(height: 12);
    }
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.labelCaps(),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = widget.selectedIndex == index;
    final collapsed = _widthAnim.value < 120;

    return _NavItem(
      icon: icon,
      label: label,
      isSelected: isSelected,
      collapsed: collapsed,
      onTap: () => widget.onItemSelected(index),
      animController: _ctrl,
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B61FF), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 16),
          ),
          if (_widthAnim.value > 140) ...[
            const SizedBox(width: 10),
            Expanded(
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                      parent: _ctrl,
                      curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Super Admin',
                        style: AppTextStyles.h4().copyWith(fontSize: 12)),
                    Text('admin@ethercinema.app',
                        style: AppTextStyles.bodySm().copyWith(fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.collapsed,
    required this.onTap,
    required this.animController,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool collapsed;
  final VoidCallback onTap;
  final AnimationController animController;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _hover;
  late Animation<double> _hoverAnim;

  @override
  void initState() {
    super.initState();
    _hover = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _hoverAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _hover, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hover.forward(),
      onExit: (_) => _hover.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _hoverAnim,
          builder: (_, __) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 1),
            padding: EdgeInsets.symmetric(
              horizontal: widget.collapsed ? 0 : 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppColors.primary.withOpacity(0.12)
                  : _hoverAnim.value > 0.1
                      ? AppColors.glass
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: widget.isSelected
                  ? Border.all(
                      color: AppColors.primary.withOpacity(0.2), width: 1)
                  : null,
            ),
            child: Row(
              mainAxisAlignment: widget.collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.isSelected)
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                          boxShadow: [
                            AppColors.glowCyan(blur: 12, opacity: 0.4)
                          ],
                        ),
                      ),
                    Icon(
                      widget.icon,
                      size: 18,
                      color: widget.isSelected
                          ? AppColors.primary
                          : AppColors.textSecond,
                    ),
                  ],
                ),
                if (!widget.collapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: widget.animController,
                          curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                        ),
                      ),
                      child: Text(
                        widget.label,
                        style: widget.isSelected
                            ? AppTextStyles.navItemActive()
                            : AppTextStyles.navItem(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (widget.isSelected)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [AppColors.glowCyan(blur: 8, opacity: 0.8)],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


