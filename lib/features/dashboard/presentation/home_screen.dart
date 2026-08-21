import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../../transactions/presentation/widgets/transaction_form_sheet.dart';
import '../providers/dashboard_provider.dart';
import 'widgets/analytics_section.dart';
import 'widgets/quick_actions.dart';

/// Tela principal (área logada): o Dashboard com resumo, gráficos e atalhos.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.select<AuthProvider, String?>(
      (auth) => auth.user?.uid,
    );

    if (userId == null) {
      return const AppScaffold(
        title: 'Dashboard',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider(
      key: ValueKey(userId),
      create: (_) => DashboardProvider(userId: userId),
      child: _DashboardView(userId: userId),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView({required this.userId});

  final String userId;

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  Future<void> _openNewTransaction() async {
    final provider = context.read<DashboardProvider>();

    final draft = await showTransactionFormSheet(
      context,
      userId: widget.userId,
    );
    if (draft == null) return;

    final saved = await provider.saveTransaction(draft);
    if (!mounted) return;
    _toast(
      saved
          ? 'Transação adicionada.'
          : provider.errorMessage ?? 'Não foi possível salvar.',
    );
  }

  void _toast(String message) {
    ShadToaster.of(context).show(ShadToast(description: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final provider = context.watch<DashboardProvider>();

    return AppScaffold(
      title: 'Dashboard',
      body: RefreshIndicator(
        color: theme.colorScheme.primary,
        onRefresh: provider.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Header(),
              const SizedBox(height: 20),
              _buildContent(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(DashboardProvider provider) {
    if (provider.errorMessage != null && provider.data.recent.isEmpty) {
      return _ErrorState(
        message: provider.errorMessage!,
        onRetry: provider.refresh,
      );
    }

    if (provider.isLoading && provider.data.recent.isEmpty) {
      return const _LoadingState();
    }

    final data = provider.data;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuickActions(onNewTransaction: _openNewTransaction),
        const SizedBox(height: 24),
        AnalyticsSection(
          data: data,
          isLoading: provider.isLoading,
          onSeeAll: () => context.go('/transacoes'),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final name = context.select<AuthProvider, String?>(
      (auth) => auth.user?.name,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Dashboard', style: theme.textTheme.h2),
        const SizedBox(height: 2),
        Text(
          name == null
              ? 'Veja o seu resumo financeiro'
              : 'Olá, $name — veja o seu resumo financeiro',
          style: theme.textTheme.muted,
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: theme.colorScheme.destructive,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.muted,
            textAlign: TextAlign.center,
          ),
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
