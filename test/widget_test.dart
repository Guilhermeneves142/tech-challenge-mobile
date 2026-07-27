import 'package:flutter_test/flutter_test.dart';

import 'package:finance_app_mobile/app.dart';

void main() {
  testWidgets('App inicia e renderiza a Home', (tester) async {
    await tester.pumpWidget(const FinanceApp());
    await tester.pumpAndSettle();

    expect(find.text('FinanceApp'), findsWidgets);
    expect(find.text('Botão primário'), findsOneWidget);
  });
}
