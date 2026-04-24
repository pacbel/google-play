import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_app/app.dart';

void main() {
  testWidgets('App smoke test — renders CryptoPage', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Crypto App'), findsOneWidget);
    expect(find.text('Criptografar'), findsWidgets);
    expect(find.text('Descriptografar'), findsWidgets);
  });
}
