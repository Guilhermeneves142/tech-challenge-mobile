import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'features/auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // O AuthProvider já restaura a sessão salva no construtor (loadSession).
  // Enquanto isso, o router mostra a Splash (status = unknown).
  final authProvider = AuthProvider();

  runApp(FinanceApp(authProvider: authProvider));
}
