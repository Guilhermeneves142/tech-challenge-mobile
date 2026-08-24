import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/utils/formatters.dart';
import '../../../transactions/models/transaction.dart';
import '../../models/dashboard_data.dart';

/// Cor de cada categoria no gráfico
extension _CategoryColor on TransactionCategory {
  Color get color => switch (this) {
    TransactionCategory.alimentacao => const Color(0xFF3B783A),
    TransactionCategory.renda => const Color(0xFF198754),
    TransactionCategory.transporte => const Color(0xFFFD7E14),
    TransactionCategory.moradia => const Color(0xFF0D6EFD),
    TransactionCategory.educacao => const Color(0xFF6F42C1),
    TransactionCategory.saude => const Color(0xFFDC3545),
    TransactionCategory.lazer => const Color(0xFF20C997),
    TransactionCategory.transferencia => const Color(0xFF737373),
    TransactionCategory.outros => const Color(0xFFA3A3A3),
  };
}

/// despesas do mês por categoria
class CategoryPieContent extends StatelessWidget {
  const CategoryPieContent({super.key, required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return !data.hasCategoryData
        ? _EmptyChart(
            message: 'Sem despesas neste mês para exibir.',
            theme: theme,
          )
        : LayoutBuilder(
              builder: (context, constraints) {
                final total = data.byCategory.fold<double>(
                  0,
                  (sum, c) => sum + c.total,
                );

                final chart = SizedBox(
                  width: 140,
                  height: 140,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 34,
                      sections: [
                        for (final item in data.byCategory)
                          PieChartSectionData(
                            value: item.total,
                            color: item.category.color,
                            radius: 26,
                            title: _percentLabel(item.total, total),
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                );

                final legend = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final item in data.byCategory)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _LegendRow(item: item, theme: theme),
                      ),
                  ],
                );

                if (constraints.maxWidth < 360) {
                  return Column(
                    children: [
                      chart,
                      const SizedBox(height: 16),
                      legend,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    chart,
                    const SizedBox(width: 20),
                    Expanded(child: legend),
                  ],
                );
              },
            );
  }

  String _percentLabel(double value, double total) {
    if (total <= 0) return '';
    final pct = (value / total) * 100;
    return pct < 6 ? '' : '${pct.toStringAsFixed(0)}%';
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.item, required this.theme});

  final CategoryTotal item;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: item.category.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            item.category.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.small,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatCurrency(item.total),
          style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.message, required this.theme});

  final String message;
  final ShadThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.muted,
        ),
      ),
    );
  }
}
