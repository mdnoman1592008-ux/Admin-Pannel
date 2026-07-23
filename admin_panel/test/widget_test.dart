import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema_admin_panel/main.dart';
import 'package:ether_cinema_admin_panel/core/auth/admin_auth_service.dart';
import 'package:ether_cinema_admin_panel/features/auth/login_screen.dart';

void main() {
  testWidgets('EtherAdminApp loads AuthGateway and LoginScreen by default', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    AdminAuthService.instance.setAuthStateForTesting(AdminAuthState.unauthenticated());

    await tester.pumpWidget(const EtherAdminApp());
    await tester.pump();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
