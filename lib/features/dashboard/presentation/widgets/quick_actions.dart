import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Mensagem "O que você quer fazer?" atalhos do topo do Dashboard
/// "Transferir" e "Pagar Conta" indisponveis
class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.onNewTransaction});

  final VoidCallback onNewTransaction;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.bolt_rounded, size: 22, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('O que você quer fazer?', style: theme.textTheme.h3),
          ],
        ),
        const SizedBox(height: 16),
        _ActionCard(
          label: 'Transação',
          icon: Icons.add_rounded,
          onTap: onNewTransaction,
        ),
        const SizedBox(height: 12),
        const _ActionCard(label: 'Transferir', icon: Icons.swap_horiz_rounded),
        const SizedBox(height: 12),
        const _ActionCard(
          label: 'Pagar Conta',
          icon: Icons.qr_code_scanner_rounded,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final enabled = onTap != null;

    final circleColor = enabled
        ? theme.colorScheme.secondary
        : theme.colorScheme.muted;
    final iconColor = enabled
        ? theme.colorScheme.primary
        : theme.colorScheme.mutedForeground;

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.small.copyWith(
              fontWeight: FontWeight.w600,
              color: enabled
                  ? theme.colorScheme.foreground
                  : theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );

    if (!enabled) {
      return Tooltip(
        message: 'Disponível em breve',
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: theme.radius,
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: content,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: theme.radius,
          border: Border.all(color: theme.colorScheme.border),
        ),
        child: content,
      ),
    );
  }
}
