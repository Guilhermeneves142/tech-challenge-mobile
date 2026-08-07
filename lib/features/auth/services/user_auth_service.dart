import 'package:firebase_auth/firebase_auth.dart';

import '../models/auth_user.dart';

class AuthResponse {
  final AuthUser user;
  final String token;

  AuthResponse({required this.user, required this.token});
}

class UserAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<AuthResponse> userRegister({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);

    final firebaseUser = credential.user!;

    final token = await firebaseUser.getIdToken() ?? '';

    print('USUÁRIO CRIADO: ${firebaseUser.uid}');
    print('EMAIL: ${firebaseUser.email}');

    return AuthResponse(
      token: token,
      user: AuthUser(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        initials: name.split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
        plan: 'free',
      ),
    );
  }
}
