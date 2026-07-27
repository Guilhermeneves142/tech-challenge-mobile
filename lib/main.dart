import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO(fase3): inicializar Firebase aqui após `flutterfire configure`.
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FinanceApp());
}
