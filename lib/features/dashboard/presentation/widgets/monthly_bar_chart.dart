import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../models/dashboard_data.dart';

class MonthlyBarsContent extends StatelessWidget {
  const MonthlyBarsContent({super.key, required this.data});

  final DashboardData data;

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
        _Legend(theme: theme),
        const SizedBox(height: 16),
        SizedBox(height: 190, child: BarChart(_chartData(theme))),
      ],
    );
  }

  BarChartData _chartData(ShadThemeData theme) {
    final rawMax = data.byMonth.fold<double>(0, (max, m) {
      final localMax = math.max(m.receitas, m.despesas);
      return math.max(max, localMax);
    });
    // Arredonda o topo para um múltiplo "redondo", gerando marcas tipo 2/4/6/8 mil
    final step = _niceStep(rawMax);
    final maxY = step * 4;
    final muted = theme.textTheme.muted.copyWith(fontSize: 10);

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => theme.colorScheme.foreground,
          getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
            formatCurrency(rod.toY),
            TextStyle(
              color: theme.colorScheme.background,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ),
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
              if (index < 0 || index >= data.byMonth.length) {
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
      barGroups: [
        for (var i = 0; i < data.byMonth.length; i++)
          BarChartGroupData(
            x: i,
            barsSpace: 3,
            barRods: [
              _rod(data.byMonth[i].despesas, _despesaColor),
              _rod(data.byMonth[i].receitas, _receitaColor),
            ],
          ),
      ],
    );
  }

  BarChartRodData _rod(double value, Color color) => BarChartRodData(
    toY: value,
    color: color,
    width: 9,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
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
    final magnitude = math.pow(10, (math.log(rough) / math.ln10).floor())
        .toDouble();
    for (final m in [1, 2, 2.5, 5, 10]) {
      final candidate = m * magnitude;
      if (candidate >= rough) return candidate;
    }
    return 10 * magnitude;
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.theme});

  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(
          color: MonthlyBarsContent._despesaColor,
          label: 'Despesas',
          theme: theme,
        ),
        const SizedBox(width: 20),
        _LegendDot(
          color: MonthlyBarsContent._receitaColor,
          label: 'Receitas',
          theme: theme,
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.theme,
  });

  final Color color;
  final String label;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
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
  }
}
