import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/animated_sidebar.dart';
import '../../core/widgets/top_bar.dart';
import '../dashboard/dashboard_screen.dart';
import '../movies/movies_screen.dart';
import '../series/series_screen.dart';
import '../banners/banners_screen.dart';
import '../categories/categories_screen.dart';
import '../users/users_screen.dart';
import '../notifications/notifications_screen.dart';
import '../analytics/analytics_screen.dart';
import '../storage/storage_screen.dart';
import '../audit/audit_screen.dart';
import '../remote_config/remote_config_screen.dart';
import '../release_center/release_center_screen.dart';

/// Admin Shell — Ether Cinema Admin Panel
/// Main layout: floating sidebar + top bar + animated content area
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _sidebarCollapsed = false;

  late AnimationController _pageCtrl;
  late Animation<double> _pageFade;
  late Animation<Offset> _pageSlide;

  static const _pages = [
    DashboardScreen(),
    MoviesScreen(),
    SeriesScreen(),
    BannersScreen(),
    CategoriesScreen(),
    UsersScreen(),
    NotificationsScreen(),
    AnalyticsScreen(),
    StorageScreen(),
    AuditScreen(),
    RemoteConfigScreen(),
    ReleaseCenterScreen(),
  ];

  static final _pageTitles = [
    ('Dashboard', 'Welcome back, Super Admin 👋'),
    ('Movies', 'Manage your film library'),
    ('Series', 'TV series & episodes'),
    ('Banners', 'Hero banner management'),
    ('Categories', 'Content organization'),
    ('Users & Auth', 'User management & authentication'),
    ('Notifications', 'FCM push notification center'),
    ('Analytics', 'Performance insights'),
    ('Storage', 'Supabase Storage explorer'),
    ('Audit Logs', 'System activity timeline'),
    ('Remote Config', 'Live configuration editor'),
    ('Release Center', 'Continuous deployment & audit readiness'),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _pageFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOut),
    );
    _pageSlide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageCtrl, curve: Curves.easeOutCubic));
    _pageCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _selectPage(int index) {
    if (index == _selectedIndex) return;
    _pageCtrl.reverse().then((_) {
      setState(() => _selectedIndex = index);
      _pageCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = _pageTitles[_selectedIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Row(
          children: [
            // Floating glass sidebar
            AnimatedSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: _selectPage,
              isCollapsed: _sidebarCollapsed,
              onToggleCollapse: () =>
                  setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            ),
            // Main content area
            Expanded(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 12, 0),
                    child: TopBar(
                      pageTitle: title,
                      pageSubtitle: subtitle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Page content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 12, 12),
                      child: FadeTransition(
                        opacity: _pageFade,
                        child: SlideTransition(
                          position: _pageSlide,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _pages[_selectedIndex],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
