import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/dashboard_data.dart';
import '../../models/dashboard_widget_config.dart';
import 'dashboard_widget_view.dart';

/// Abre o modal "Editar Widget"
Future<DashboardWidgetConfig?> showWidgetEditorSheet(
  BuildContext context, {
  required DashboardData data,
  DashboardWidgetConfig? config,
}) {
  return showShadDialog<DashboardWidgetConfig>(
    context: context,
    builder: (context) => _WidgetEditorSheet(data: data, config: config),
  );
}

class _WidgetEditorSheet extends StatefulWidget {
  const _WidgetEditorSheet({required this.data, this.config});

  final DashboardData data;
  final DashboardWidgetConfig? config;

  @override
  State<_WidgetEditorSheet> createState() => _WidgetEditorSheetState();
}

class _WidgetEditorSheetState extends State<_WidgetEditorSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.config?.name ?? '',
  );
  late WidgetChartType _type = widget.config?.type ?? WidgetChartType.kpi;
  late WidgetMetric _metric = widget.config?.metric ?? WidgetMetric.saldo;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim().isEmpty
        ? _type.label
        : _name.text.trim();
    Navigator.of(context).pop(
      DashboardWidgetConfig(
        id: widget.config?.id ?? 'w${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        type: _type,
        metric: _metric,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isNew = widget.config == null;

    final draft = DashboardWidgetConfig(
      id: 'preview',
      name: _name.text,
      type: _type,
      metric: _metric,
    );

    return ShadDialog(
      backgroundColor: theme.colorScheme.card,
      radius: BorderRadius.circular(16),
      removeBorderRadiusWhenTiny: false,
      useSafeArea: false,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width - 40,
      ),
      title: Text(isNew ? 'Adicionar Widget' : 'Editar Widget'),
      actions: [
        ShadButton(onPressed: _save, child: const Text('Salvar')),
        ShadButton.outline(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
            _Field(
              label: 'Nome',
              child: ShadInput(
                controller: _name,
                placeholder: const Text('Nome do widget'),
              ),
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Tipo de gráfico',
              child: ShadSelect<WidgetChartType>(
                initialValue: _type,
                placeholder: const Text('Selecione'),
                selectedOptionBuilder: (context, value) => Text(value.label),
                options: [
                  for (final type in WidgetChartType.values)
                    ShadOption(value: type, child: Text(type.label)),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _type = value);
                },
              ),
            ),
            if (_type == WidgetChartType.kpi) ...[
              const SizedBox(height: 16),
              _Field(
                label: 'KPI',
                child: ShadSelect<WidgetMetric>(
                  initialValue: _metric,
                  placeholder: const Text('Selecione'),
                  selectedOptionBuilder: (context, value) => Text(value.label),
                  options: [
                    for (final metric in WidgetMetric.values)
                      ShadOption(value: metric, child: Text(metric.label)),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _metric = value);
                  },
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Pré-visualização',
              style: theme.textTheme.muted.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.card,
                borderRadius: theme.radius,
                border: Border.all(color: theme.colorScheme.border),
              ),
              child: buildWidgetContent(draft, widget.data),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(label, style: theme.textTheme.small),
        ),
        child,
      ],
    );
  }
}
