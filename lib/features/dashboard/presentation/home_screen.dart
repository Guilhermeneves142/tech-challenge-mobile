import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../auth/providers/auth_provider.dart';

/// Tela principal (área logada). O Dashboard real (gráficos/análises) fica a
/// cargo de outra pessoa da equipe — aqui só as boas-vindas + o menu/AppBar.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final user = context.watch<AuthProvider>().user;

    return AppScaffold(
      title: 'Dashboard',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 56,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Olá, ${user?.name ?? 'bem-vindo'} 👋',
                style: theme.textTheme.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Abra o menu no canto superior esquerdo.',
                style: theme.textTheme.muted,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
