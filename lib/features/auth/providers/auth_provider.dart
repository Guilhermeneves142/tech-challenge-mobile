import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';

import '../models/auth_user.dart';

/// Estados possíveis da autenticação.
/// `unknown` = ainda restaurando a sessão salva (mostra a Splash).
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Estado global de autenticação (Provider — exigência da Fase 03).
///
/// Aula (JS -> Dart): pense no `ChangeNotifier` como um "store" (tipo Zustand)
/// ou um Context com estado. Quando algo muda, chamamos `notifyListeners()`
/// e todo widget que "assiste" esse provider re-renderiza.
///
/// Agora tudo roda no Firebase:
/// - `firebase_auth` cuida de login/cadastro/sessão (troca o backend próprio).
/// - `cloud_firestore` guarda o "perfil" do usuário (nome, iniciais etc.),
///   já que o Firebase Auth por si só só conhece e-mail/senha/uid.
class AuthProvider extends ChangeNotifier {
  AuthProvider({fb_auth.FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? fb_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _startedAt = DateTime.now() {
    // authStateChanges é um Stream (~ um Observable): emite sempre que o
    // usuário loga/desloga, inclusive na abertura do app (sessão restaurada
    // automaticamente pelo SDK do Firebase — não precisamos de shared_prefs).
    _auth.authStateChanges().listen(_onAuthChanged);
  }

  final fb_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final DateTime _startedAt;

  // Tempo mínimo de exibição da Splash (só na 1ª resolução do auth state,
  // que com o Firebase costuma vir quase instantânea — sem isso ela pisca).
  static const _minSplash = Duration(milliseconds: 3200);

  AuthStatus _status = AuthStatus.unknown;
  AuthUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<void> _onAuthChanged(fb_auth.User? fbUser) async {
    // Só na 1ª resolução (saindo de `unknown`) garantimos o tempo mínimo de
    // Splash. Trocas depois disso (logout/login manual) ficam instantâneas.
    if (_status == AuthStatus.unknown) {
      final remaining = _minSplash - DateTime.now().difference(_startedAt);
      if (remaining > Duration.zero) await Future.delayed(remaining);
    }

    if (fbUser == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    // Busca o "perfil" (nome, iniciais, plano) salvo no Firestore.
    // Aula: sem este try/catch, um erro aqui (rede, regras de segurança)
    // travaria o app na Splash para sempre — a exceção nunca chegaria em
    // lugar nenhum, porque `_onAuthChanged` roda dentro do listener do
    // Stream, sem ninguém "escutando" um possível erro. Por isso tratamos
    // explicitamente e caímos para deslogado com uma mensagem de erro.
    try {
      final doc = await _usersCollection.doc(fbUser.uid).get();
      _user = AuthUser.fromFirebase(fbUser, doc.data());
      _status = AuthStatus.authenticated;
    } catch (_) {
      _errorMessage = 'Não foi possível carregar seu perfil. Tente novamente.';
      _status = AuthStatus.unauthenticated;
      await _auth.signOut();
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) {
    return _run(() async {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final fbUser = credential.user!;
      await fbUser.updateDisplayName(name.trim());

      // Salva o perfil (nome + iniciais) no Firestore, indexado pelo uid.
      await _usersCollection.doc(fbUser.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'initials': _initialsOf(name),
        'plan': 'Plano Grátis',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> signOut() => _auth.signOut();
  // _onAuthChanged cuida do resto (status/user) automaticamente.

  /// Executa uma ação de auth cuidando de loading/erro.
  /// Retorna `true` no sucesso (a tela usa isso pra navegar).
  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      _errorMessage = _friendlyMessage(e.code);
      return false;
    } catch (_) {
      _errorMessage = 'Não foi possível conectar. Tente novamente.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Traduz os códigos de erro do Firebase Auth para mensagens amigáveis.
  String _friendlyMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha inválidos.';
      case 'email-already-in-use':
        return 'E-mail já cadastrado.';
      case 'weak-password':
        return 'Senha muito fraca (mínimo 6 caracteres).';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      default:
        return 'Não foi possível concluir. Tente novamente.';
    }
  }

  String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    final letters = parts.map((p) => p[0]).take(2).join();
    return letters.toUpperCase();
  }

  /// Limpa a mensagem de erro (ex.: ao sair da tela ou reeditar campos).
  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }
}
