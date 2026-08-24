import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../transactions/models/transaction.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';

class RecentTransactionsContent extends StatelessWidget {
  const RecentTransactionsContent({
    super.key,
    required this.transactions,
    this.onSeeAll,
  });

  final List<TransactionModel> transactions;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text('Nenhuma transação ainda.', style: theme.textTheme.muted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < transactions.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          _RecentRow(transaction: transactions[i]),
        ],
        if (onSeeAll != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: ShadButton.ghost(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              onPressed: onSeeAll,
              child: Text(
                'Ver tudo',
                style: theme.textTheme.small.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isIncome = transaction.type == TransactionType.receita;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.colorScheme.accent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.category.icon,
              size: 17,
              color: theme.colorScheme.accentForeground,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  transaction.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.small,
                ),
                const SizedBox(height: 2),
                Text(
                  formatTransactionDate(transaction.date),
                  style: theme.textTheme.muted.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatSignedCurrency(transaction.signedAmount),
            style: theme.textTheme.small.copyWith(
              fontWeight: FontWeight.w600,
              color: isIncome ? AppColors.success : theme.colorScheme.destructive,
            ),
          ),
        ],
      ),
    );
  }
}
