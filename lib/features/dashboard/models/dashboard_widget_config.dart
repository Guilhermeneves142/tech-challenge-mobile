/// Tipo de visualização de um widget do painel (espelha o "Tipo de gráfico" do
/// modal Editar Widget no web).
enum WidgetChartType {
  kpi('Indicador (KPI)'),
  bars('Barras'),
  line('Linha'),
  area('Área'),
  pie('Pizza'),
  list('Extrato (lista)');

  const WidgetChartType(this.label);

  final String label;

  static WidgetChartType fromName(String? name) => values.firstWhere(
    (t) => t.name == name,
    orElse: () => WidgetChartType.kpi,
  );
}

/// Métrica exibida por um widget do tipo KPI (o campo "KPI" do modal).
enum WidgetMetric {
  saldo('Saldo (resultado)'),
  receitas('Receitas'),
  despesas('Despesas'),
  count('N° de transações');

  const WidgetMetric(this.label);

  final String label;

  static WidgetMetric fromName(String? name) => values.firstWhere(
    (m) => m.name == name,
    orElse: () => WidgetMetric.saldo,
  );
}

/// Configuração de um widget do painel Análises financeiras.
class DashboardWidgetConfig {
  const DashboardWidgetConfig({
    required this.id,
    required this.name,
    required this.type,
    this.metric = WidgetMetric.saldo,
  });

  final String id;
  final String name;
  final WidgetChartType type;

  /// Só é usada quando [type] == [WidgetChartType.kpi].
  final WidgetMetric metric;

  DashboardWidgetConfig copyWith({
    String? name,
    WidgetChartType? type,
    WidgetMetric? metric,
  }) {
    return DashboardWidgetConfig(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      metric: metric ?? this.metric,
    );
  }
}

/// Layout padrão do painel
List<DashboardWidgetConfig> defaultDashboardWidgets() => [
  const DashboardWidgetConfig(
    id: 'saldo',
    name: 'Saldo atual',
    type: WidgetChartType.kpi,
    metric: WidgetMetric.saldo,
  ),
  const DashboardWidgetConfig(
    id: 'receitas',
    name: 'Receitas',
    type: WidgetChartType.kpi,
    metric: WidgetMetric.receitas,
  ),
  const DashboardWidgetConfig(
    id: 'despesas',
    name: 'Despesas',
    type: WidgetChartType.kpi,
    metric: WidgetMetric.despesas,
  ),
  const DashboardWidgetConfig(
    id: 'receitas-despesas',
    name: 'Receitas × Despesas',
    type: WidgetChartType.bars,
  ),
  const DashboardWidgetConfig(
    id: 'por-categoria',
    name: 'Despesas por categoria',
    type: WidgetChartType.pie,
  ),
  const DashboardWidgetConfig(
    id: 'extrato',
    name: 'Extrato Recente',
    type: WidgetChartType.list,
  ),
];
