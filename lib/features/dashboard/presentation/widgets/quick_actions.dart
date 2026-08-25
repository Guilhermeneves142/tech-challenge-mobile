import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:finance_app_mobile/core/widgets/entrance_fade.dart';

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
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: EntranceFade(
                child: _ActionItem(
                  label: 'Transação',
                  icon: Icons.add_rounded,
                  onTap: onNewTransaction,
                ),
              ),
            ),
            Expanded(
              child: EntranceFade(
                delay: const Duration(milliseconds: 60),
                child: const _ActionItem(
                  label: 'Transferir',
                  icon: Icons.swap_horiz_rounded,
                ),
              ),
            ),
            Expanded(
              child: EntranceFade(
                delay: const Duration(milliseconds: 120),
                child: const _ActionItem(
                  label: 'Pagar Conta',
                  icon: Icons.qr_code_scanner_rounded,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Atalho sem card: apenas um ícone circular com leve animação de toque
/// (escala) e entrada em cascata, para uma linha mais leve e elegante.
class _ActionItem extends StatefulWidget {
  const _ActionItem({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  State<_ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<_ActionItem> {
  double _scale = 1;

  void _setPressed(bool pressed) {
    setState(() => _scale = pressed ? 0.92 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final enabled = widget.onTap != null;

    final circleColor = enabled
        ? theme.colorScheme.secondary
        : theme.colorScheme.muted;
    final iconColor = enabled
        ? theme.colorScheme.primary
        : theme.colorScheme.mutedForeground;

    final item = AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
            child: Icon(widget.icon, size: 26, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            widget.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
        child: Opacity(opacity: 0.6, child: item),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: item,
    );
  }
}
