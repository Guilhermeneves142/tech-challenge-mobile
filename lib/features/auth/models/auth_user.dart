import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

/// Modelo do usuário autenticado.
///
/// Aula: no Firebase o identificador do usuário é o `uid` (uma string),
/// diferente do `id` numérico que um backend próprio costuma usar. E-mail e
/// senha ficam só no Firebase Auth; o resto do "perfil" (nome, iniciais,
/// plano) mora num documento à parte no Firestore, na coleção `users`.
class AuthUser {
  final String uid;
  final String name;
  final String email;
  final String initials;
  final String plan;

  const AuthUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.initials,
    required this.plan,
  });

  /// Combina o usuário do Firebase Auth (`fbUser`) com o perfil salvo no
  /// Firestore (`profile`, o `Map` do documento em `users/<uid>`).
  factory AuthUser.fromFirebase(
    fb_auth.User fbUser,
    Map<String, dynamic>? profile,
  ) {
    final name = (profile?['name'] as String?) ??
        fbUser.displayName ??
        fbUser.email?.split('@').first ??
        'Usuário';

    return AuthUser(
      uid: fbUser.uid,
      name: name,
      email: (profile?['email'] as String?) ?? fbUser.email ?? '',
      initials: (profile?['initials'] as String?) ?? _initialsOf(name),
      plan: (profile?['plan'] as String?) ?? 'Plano Grátis',
    );
  }

  static String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.map((p) => p[0]).take(2).join().toUpperCase();
  }
}
