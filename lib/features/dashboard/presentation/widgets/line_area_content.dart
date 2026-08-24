import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../models/dashboard_data.dart';

class LineAreaContent extends StatelessWidget {
  const LineAreaContent({super.key, required this.data, this.filled = false});

  final DashboardData data;
  final bool filled;

  static const _receitaColor = AppColors.brandPrimary;
  static const _despesaColor = AppColors.error;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    if (!data.hasMonthlyData) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: Text(
            'Sem movimentações no período para exibir.',
            textAlign: TextAlign.center,
            style: theme.textTheme.muted,
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dot(_despesaColor, 'Despesas', theme),
            const SizedBox(width: 20),
            _dot(_receitaColor, 'Receitas', theme),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(height: 190, child: LineChart(_chartData(theme))),
      ],
    );
  }

  LineChartData _chartData(ShadThemeData theme) {
    final rawMax = data.byMonth.fold<double>(0, (max, m) {
      return math.max(max, math.max(m.receitas, m.despesas));
    });
    final step = _niceStep(rawMax);
    final maxY = step * 4;
    final muted = theme.textTheme.muted.copyWith(fontSize: 10);

    List<FlSpot> spots(double Function(int i) pick) => [
      for (var i = 0; i < data.byMonth.length; i++)
        FlSpot(i.toDouble(), pick(i)),
    ];

    LineChartBarData bar(Color color, double Function(int i) pick) =>
        LineChartBarData(
          spots: spots(pick),
          isCurved: true,
          curveSmoothness: 0.25,
          color: color,
          barWidth: 2,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: filled,
            color: color.withValues(alpha: 0.15),
          ),
        );

    return LineChartData(
      minY: 0,
      maxY: maxY,
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: step,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: theme.colorScheme.border, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: step,
            reservedSize: 38,
            getTitlesWidget: (value, meta) {
              if (value > maxY) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(_milLabel(value), style: muted),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 ||
                  index >= data.byMonth.length ||
                  value != index.toDouble()) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  formatMonthYear(data.byMonth[index].month),
                  style: muted,
                ),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        bar(_despesaColor, (i) => data.byMonth[i].despesas),
        bar(_receitaColor, (i) => data.byMonth[i].receitas),
      ],
    );
  }

  Widget _dot(Color color, String label, ShadThemeData theme) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: theme.textTheme.muted.copyWith(fontSize: 12)),
    ],
  );

  String _milLabel(double value) {
    if (value == 0) return '0';
    final thousands = value / 1000;
    final text = thousands == thousands.roundToDouble()
        ? thousands.toStringAsFixed(0)
        : thousands.toStringAsFixed(1);
    return '$text mil';
  }

  double _niceStep(double rawMax) {
    if (rawMax <= 0) return 250;
    final rough = rawMax / 4;
    final magnitude = math
        .pow(10, (math.log(rough) / math.ln10).floor())
        .toDouble();
    for (final m in [1, 2, 2.5, 5, 10]) {
      final candidate = m * magnitude;
      if (candidate >= rough) return candidate;
    }
    return 10 * magnitude;
  }
}
