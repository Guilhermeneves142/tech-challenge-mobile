/// Modelo do usuário autenticado.
///
/// Adaptado para Firebase Auth.
/// O Firebase utiliza `uid` como identificador único (String),
/// diferente do backend antigo que usava `id` numérico.
class AuthUser {
  final String uid;
  final String name;
  final String email;
  final String initials;
  final String plan;
  final String? avatar;

  const AuthUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.initials,
    required this.plan,
    this.avatar,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        uid: json['uid'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        initials: (json['initials'] as String?) ?? '',
        plan: (json['plan'] as String?) ?? 'free',
        avatar: json['avatar'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'initials': initials,
        'plan': plan,
        'avatar': avatar,
      };
}


/// Resposta padronizada da autenticação.
///
/// Mantemos esse formato para não precisar mudar
/// todas as telas que já esperam:
/// user + token.
class AuthResponse {
  final AuthUser user;
  final String token;

  const AuthResponse({
    required this.user,
    required this.token,
  });
}