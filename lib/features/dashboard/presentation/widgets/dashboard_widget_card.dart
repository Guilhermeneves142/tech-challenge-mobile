import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Cartão de um "widget" do painel Análises financeiras (espelha o web).
///
/// Cabeçalho com alça de arrastar (≡), título e ações editar/excluir. Por
/// enquanto os controles são visuais — a reordenação/edição/exclusão de verdade
/// fica para uma etapa seguinte (via [onEdit]/[onDelete], hoje opcionais).
class DashboardWidgetCard extends StatelessWidget {
  const DashboardWidgetCard({
    super.key,
    required this.title,
    required this.child,
    this.onEdit,
    this.onDelete,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 12, 16),
  });

  final String title;
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final muted = theme.colorScheme.mutedForeground;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: theme.radius,
        border: Border.all(color: theme.colorScheme.border),
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.drag_indicator, size: 18, color: muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.large.copyWith(fontSize: 15),
                ),
              ),
              _HeaderAction(
                icon: Icons.edit_outlined,
                tooltip: 'Editar',
                onTap: onEdit,
                color: muted,
              ),
              _HeaderAction(
                icon: Icons.delete_outline,
                tooltip: 'Excluir',
                onTap: onDelete,
                color: theme.colorScheme.destructive,
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: onTap == null ? 'Disponível em breve' : tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 18,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }
}
