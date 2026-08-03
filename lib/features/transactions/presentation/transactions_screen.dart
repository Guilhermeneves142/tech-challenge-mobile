import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/transactions_provider.dart';
import 'widgets/transaction_filters_bar.dart';
import 'widgets/transaction_tile.dart';

/// Listagem de transações do usuário autenticado (Firestore + filtros + paginação).
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _scrollController = ScrollController();
  static final _iso = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user?.id.toString();
      if (userId != null) {
        context.read<TransactionsProvider>().loadInitial(userId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<TransactionsProvider>().loadMore();
    }
  }

  Future<void> _pickDateRange(TransactionsProvider provider) async {
    final now = DateTime.now();
    final initialStart = provider.startDateFilter != null
        ? DateTime.tryParse(provider.startDateFilter!)
        : null;
    final initialEnd = provider.endDateFilter != null
        ? DateTime.tryParse(provider.endDateFilter!)
        : null;

    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: initialStart != null && initialEnd != null
          ? DateTimeRange(start: initialStart, end: initialEnd)
          : null,
      locale: const Locale('pt', 'BR'),
      helpText: 'Filtrar por período',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
    );

    if (range == null || !mounted) return;

    await provider.applyFilters(
      category: provider.categoryFilter,
      startDate: _iso.format(range.start),
      endDate: _iso.format(range.end),
    );
  }

  Future<void> _confirmDelete(
    TransactionsProvider provider,
    String docId,
    String description,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = ShadTheme.of(ctx);
        return AlertDialog(
          backgroundColor: theme.colorScheme.card,
          title: Text('Excluir transação', style: theme.textTheme.h3),
          content: Text(
            'Deseja remover "$description"? Esta ação não pode ser desfeita.',
            style: theme.textTheme.muted,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.destructive,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final ok = await provider.remove(docId);
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Transação removida.' : (provider.errorMessage ?? 'Falha ao excluir.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final provider = context.watch<TransactionsProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Transações'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.primaryForeground,
        elevation: 0,
      ),
      body: Column(
        children: [
          TransactionFiltersBar(
            selectedCategory: provider.categoryFilter,
            startDate: provider.startDateFilter,
            endDate: provider.endDateFilter,
            hasActiveFilters: provider.hasActiveFilters,
            onCategoryChanged: (value) {
              provider.applyFilters(
                category: value,
                startDate: provider.startDateFilter,
                endDate: provider.endDateFilter,
              );
            },
            onDateRangePressed: () => _pickDateRange(provider),
            onClear: provider.clearFilters,
          ),
          if (provider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                provider.errorMessage!,
                style: theme.textTheme.small.copyWith(
                  color: theme.colorScheme.destructive,
                ),
              ),
            ),
          Expanded(child: _buildBody(theme, provider)),
        ],
      ),
    );
  }

  Widget _buildBody(ShadThemeData theme, TransactionsProvider provider) {
    if (provider.loading && provider.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!provider.loading && provider.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 48,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(height: 12),
              Text('Nenhuma transação encontrada', style: theme.textTheme.h3),
              const SizedBox(height: 8),
              Text(
                provider.hasActiveFilters
                    ? 'Ajuste os filtros ou limpe-os para ver mais resultados.'
                    : 'Quando houver lançamentos, eles aparecerão aqui.',
                style: theme.textTheme.muted,
                textAlign: TextAlign.center,
              ),
              if (provider.hasActiveFilters) ...[
                const SizedBox(height: 16),
                ShadButton.outline(
                  onPressed: provider.clearFilters,
                  child: const Text('Limpar filtros'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final userId = context.read<AuthProvider>().user?.id.toString();
        if (userId != null) await provider.loadInitial(userId);
      },
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.items.length + (provider.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: theme.colorScheme.border,
        ),
        itemBuilder: (context, index) {
          if (index >= provider.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final tx = provider.items[index];
          return TransactionTile(
            transaction: tx,
            onDelete: () => _confirmDelete(provider, tx.docId, tx.description),
          );
        },
      ),
    );
  }
}
