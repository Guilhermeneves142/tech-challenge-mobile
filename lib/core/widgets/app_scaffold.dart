import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../features/dashboard/presentation/app_drawer.dart';

/// Casca compartilhada por toda a área logada: AppBar verde + Drawer (menu
/// lateral). Cada tela só precisa fornecer o [title] e o [body].
class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.title, required this.body});

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.primaryForeground,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: body,
    );
  }
}
