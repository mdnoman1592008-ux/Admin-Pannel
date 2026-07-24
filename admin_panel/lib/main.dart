import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/backend/backend_service.dart';
import 'core/auth/auth_gateway.dart';
import 'core/supabase_initializer.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: AdminFirebaseOptions.currentPlatform);
  await SupabaseInitializer.initialize();
  await LiveBackendService.instance.start();
  runApp(const EtherAdminApp());
}

class EtherAdminApp extends StatelessWidget {
  const EtherAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ether Cinema — Enterprise Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AuthGateway(),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: _SmoothScrollBehavior(),
          child: child!,
        );
      },
    );
  }
}

/// Smooth scroll behavior for web (enables mouse drag scrolling)
class _SmoothScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
      };
}
