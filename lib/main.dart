import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/environment_config.dart';
import 'core/logging/app_logger.dart';
import 'core/supabase/supabase_initializer.dart';
import 'core/theme/app_theme.dart';
import 'features/main/main_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/recommendation_preferences/recommendation_preferences_screen.dart';
import 'features/profile/avatar_selection/avatar_selection_screen.dart';
import 'features/profile/profile_selection/profile_selection_screen.dart';
import 'features/splash/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'core/notifications/notification_service.dart';
import 'core/di/riverpod_providers.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  EnvironmentConfig.setEnvironment(Environment.prod);
  await Future.wait([
    NotificationService.initialize(),
    SupabaseInitializer.initialize(),
  ]);
  AppLogger.i('AppInit', 'Ether Cinema Enterprise & Supabase initialized in PROD environment.');

  runApp(const ProviderScope(child: EtherCinemaApp()));
}

class EtherCinemaApp extends ConsumerStatefulWidget {
  const EtherCinemaApp({super.key});

  @override
  ConsumerState<EtherCinemaApp> createState() => _EtherCinemaAppState();
}

class _EtherCinemaAppState extends ConsumerState<EtherCinemaApp> {
  bool _showSplash = true;

  void _finishSplash() {
    setState(() {
      _showSplash = false;
    });
  }

  Widget _buildHomeWidget(user) {
    if (user == null) {
      return const OnboardingScreen();
    }

    if (!user.hasCompletedOnboarding) {
      return const AvatarSelectionScreen();
    }

    if (!user.preferencesCompleted) {
      return const RecommendationPreferencesScreen();
    }

    if (user.profiles.length > 1) {
      return const ProfileSelectionScreen();
    }

    return const MainScreen();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          title: 'Ether Cinema Enterprise',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          home: _showSplash
              ? SplashScreen(onFinishSplash: _finishSplash)
              : authState.when(
                  data: _buildHomeWidget,
                  loading: () => const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const OnboardingScreen(),
                ),
        );
      }
    );
  }
}
