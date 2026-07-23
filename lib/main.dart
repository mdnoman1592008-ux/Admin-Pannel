import 'package:flutter/material.dart';
import 'core/config/environment_config.dart';
import 'core/logging/app_logger.dart';
import 'core/supabase/supabase_initializer.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/main/main_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EnvironmentConfig.setEnvironment(Environment.prod);
  await SupabaseInitializer.initialize();
  AppLogger.i('AppInit', 'Ether Cinema Enterprise & Supabase initialized in PROD environment.');

  runApp(const EtherCinemaApp());
}

class EtherCinemaApp extends StatefulWidget {
  const EtherCinemaApp({super.key});

  @override
  State<EtherCinemaApp> createState() => _EtherCinemaAppState();
}

class _EtherCinemaAppState extends State<EtherCinemaApp> {
  bool _showSplash = true;

  void _finishSplash() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ether Cinema Enterprise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _showSplash
          ? SplashScreen(onFinishSplash: _finishSplash)
          : const MainScreen(),
    );
  }
}
