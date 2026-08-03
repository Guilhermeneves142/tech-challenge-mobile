import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/transactions/providers/transactions_provider.dart';

/// Widget raiz da aplicação.
///
/// É StatefulWidget para criar o [GoRouter] UMA vez (em initState) — recriar o
/// router a cada rebuild perderia o histórico de navegação.
class FinanceApp extends StatefulWidget {
  const FinanceApp({super.key, required this.authProvider});

  final AuthProvider authProvider;

  @override
  State<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  late final GoRouter _router = AppRouter.create(widget.authProvider);

  @override
  void initState() {
    super.initState();
    // Só restaura a sessão DEPOIS do primeiro frame, para o contador mínimo da
    // Splash começar quando ela já está visível (senão o cold start "come" o
    // tempo e a splash pisca).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.authProvider.loadSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.authProvider),
        ChangeNotifierProvider(create: (_) => TransactionsProvider()),
      ],
      child: ShadApp.router(
        title: 'FinanceApp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: _router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('pt', 'BR')],
      ),
    );
  }
}
