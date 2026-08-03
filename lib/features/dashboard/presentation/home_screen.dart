import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../auth/providers/auth_provider.dart';

/// Tela principal (área logada). Por enquanto mostra as boas-vindas e o menu
/// lateral com logout. O Dashboard real (gráficos/análises) entra depois.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('FinanceApp'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.primaryForeground,
        elevation: 0,
      ),
      drawer: const _AppDrawer(),
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

/// Menu lateral: cabeçalho com o usuário + botão de sair.
class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final user = context.watch<AuthProvider>().user;

    return Drawer(
      backgroundColor: theme.colorScheme.card,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho com avatar (iniciais), nome e e-mail.
            Container(
              padding: const EdgeInsets.all(20),
              color: theme.colorScheme.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primaryForeground,
                    child: Text(
                      user?.initials ?? '?',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? '',
                    style: TextStyle(
                      color: theme.colorScheme.primaryForeground,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      color: theme.colorScheme.primaryForeground
                          .withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: Icon(
                Icons.receipt_long_outlined,
                color: theme.colorScheme.foreground,
              ),
              title: Text(
                'Transações',
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                context.push('/transacoes');
              },
            ),

            const Spacer(),

            // Botão de logout no rodapé do menu.
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ShadButton.destructive(
                  onPressed: () {
                    Navigator.of(context).pop(); // fecha o drawer
                    // signOut() muda o status -> o redirect leva ao /login.
                    context.read<AuthProvider>().signOut();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout, size: 18),
                      SizedBox(width: 8),
                      Text('Sair'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
