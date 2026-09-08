import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum ChartType { pie, bar, line }

class ChartSlice {
  const ChartSlice({required this.label, required this.value});

  final String label;
  final double value;
}

class WidgetChart extends StatefulWidget {
  const WidgetChart({
    super.key,
    required this.chartType,
    required this.data,
    this.onSliceTap,
  });

  final ChartType chartType;
  final List<ChartSlice> data;

  /// Disparado quando o usuário toca em um item do gráfico (fatia, barra ou
  /// ponto da linha). Quem usa o [WidgetChart] decide o que fazer com isso —
  /// o componente só reporta qual item foi tocado.
  final ValueChanged<ChartSlice>? onSliceTap;

  @override
  State<WidgetChart> createState() => _WidgetChartState();
}

class _WidgetChartState extends State<WidgetChart> {
  /// Índice da fatia do pie tocada no momento (-1 = nenhuma) — usado só pra
  /// destaque visual (fatia cresce enquanto o dedo está sobre ela).
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    if (data.isEmpty) {
      return const Center(child: Text('Sem dados para exibir'));
    }

    switch (widget.chartType) {
      case ChartType.pie:
        return _buildPie(data);
      case ChartType.bar:
        return _buildBar(data);
      case ChartType.line:
        return _buildLine(data);
    }
  }

  static const _palette = [
    AppColors.brandPrimary,
    AppColors.brandTertiary,
    AppColors.error,
    AppColors.info,
    AppColors.warning,
  ];

  Widget _buildPie(List<ChartSlice> data) {
    final total = _total(data);
    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 0,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  final index = response?.touchedSection?.touchedSectionIndex;

                  setState(() {
                    _touchedIndex = event.isInterestedForInteractions
                        ? (index ?? -1)
                        : -1;
                  });

                  if (event.isInterestedForInteractions &&
                      index != null &&
                      index >= 0 &&
                      index < data.length) {
                    widget.onSliceTap?.call(data[index]);
                  }
                },
              ),
              sections: [
                for (var i = 0; i < data.length; i++)
                  PieChartSectionData(
                    value: data[i].value,
                    color: _palette[i % _palette.length],
                    radius: i == _touchedIndex ? 100 : 90,
                    title:
                        '${(data[i].value / total * 100).toStringAsFixed(1)}%',
                    titleStyle: TextStyle(
                      fontSize: i == _touchedIndex ? 20 : 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkPrimaryForeground,
                      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _legend(data, total),
      ],
    );
  }

  double _total(List<ChartSlice> data) {
    return data.fold(0.0, (sum, item) => sum + item.value);
  }

  Widget _legend(List<ChartSlice> data, double total) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < data.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _palette[i % _palette.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${data[i].label} (${(data[i].value / total * 100).toStringAsFixed(1)}%)',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildBar(List<ChartSlice> data) {
    final total = _total(data);
    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(
                touchCallback: (event, response) {
                  if (!event.isInterestedForInteractions) return;
                  final index = response?.spot?.touchedBarGroupIndex;
                  if (index != null && index >= 0 && index < data.length) {
                    widget.onSliceTap?.call(data[index]);
                  }
                },
              ),
              barGroups: [
                for (var i = 0; i < data.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i].value,
                        color: _palette[i % _palette.length],
                        width: 24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
              ],
              titlesData: _axisTitles(data),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _legend(data, total),
      ],
    );
  }

  /// Eixos compartilhados por barra e linha: só o de baixo mostra os labels
  /// de categoria (um por índice); os outros três lados ficam ocultos —
  /// sem isso o fl_chart desenha números automáticos nos 4 lados, que se
  /// misturam com os labels de categoria.
  FlTitlesData _axisTitles(List<ChartSlice> data) {
    const hidden = AxisTitles(sideTitles: SideTitles(showTitles: false));
    return FlTitlesData(
      topTitles: hidden,
      rightTitles: hidden,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= data.length) {
              return const SizedBox.shrink();
            }
            return Text(
              data[index].label,
              style: const TextStyle(fontSize: 11),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLine(List<ChartSlice> data) {
    final total = _total(data);
    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchCallback: (event, response) {
                  if (!event.isInterestedForInteractions) return;
                  final spots = response?.lineBarSpots;
                  if (spots == null || spots.isEmpty) return;
                  final index = spots.first.spotIndex;
                  if (index >= 0 && index < data.length) {
                    widget.onSliceTap?.call(data[index]);
                  }
                },
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < data.length; i++)
                      FlSpot(i.toDouble(), data[i].value),
                  ],
                  color: _palette.first,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                ),
              ],
              titlesData: _axisTitles(data),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _legend(data, total),
      ],
    );
  }
}
