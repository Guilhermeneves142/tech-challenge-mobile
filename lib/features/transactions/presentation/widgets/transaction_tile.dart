import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../models/transaction.dart';

const double kWideTransactionRow = 420;

extension TransactionCategoryIcon on TransactionCategory {
  IconData get icon => switch (this) {
    TransactionCategory.alimentacao => Icons.shopping_basket_rounded,
    TransactionCategory.renda => Icons.payments_rounded,
    TransactionCategory.transporte => Icons.local_gas_station_rounded,
    TransactionCategory.moradia => Icons.home_rounded,
    TransactionCategory.educacao => Icons.school_rounded,
    TransactionCategory.saude => Icons.favorite_rounded,
    TransactionCategory.lazer => Icons.sports_esports_rounded,
    TransactionCategory.transferencia => Icons.swap_horiz_rounded,
    TransactionCategory.outros => Icons.receipt_long_rounded,
  };
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  final TransactionModel transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isIncome = transaction.type == TransactionType.receita;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= kWideTransactionRow;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _CategoryAvatar(category: transaction.category),
              const SizedBox(width: 12),
              Expanded(
                flex: 5,
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            formatTransactionDate(transaction.date),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.muted.copyWith(fontSize: 11),
                          ),
                        ),
                        // No celular a categoria vira um chip aqui embaixo.
                        if (!isWide) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: _CategoryChip(
                              category: transaction.category,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isWide) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _CategoryChip(category: transaction.category),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Text(
                formatSignedCurrency(transaction.signedAmount),
                textAlign: TextAlign.right,
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isIncome
                      ? AppColors.success
                      : theme.colorScheme.destructive,
                ),
              ),
              const SizedBox(width: 4),
              ShadIconButton.ghost(
                width: 30,
                height: 30,
                icon: const Icon(Icons.edit_outlined, size: 16),
                onPressed: onEdit,
              ),
              ShadIconButton.ghost(
                width: 30,
                height: 30,
                icon: const Icon(Icons.delete_outline, size: 16),
                foregroundColor: theme.colorScheme.destructive,
                onPressed: onDelete,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryAvatar extends StatelessWidget {
  const _CategoryAvatar({required this.category});

  final TransactionCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: theme.colorScheme.accent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        category.icon,
        size: 17,
        color: theme.colorScheme.accentForeground,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final TransactionCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        category.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.muted.copyWith(
          fontSize: 11,
          color: theme.colorScheme.foreground,
        ),
      ),
    );
  }
}

class TransactionListHeader extends StatelessWidget {
  const TransactionListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final style = theme.textTheme.muted.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= kWideTransactionRow;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              const SizedBox(width: 46), // alinha com o avatar da categoria
              Expanded(flex: 5, child: Text('DESCRIÇÃO', style: style)),
              if (isWide)
                Expanded(flex: 3, child: Text('CATEGORIA', style: style)),
              Text('VALOR', style: style),
              const SizedBox(width: 12),
              Text('AÇÕES', style: style),
            ],
          ),
        );
      },
    );
  }
}
