import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/utils/formatters.dart';
import '../../models/transaction.dart';
import '../../models/transaction_filters.dart';
import '../../providers/transactions_provider.dart';

const _todos = 'todos';

class TransactionFiltersBar extends StatefulWidget {
  const TransactionFiltersBar({super.key, required this.onNewTransaction});

  final VoidCallback onNewTransaction;

  @override
  State<TransactionFiltersBar> createState() => _TransactionFiltersBarState();
}

class _TransactionFiltersBarState extends State<TransactionFiltersBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionsProvider>();
    final filters = provider.filters;

    final period = _Field(
      label: 'Período',
      child: ShadDatePicker.range(
        placeholder: const Text('Selecione'),
        selected: filters.range == null
            ? null
            : ShadDateTimeRange(
                start: filters.range!.start,
                end: filters.range!.end,
              ),
        formatDateRange: (range) {
          final start = range.start;
          final end = range.end;
          if (start == null) return 'Selecione';
          if (end == null) return formatShortDate(start);
          return '${formatShortDate(start)} - ${formatShortDate(end)}';
        },
        onRangeChanged: (range) {
          // Enquanto só o início foi escolhido, ainda não dá para filtrar.
          if (range?.start == null || range?.end == null) return;
          context.read<TransactionsProvider>().periodChanged(
            DateRange(range!.start!, range.end!),
          );
        },
      ),
    );

    final search = _Field(
      label: 'Buscar',
      child: ShadInput(
        controller: _searchController,
        placeholder: const Text('Descrição'),
        textInputAction: TextInputAction.search,
        leading: const Padding(
          padding: EdgeInsets.only(left: 2),
          child: Icon(Icons.search, size: 16),
        ),
        onChanged: context.read<TransactionsProvider>().searchChanged,
      ),
    );

    final type = _Field(
      label: 'Tipo',
      child: ShadSelect<String>(
        initialValue: filters.type?.name ?? _todos,
        placeholder: const Text('Todos os tipos'),
        selectedOptionBuilder: (context, value) => Text(_typeLabel(value)),
        options: [
          const ShadOption(value: _todos, child: Text('Todos os tipos')),
          for (final option in TransactionType.values)
            ShadOption(value: option.name, child: Text(option.label)),
        ],
        onChanged: (value) {
          context.read<TransactionsProvider>().typeChanged(
            value == null || value == _todos
                ? null
                : TransactionType.fromName(value),
          );
        },
      ),
    );

    return ShadCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 560;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Expanded(child: period),
                    Expanded(child: search),
                    Expanded(child: type),
                  ],
                )
              else ...[period, search, type],
              Row(
                children: [
                  ShadButton(
                    leading: const Icon(Icons.add, size: 16),
                    onPressed: widget.onNewTransaction,
                    child: const Text('Nova Transação'),
                  ),
                  const Spacer(),
                  if (!filters.isEmpty)
                    ShadButton.link(
                      onPressed: () {
                        _searchController.clear();
                        context.read<TransactionsProvider>().clearFilters();
                      },
                      child: const Text('Limpar filtros'),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _typeLabel(String value) => value == _todos
      ? 'Todos os tipos'
      : TransactionType.fromName(value).label;
}

/// Rótulo pequeno em cima do campo, como no design.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label,
            style: theme.textTheme.muted.copyWith(fontSize: 12),
          ),
        ),
        child,
      ],
    );
  }
}
