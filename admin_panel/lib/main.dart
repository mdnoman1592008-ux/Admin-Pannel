import 'dart:ui';
import 'package:flutter/material.dart';
import 'core/auth/auth_gateway.dart';
import 'core/supabase_initializer.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseInitializer.initialize();
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
