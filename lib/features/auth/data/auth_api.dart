import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../models/auth_user.dart';

/// Erro de API com a mensagem que o backend devolve em `{ message }`.
/// Aula: no Dart lançamos exceções com `throw`; aqui criamos uma classe de
/// exceção própria pra carregar a mensagem amigável até a UI.
class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

/// Cliente dos endpoints de autenticação — espelha o `authApi` do web
/// (mfe-auth/src/lib/auth-api.ts), trocando `fetch` pelo pacote `http`.
class AuthApi {
  final http.Client _client;
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  static const _headers = {'Content-Type': 'application/json'};

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _post('/auth/login', {'email': email, 'password': password});
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  /// POST genérico que decodifica `{ user, token }` ou lança [ApiException].
  Future<AuthResponse> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');

    final res = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode(body), // = JSON.stringify
    );

    final data = res.body.isNotEmpty
        ? jsonDecode(res.body) as Map<String, dynamic> // = JSON.parse
        : <String, dynamic>{};

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return AuthResponse.fromJson(data);
    }

    // Backend devolve `{ message }` nos erros (400/401/409).
    final message = (data['message'] as String?) ?? 'Erro inesperado.';
    throw ApiException(message, res.statusCode);
  }
}
