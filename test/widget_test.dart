import 'package:flutter_test/flutter_test.dart';
import 'package:ether_cinema/main.dart';

void main() {
  testWidgets('EtherCinemaApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EtherCinemaApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(EtherCinemaApp), findsOneWidget);
  });
}
