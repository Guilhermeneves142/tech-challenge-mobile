import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../models/dashboard_data.dart';
import '../../models/dashboard_widget_config.dart';

class MetricContent extends StatelessWidget {
  const MetricContent({
    super.key,
    required this.metric,
    required this.data,
    this.isLoading = false,
  });

  final WidgetMetric metric;
  final DashboardData data;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final summary = data.summary;

    final (String value, Color color) = switch (metric) {
      WidgetMetric.saldo => (
        formatCurrency(summary.saldo),
        summary.saldo < 0 ? AppColors.error : AppColors.success,
      ),
      WidgetMetric.receitas => (
        formatCurrency(summary.receitas),
        AppColors.success,
      ),
      WidgetMetric.despesas => (
        formatCurrency(summary.despesas),
        AppColors.error,
      ),
      WidgetMetric.count => (
        '${data.transactionCount}',
        theme.colorScheme.foreground,
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            isLoading ? '—' : value,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(metric.label, style: theme.textTheme.muted.copyWith(fontSize: 12)),
      ],
    );
  }
}
