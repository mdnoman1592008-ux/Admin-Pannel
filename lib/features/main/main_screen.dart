import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/movie.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_bottom_nav_bar.dart';
import '../home/home_screen.dart';
import '../categories/categories_screen.dart';
import '../downloads/downloads_screen.dart';
import '../settings/settings_screen.dart';
import '../movie_details/movie_details_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  Movie? _selectedMovie;
  DateTime? _lastBackPressTime;

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

  bool _handlePop() {
    if (_selectedMovie != null) {
      setState(() {
        _selectedMovie = null;
      });
      return false;
    }

    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }

    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Press back again to exit Ether Cinema',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF00CFFF),
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final shouldExit = _handlePop();
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: _selectedMovie != null
          ? MovieDetailsScreen(
              movie: _selectedMovie!,
              onBack: _onBackFromDetails,
              onSelectMovie: _onSelectMovie,
            )
          : Scaffold(
              backgroundColor: AppColors.background,
              body: Stack(
                children: [
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
                  IndexedStack(
                    index: _currentIndex,
                    children: [
                      HomeScreen(onSelectMovie: _onSelectMovie),
                      const CategoriesScreen(),
                      const DownloadsScreen(),
                      const SettingsScreen(),
                    ],
                  ),
                ],
              ),
              bottomNavigationBar: CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                    _selectedMovie = null;
                  });
                },
              ),
            ),
    );
  }
}
