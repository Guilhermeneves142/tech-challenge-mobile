/// Modelo do usuário autenticado — espelha a `interface AuthUser` do web
/// (mfe-auth/src/lib/auth-api.ts).
///
/// Aula (JS -> Dart): no JS o `res.json()` já vira um objeto tipado pela
/// interface. No Dart o JSON decodado é um `Map<String, dynamic>` (objeto
/// genérico), então criamos uma classe com um construtor `fromJson` que faz o
/// "parse", e um `toJson` pra gravar de volta (ex.: no armazenamento local).
class AuthUser {
  final int id;
  final String name;
  final String email;
  final String initials;
  final String plan;
  final String? avatar; // pode ser null -> tipo anulável com `?`

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.initials,
    required this.plan,
    this.avatar,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        initials: (json['initials'] as String?) ?? '',
        plan: (json['plan'] as String?) ?? '',
        avatar: json['avatar'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'initials': initials,
        'plan': plan,
        'avatar': avatar,
      };
}

/// Resposta dos endpoints /auth/login e /auth/register: `{ user, token }`.
class AuthResponse {
  final AuthUser user;
  final String token;

  const AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
        token: json['token'] as String,
      );
}
