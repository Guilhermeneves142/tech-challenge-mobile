import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'app_scaffold.dart';

/// Placeholder para telas que ainda serão implementadas (ex.: Transações,
/// que fica a cargo de outra pessoa da equipe) — espelha o
/// `underConstruction.tsx` do web.
class UnderConstructionScreen extends StatelessWidget {
  const UnderConstructionScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return AppScaffold(
      title: title,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ShadCard(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.construction_rounded,
                    size: 40,
                    color: theme.colorScheme.secondaryForeground,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Em breve', style: theme.textTheme.h4),
                const SizedBox(height: 8),
                Text(
                  'Essa funcionalidade ainda está sendo desenvolvida. '
                  'Volte em breve para conferir as novidades.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.muted,
                ),
                const SizedBox(height: 24),
                ShadButton.outline(
                  onPressed: () => context.go('/'),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, size: 16),
                      SizedBox(width: 8),
                      Text('Voltar'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
