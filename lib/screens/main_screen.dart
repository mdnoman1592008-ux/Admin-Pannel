import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'categories_screen.dart';
import 'downloads_screen.dart';
import 'settings_screen.dart';
import 'movie_details_screen.dart';
import 'admin_dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  Movie? _selectedMovie;
  bool _showAdminDashboard = false;

  void _onSelectMovie(Movie movie) {
    setState(() {
      _selectedMovie = movie;
    });
  }

  void _onBackFromDetails() {
    setState(() {
      _selectedMovie = null;
    });
  }

  void _toggleAdminDashboard(bool open) {
    setState(() {
      _showAdminDashboard = open;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showAdminDashboard) {
      return AdminDashboardScreen(
        onClose: () => _toggleAdminDashboard(false),
      );
    }

    if (_selectedMovie != null) {
      return MovieDetailsScreen(
        movie: _selectedMovie!,
        onBack: _onBackFromDetails,
        onSelectMovie: _onSelectMovie,
      );
    }

    final pages = [
      HomeScreen(
        onSelectMovie: _onSelectMovie,
        onOpenAdmin: () => _toggleAdminDashboard(true),
      ),
      SearchScreen(onSelectMovie: _onSelectMovie),
      const CategoriesScreen(),
      const DownloadsScreen(),
      SettingsScreen(
        onOpenAdmin: () => _toggleAdminDashboard(true),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background ambient light leaks
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.glassGlowBlue,
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.glassGlowPurple,
              ),
            ),
          ),

          // IndexedStack for persistent navigation
          IndexedStack(
            index: _currentIndex,
            children: pages,
          ),

          // Floating Glass Bottom Nav Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
