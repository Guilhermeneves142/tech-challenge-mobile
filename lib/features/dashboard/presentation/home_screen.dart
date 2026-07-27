import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Tela inicial temporária — serve como showcase de que o design system
/// (shadcn_ui + tokens do finance-ui) está aplicado. Será substituída pelo
/// Dashboard real (gráficos + análises) nas próximas etapas.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ShadCard(
                title: Text('FinanceApp', style: theme.textTheme.h3),
                description: const Text(
                  'Ambiente Flutter pronto. Design system finance-ui aplicado.',
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      ShadButton(
                        onPressed: () {},
                        child: const Text('Botão primário'),
                      ),
                      ShadButton.secondary(
                        onPressed: () {},
                        child: const Text('Secundário'),
                      ),
                      ShadButton.outline(
                        onPressed: () {},
                        child: const Text('Outline'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
