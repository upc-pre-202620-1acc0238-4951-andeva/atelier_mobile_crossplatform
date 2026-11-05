import 'package:atelier_mobile_crossplatform/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la app abre con los textos en español', (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(find.text('Atelier'), findsOneWidget);
  });
}
