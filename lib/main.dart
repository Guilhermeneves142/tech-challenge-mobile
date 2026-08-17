import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'features/auth/providers/auth_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // O AuthProvider escuta authStateChanges() do Firebase Auth — a sessão é
  // restaurada automaticamente pelo SDK (não precisamos mais de shared_prefs).
  final authProvider = AuthProvider();

  runApp(FinanceApp(authProvider: authProvider));
}
