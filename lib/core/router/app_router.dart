import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/home_screen.dart';

/// Configuração de navegação (go_router).
///
/// Por enquanto expõe só a rota inicial. Rotas de auth, transações e
/// adicionar/editar serão adicionadas nas próximas etapas.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
