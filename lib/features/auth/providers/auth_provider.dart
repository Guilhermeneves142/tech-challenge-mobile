import 'package:flutter/foundation.dart';

/// Estado global de autenticação (Provider — exigido pela Fase 03).
///
/// Placeholder: a integração real com Firebase Auth entra nas próximas etapas.
class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;

  // TODO(fase3): integrar com FirebaseAuth (signIn/signOut/authStateChanges).
  void signInMock(String userId) {
    _userId = userId;
    _isAuthenticated = true;
    notifyListeners();
  }

  void signOut() {
    _userId = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
