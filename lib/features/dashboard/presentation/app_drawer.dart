import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

/// Um item do menu lateral — espelha `menuItems` do `sideBar.tsx` do web.
class _MenuItem {
  const _MenuItem({
    required this.label,
    required this.route,
    required this.icon,
    this.enabled = true,
  });

  final String label;
  final String route;
  final IconData icon;
  final bool enabled;
}

const _menuItems = [
  _MenuItem(label: 'Dashboard', route: '/', icon: Icons.dashboard_rounded),
  _MenuItem(
    label: 'Transações',
    route: '/transacoes',
    icon: Icons.receipt_long_rounded,
  ),
  _MenuItem(
    label: 'Planejamento',
    route: '/planejamento',
    icon: Icons.donut_large_rounded,
    enabled: false,
  ),
  _MenuItem(
    label: 'Perfil',
    route: '/perfil',
    icon: Icons.person_rounded,
    enabled: false,
  ),
];

/// Menu lateral: mesma estrutura do Sidebar web — logo, itens de navegação
/// (com os "em breve" bloqueados) e a caixa do usuário com logout.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: AppColors.brandTertiary,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerLogo(theme: theme),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final item in _menuItems)
                    _DrawerMenuTile(
                      item: item,
                      selected: currentLocation == item.route,
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white24),
            const _UserBox(),
          ],
        ),
      ),
    );
  }
}

class _DrawerLogo extends StatelessWidget {
  const _DrawerLogo({required this.theme});

  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'FinanceApp',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuTile extends StatelessWidget {
  const _DrawerMenuTile({required this.item, required this.selected});

  final _MenuItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    if (!item.enabled) {
      return Tooltip(
        message: 'Disponível em breve',
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(item.icon, size: 20, color: Colors.white38),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(color: Colors.white38, fontSize: 16),
                ),
              ),
              const Icon(Icons.lock_outline, size: 16, color: Colors.white38),
            ],
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.of(context).pop(); // fecha o drawer
          if (!selected) context.go(item.route);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.secondary : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20,
                color: selected
                    ? theme.colorScheme.secondaryForeground
                    : Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: TextStyle(
                  color: selected
                      ? theme.colorScheme.secondaryForeground
                      : Colors.white,
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar + nome + plano + botão de sair, no rodapé do menu.
class _UserBox extends StatelessWidget {
  const _UserBox();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Text(
              user?.initials ?? '?',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?.name ?? 'Usuário',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  user?.plan ?? 'Plano Grátis',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  /// Mesmo fluxo do web: modal "Deseja sair?" antes de efetivar o logout.
  Future<void> _confirmLogout(BuildContext context) async {
    final auth = context.read<AuthProvider>();

    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Deseja sair?'),
        description: const Text(
          'Você será redirecionado para a tela de login.',
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ShadButton.destructive(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (context.mounted) Navigator.of(context).pop(); // fecha o drawer
      await auth.signOut();
    }
  }
}
