import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/transaction.dart';
import '../providers/transactions_provider.dart';
import 'widgets/transaction_filters_bar.dart';
import 'widgets/transaction_form_sheet.dart';
import 'widgets/transaction_tile.dart';
import 'widgets/transactions_summary_cards.dart';
import 'dart:io';
import '../data/receipt_img_storage_service.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.select<AuthProvider, String?>(
      (auth) => auth.user?.uid,
    );

    if (userId == null) {
      return const AppScaffold(
        title: 'Transações',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider(
      key: ValueKey(userId),
      create: (_) => TransactionsProvider(userId: userId),
      child: _TransactionsView(userId: userId),
    );
  }
}

class _TransactionsView extends StatefulWidget {
  const _TransactionsView({required this.userId});

  final String userId;

  @override
  State<_TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<_TransactionsView> {
  final _scrollController = ScrollController();

  static const _loadMoreThreshold = 320.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      context.read<TransactionsProvider>().loadMore();
    }
  }

  Future<void> _openForm({TransactionModel? transaction}) async {
    final provider = context.read<TransactionsProvider>();

    final result = await showTransactionFormSheet(
      context,
      userId: widget.userId,
      transaction: transaction,
    );

    if (result == null) return;

    final saved = await provider.save(
      result.transaction,
      receiptFile: result.receiptFile,
    );
    if (!mounted) return;

    if (saved) {
      _toast(
        transaction == null ? 'Transação adicionada.' : 'Transação atualizada.',
      );
    } else {
      _toast(provider.errorMessage ?? 'Não foi possível salvar.');
    }
  }

  Future<void> _confirmDelete(TransactionModel transaction) async {
    final provider = context.read<TransactionsProvider>();

    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (context) => ShadDialog.alert(
        title: const Text('Excluir transação'),
        radius: BorderRadius.circular(20),
        removeBorderRadiusWhenTiny: false,
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        useSafeArea: false,
        description: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          'Tem certeza que deseja excluir essa transação?\n'
          '"${transaction.description}" será removida permanentemente.',
          textAlign: TextAlign.left,
          style: ShadTheme.of(context).textTheme.muted.copyWith(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ShadButton.outline(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ShadButton.destructive(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Excluir'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final deleted = await provider.delete(transaction);
    if (!mounted) return;
    _toast(
      deleted
          ? 'Transação excluída.'
          : provider.errorMessage ?? 'Não foi possível excluir.',
    );
  }

  void _toast(String message) {
    ShadToaster.of(context).show(ShadToast(description: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final provider = context.watch<TransactionsProvider>();

    return AppScaffold(
      title: 'Transações',
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: provider.refresh,
        child: CustomScrollView(
          controller: _scrollController,
          // Garante que dá pra puxar para atualizar mesmo com pouca coisa.
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverToBoxAdapter(child: _ScreenHeader()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: TransactionFiltersBar(
                  onNewTransaction: () => _openForm(),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: TransactionsSummaryCards(
                  summary: provider.summary,
                  isLoading: provider.isLoading,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: DecoratedSliver(
                decoration: BoxDecoration(
                  color: theme.colorScheme.card,
                  borderRadius: theme.radius,
                  border: Border.all(color: theme.colorScheme.border),
                ),
                sliver: SliverMainAxisGroup(
                  slivers: [
                    const SliverToBoxAdapter(child: TransactionListHeader()),
                    _buildContent(provider),
                    SliverToBoxAdapter(child: _ListFooter(provider: provider)),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: _ScreenFooter()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(TransactionsProvider provider) {
    if (provider.errorMessage != null && provider.items.isEmpty) {
      return SliverToBoxAdapter(
        child: _ErrorState(
          message: provider.errorMessage!,
          onRetry: provider.refresh,
        ),
      );
    }

    if (provider.isLoading && provider.items.isEmpty) {
      return const SliverToBoxAdapter(child: _LoadingState());
    }

    if (provider.isEmpty) {
      return SliverToBoxAdapter(
        child: _EmptyState(hasFilters: !provider.filters.isEmpty),
      );
    }

    return SliverList.separated(
      itemCount: provider.items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final transaction = provider.items[index];
        return TransactionTile(
          transaction: transaction,
          onEdit: () => _openForm(transaction: transaction),
          onDelete: () => _confirmDelete(transaction),
        );
      },
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Transações', style: theme.textTheme.h2),
        const SizedBox(height: 2),
        Text('Veja as suas transações', style: theme.textTheme.muted),
      ],
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.provider});

  final TransactionsProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    if (provider.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text('Carregando mais', style: theme.textTheme.muted),
          ],
        ),
      );
    }

    if (provider.errorMessage != null && provider.items.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          provider.errorMessage!,
          textAlign: TextAlign.center,
          style: theme.textTheme.small.copyWith(
            color: theme.colorScheme.destructive,
          ),
        ),
      );
    }

    if (provider.items.isEmpty || provider.hasMore) {
      return const SizedBox(height: 12);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(
        'Você chegou ao fim da lista',
        textAlign: TextAlign.center,
        style: theme.textTheme.muted.copyWith(fontSize: 12),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters});

  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          Icon(
            hasFilters ? Icons.search_off_rounded : Icons.receipt_long_rounded,
            size: 40,
            color: theme.colorScheme.mutedForeground,
          ),
          const SizedBox(height: 12),
          Text(
            hasFilters
                ? 'Nenhuma transação encontrada'
                : 'Você ainda não tem transações',
            style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            hasFilters
                ? 'Tente ajustar o período, a busca ou o tipo.'
                : 'Toque em "Nova Transação" para adicionar a primeira.',
            style: theme.textTheme.muted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: theme.colorScheme.destructive,
          ),
          const SizedBox(height: 12),
          Text(message, style: theme.textTheme.muted, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ShadButton.outline(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class _ScreenFooter extends StatelessWidget {
  const _ScreenFooter();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Text(
        '© ${DateTime.now().year} FinanceApp - Sua Gestão Financeira '
        'Profissional.',
        textAlign: TextAlign.center,
        style: theme.textTheme.muted.copyWith(fontSize: 11),
      ),
    );
  }
}
