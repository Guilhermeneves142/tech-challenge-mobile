import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cadastro_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/presentation/home_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';

/// Configuração de navegação (go_router).
///
/// O `redirect` é o "guarda de rota". Enquanto a sessão está sendo restaurada
/// (`AuthStatus.unknown`) mostramos a Splash; depois mandamos para login ou
/// home. `refreshListenable` faz o router reavaliar o redirect sempre que o
/// auth muda.
class AppRouter {
  AppRouter._();

  static GoRouter create(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: auth,
      redirect: (context, state) {
        final loc = state.matchedLocation;

        // Ainda restaurando a sessão -> fica na Splash.
        if (auth.status == AuthStatus.unknown) {
          return loc == '/splash' ? null : '/splash';
        }

        final loggingIn = loc == '/login' || loc == '/cadastro';

        // Sessão resolvida: sai da Splash para o destino certo.
        if (loc == '/splash') return auth.isAuthenticated ? '/' : '/login';

        // Não logado tentando acessar área interna -> login.
        if (!auth.isAuthenticated && !loggingIn) return '/login';

        // Já logado tentando ver login/cadastro -> home.
        if (auth.isAuthenticated && loggingIn) return '/';

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/transacoes',
          name: 'transactions',
          builder: (context, state) => const TransactionsScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/cadastro',
          name: 'cadastro',
          builder: (context, state) => const CadastroScreen(),
        ),
      ],
    );
  }
}
