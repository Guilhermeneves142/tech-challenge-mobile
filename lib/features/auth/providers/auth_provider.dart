import 'package:flutter/foundation.dart';

import '../../../core/storage/auth_storage.dart';
import '../data/auth_api.dart';
import '../models/auth_user.dart';

/// Estados possíveis da autenticação.
/// `unknown` = ainda restaurando a sessão salva (mostra a Splash).
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Estado global de autenticação (Provider — exigência da Fase 03).
///
/// Aula (JS -> Dart): pense no `ChangeNotifier` como um "store" (tipo Zustand)
/// ou um Context com estado. Quando algo muda, chamamos `notifyListeners()`
/// e todo widget que "assiste" esse provider re-renderiza.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthApi? api, AuthStorage? storage})
      : _api = api ?? AuthApi(),
        _storage = storage ?? AuthStorage();

  final AuthApi _api;
  final AuthStorage _storage;

  AuthStatus _status = AuthStatus.unknown;
  AuthUser? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  AuthUser? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Restaura a sessão salva no dispositivo. Mantém um tempo mínimo para a
  /// Splash aparecer de forma agradável (senão ela piscaria).
  Future<void> loadSession() async {
    final minSplash = Future<void>.delayed(const Duration(milliseconds: 1400));

    _token = await _storage.readToken();
    _user = await _storage.readUser();

    await minSplash;

    _status =
        _token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) {
    return _run(() => _api.login(email: email, password: password));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(
        () => _api.register(name: name, email: email, password: password));
  }

  Future<void> signOut() async {
    await _storage.clear();
    _user = null;
    _token = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Executa uma ação de auth cuidando de loading/erro/persistência.
  /// Retorna `true` no sucesso (a tela usa isso pra navegar).
  Future<bool> _run(Future<AuthResponse> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await action();
      _user = res.user;
      _token = res.token;
      _status = AuthStatus.authenticated;
      await _storage.save(res.token, res.user);
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message; // mensagem amigável vinda do backend
      return false;
    } catch (_) {
      _errorMessage = 'Não foi possível conectar. Tente novamente.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpa a mensagem de erro (ex.: ao sair da tela ou reeditar campos).
  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
