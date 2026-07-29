import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finance_app_mobile/app.dart';
import 'package:finance_app_mobile/features/auth/providers/auth_provider.dart';

void main() {
  testWidgets('Mostra a Splash e depois cai no login sem sessão',
      (tester) async {
    // Sem token salvo -> após a splash, o redirect leva para /login.
    SharedPreferences.setMockInitialValues({});
    final auth = AuthProvider(); // já dispara loadSession()

    await tester.pumpWidget(FinanceApp(authProvider: auth));
    await tester.pump(const Duration(milliseconds: 200)); // deixa a Splash montar

    expect(find.text('FinanceApp'), findsWidgets); // splash visível

    // Avança o tempo além do mínimo da splash (1400ms) e deixa o redirect agir.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Entrar'), findsWidgets);
    expect(find.text('Não tem uma conta?'), findsOneWidget);
  });
}
