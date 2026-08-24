import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/dashboard_data.dart';
import '../../models/dashboard_widget_config.dart';
import 'dashboard_widget_view.dart';
import 'widget_editor_sheet.dart';

/// widgets personalizável — arrastar
class AnalyticsSection extends StatefulWidget {
  const AnalyticsSection({
    super.key,
    required this.data,
    this.isLoading = false,
    this.onSeeAll,
    this.initialWidgets,
  });

  final DashboardData data;
  final bool isLoading;
  final VoidCallback? onSeeAll;
  final List<DashboardWidgetConfig>? initialWidgets;

  @override
  State<AnalyticsSection> createState() => _AnalyticsSectionState();
}

class _AnalyticsSectionState extends State<AnalyticsSection> {
  late List<DashboardWidgetConfig> _widgets = List.of(
    widget.initialWidgets ?? defaultDashboardWidgets(),
  );

  Future<void> _addWidget() async {
    final created = await showWidgetEditorSheet(context, data: widget.data);
    if (created == null) return;
    setState(() => _widgets.add(created));
  }

  Future<void> _editWidget(DashboardWidgetConfig config) async {
    final updated = await showWidgetEditorSheet(
      context,
      data: widget.data,
      config: config,
    );
    if (updated == null) return;
    setState(() {
      final index = _widgets.indexWhere((w) => w.id == config.id);
      if (index != -1) _widgets[index] = updated;
    });
  }

  Future<void> _deleteWidget(DashboardWidgetConfig config) async {
    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (context) {
        final theme = ShadTheme.of(context);
        return ShadDialog.alert(
          backgroundColor: theme.colorScheme.card,
          radius: BorderRadius.circular(16),
          removeBorderRadiusWhenTiny: false,
          useSafeArea: false,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 40,
          ),
          title: const Text('Excluir Widget'),
          description: Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 20),
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Tem certeza que deseja excluir o widget ',
                  ),
                  TextSpan(
                    text: config.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.foreground,
                    ),
                  ),
                  const TextSpan(
                    text: ' do seu dashboard? Esta ação não pode ser desfeita.',
                  ),
                ],
              ),
              style: theme.textTheme.muted.copyWith(height: 1.5),
            ),
          ),
          actions: [
            ShadButton.destructive(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
            ShadButton.outline(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    setState(() => _widgets.removeWhere((w) => w.id == config.id));
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _widgets.removeAt(oldIndex);
      _widgets.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(
              Icons.insights_rounded,
              size: 22,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text('Análises financeiras', style: theme.textTheme.h3),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ShadButton(
            leading: const Icon(Icons.add, size: 16),
            onPressed: _addWidget,
            child: const Text('Adicionar widget'),
          ),
        ),
        const SizedBox(height: 16),
        if (_widgets.isEmpty)
          _EmptyPanel(theme: theme)
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: _widgets.length,
            onReorder: _onReorder,
            proxyDecorator: (child, index, animation) =>
                Material(color: Colors.transparent, child: child),
            itemBuilder: (context, index) {
              final config = _widgets[index];
              // Segure o widget para arrastar.
              return Padding(
                key: ValueKey(config.id),
                padding: const EdgeInsets.only(bottom: 12),
                child: ReorderableDelayedDragStartListener(
                  index: index,
                  child: DashboardWidgetView(
                    config: config,
                    data: widget.data,
                    isLoading: widget.isLoading,
                    onEdit: () => _editWidget(config),
                    onDelete: () => _deleteWidget(config),
                    onSeeAll: widget.onSeeAll,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.theme});

  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: theme.radius,
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.dashboard_customize_outlined,
            size: 36,
            color: theme.colorScheme.mutedForeground,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum widget no painel.',
            style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Toque em "Adicionar widget" para começar.',
            textAlign: TextAlign.center,
            style: theme.textTheme.muted,
          ),
        ],
      ),
    );
  }
}
