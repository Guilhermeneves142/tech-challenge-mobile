import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finance_app_mobile/app.dart';
import 'package:finance_app_mobile/features/auth/providers/auth_provider.dart';

void main() {
  testWidgets('Mostra a Splash e depois cai no login sem sessão',
      (tester) async {
    // MockFirebaseAuth sem `signedIn`/`mockUser` = ninguém logado -> depois
    // da splash o redirect deve levar para /login.
    final auth = AuthProvider(
      auth: MockFirebaseAuth(),
      firestore: FakeFirebaseFirestore(),
    );

    await tester.pumpWidget(FinanceApp(authProvider: auth));
    await tester.pump(const Duration(milliseconds: 200)); // deixa a Splash montar

    expect(find.text('FinanceApp'), findsWidgets); // splash visível

    // Avança além do mínimo da splash (3200ms) e deixa o redirect agir.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();

    expect(find.text('Entrar'), findsWidgets);
    expect(find.text('Não tem uma conta?'), findsOneWidget);
  });
}
