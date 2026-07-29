import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/models/auth_user.dart';

/// Persistência do login — equivalente mobile do `auth-storage.ts` do web.
///
/// Aula: no navegador é `localStorage`. No mobile usamos `shared_preferences`
/// (key-value assíncrono do dispositivo). Para um token "de verdade" o ideal
/// seria `flutter_secure_storage` (criptografado); aqui mantemos paridade com
/// o web e simplicidade.
class AuthStorage {
  static const _tokenKey = 'finance-app-token';
  static const _userKey = 'finance-app-user';

  Future<void> save(String token, AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<AuthUser?> readUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
