import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/transaction_category.dart';

class TransactionFiltersBar extends StatelessWidget {
  const TransactionFiltersBar({
    super.key,
    required this.selectedCategory,
    required this.startDate,
    required this.endDate,
    required this.onCategoryChanged,
    required this.onDateRangePressed,
    required this.onClear,
    required this.hasActiveFilters,
  });

  final String? selectedCategory;
  final String? startDate;
  final String? endDate;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onDateRangePressed;
  final VoidCallback onClear;
  final bool hasActiveFilters;

  static final _displayDate = DateFormat('dd/MM/yyyy');

  String get _dateLabel {
    if (startDate == null && endDate == null) return 'Período';
    String fmt(String? iso) {
      if (iso == null || iso.isEmpty) return '…';
      final parsed = DateTime.tryParse(iso);
      return parsed == null ? iso : _displayDate.format(parsed);
    }

    return '${fmt(startDate)} – ${fmt(endDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Material(
      color: theme.colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey(selectedCategory ?? 'all'),
                    initialValue: selectedCategory,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Categoria',
                      filled: true,
                      fillColor: theme.colorScheme.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: theme.colorScheme.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Todas'),
                      ),
                      ...TransactionCategory.values.map(
                        (c) => DropdownMenuItem<String?>(
                          value: c.value,
                          child: Text(c.label),
                        ),
                      ),
                    ],
                    onChanged: onCategoryChanged,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onDateRangePressed,
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    _dateLabel,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (hasActiveFilters) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ShadButton.ghost(
                  onPressed: onClear,
                  child: const Text('Limpar filtros'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
