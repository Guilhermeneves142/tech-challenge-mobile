import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/transaction.dart';
import '../../models/transaction_category.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  final TransactionModel transaction;
  final VoidCallback onDelete;

  static final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final amountColor =
        transaction.isIncome ? AppColors.success : AppColors.error;
    final sign = transaction.isIncome ? '+' : '-';
    final dateText = transaction.dateLabel.isNotEmpty
        ? transaction.dateLabel
        : transaction.date;

    return Dismissible(
      key: ValueKey(transaction.docId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        // A exclusão real acontece após confirmação no diálogo da tela.
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: theme.colorScheme.destructive,
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.destructiveForeground,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: amountColor.withValues(alpha: 0.15),
          child: Icon(
            transaction.isIncome
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: amountColor,
            size: 20,
          ),
        ),
        title: Text(
          transaction.description,
          style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${TransactionCategory.labelOf(transaction.category)}'
          '${dateText.isEmpty ? '' : ' · $dateText'}',
          style: theme.textTheme.muted,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$sign ${_currency.format(transaction.amount.abs())}',
              style: theme.textTheme.small.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            IconButton(
              tooltip: 'Excluir',
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.mutedForeground,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
