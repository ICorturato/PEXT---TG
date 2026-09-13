import 'package:flutter_test/flutter_test.dart';
import 'package:pext/main.dart';

void main() {
  testWidgets('renders the PEXT login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PextApp());

    expect(find.text('ENTRAR'), findsOneWidget);
    expect(find.text('CPF'), findsOneWidget);
  });
}
