import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/transactions_repository.dart';

class TransactionsSummaryCards extends StatelessWidget {
  const TransactionsSummaryCards({
    super.key,
    required this.summary,
    required this.isLoading,
  });

  final TransactionsSummary summary;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Receitas',
                  value: summary.receitas,
                  isLoading: isLoading,
                  background: AppColors.brandSecondary,
                  foreground: AppColors.brandTertiary,
                ),
              ),
              Expanded(
                child: _SummaryCard(
                  label: 'Despesas',
                  value: summary.despesas,
                  isLoading: isLoading,
                  background: AppColors.error,
                  foreground: Colors.white,
                ),
              ),
            ],
          ),
        ),
        _SummaryCard(
          label: 'Seu Saldo Atual',
          value: summary.saldo,
          isLoading: isLoading,
          background: AppColors.brandTertiary,
          foreground: Colors.white,
          valueFontSize: 26,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.isLoading,
    required this.background,
    required this.foreground,
    this.valueFontSize = 20,
  });

  final String label;
  final double value;
  final bool isLoading;
  final Color background;
  final Color foreground;
  final double valueFontSize;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: theme.radius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.small.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              isLoading ? r'R$ --' : formatCurrency(value),
              style: TextStyle(
                color: foreground,
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
