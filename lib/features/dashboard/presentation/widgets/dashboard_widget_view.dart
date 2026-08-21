import 'package:flutter/material.dart';

import '../../models/dashboard_data.dart';
import '../../models/dashboard_widget_config.dart';
import 'category_pie_chart.dart';
import 'dashboard_widget_card.dart';
import 'line_area_content.dart';
import 'metric_card.dart';
import 'monthly_bar_chart.dart';
import 'recent_transactions_card.dart';

/// Constrói o CONTEÚDO de um widget a partir da sua config e dos dados
Widget buildWidgetContent(
  DashboardWidgetConfig config,
  DashboardData data, {
  bool isLoading = false,
  VoidCallback? onSeeAll,
}) {
  return switch (config.type) {
    WidgetChartType.kpi => MetricContent(
      metric: config.metric,
      data: data,
      isLoading: isLoading,
    ),
    WidgetChartType.bars => MonthlyBarsContent(data: data),
    WidgetChartType.line => LineAreaContent(data: data),
    WidgetChartType.area => LineAreaContent(data: data, filled: true),
    WidgetChartType.pie => CategoryPieContent(data: data),
    WidgetChartType.list => RecentTransactionsContent(
      transactions: data.recent,
      onSeeAll: onSeeAll,
    ),
  };
}

/// Um widget do painel: cartão com cabeçalho editar/excluir/arrastar
class DashboardWidgetView extends StatelessWidget {
  const DashboardWidgetView({
    super.key,
    required this.config,
    required this.data,
    this.isLoading = false,
    this.onEdit,
    this.onDelete,
    this.onSeeAll,
  });

  final DashboardWidgetConfig config;
  final DashboardData data;
  final bool isLoading;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return DashboardWidgetCard(
      title: config.name,
      onEdit: onEdit,
      onDelete: onDelete,
      child: buildWidgetContent(
        config,
        data,
        isLoading: isLoading,
        onSeeAll: onSeeAll,
      ),
    );
  }
}
