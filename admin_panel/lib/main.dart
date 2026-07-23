import 'dart:ui';
import 'package:flutter/material.dart';
import 'core/supabase_initializer.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/admin_shell.dart';

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
      title: 'Ether Cinema — Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const AdminShell(),
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
