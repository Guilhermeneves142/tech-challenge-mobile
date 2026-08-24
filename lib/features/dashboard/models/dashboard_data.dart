import '../../transactions/data/transactions_repository.dart';
import '../../transactions/models/transaction.dart';

/// Total gasto (ou recebido) por categoria
class CategoryTotal {
  const CategoryTotal({required this.category, required this.total});

  final TransactionCategory category;
  final double total;
}

/// Receitas x despesas de um mês
class MonthlyTotal {
  const MonthlyTotal({
    required this.month,
    required this.receitas,
    required this.despesas,
  });

  /// Primeiro dia do mês
  final DateTime month;
  final double receitas;
  final double despesas;

  double get saldo => receitas - despesas;
}

/// Tudo o que o Dashboard mostra, montado numa única carga
/// ([DashboardRepository.load]).
class DashboardData {
  const DashboardData({
    required this.summary,
    required this.byCategory,
    required this.byMonth,
    required this.recent,
    this.transactionCount = 0,
  });

  final TransactionsSummary summary;
  final List<CategoryTotal> byCategory;
  final List<MonthlyTotal> byMonth;
  final List<TransactionModel> recent;
  final int transactionCount;

  bool get hasCategoryData => byCategory.any((c) => c.total > 0);
  bool get hasMonthlyData =>
      byMonth.any((m) => m.receitas > 0 || m.despesas > 0);

  static const empty = DashboardData(
    summary: TransactionsSummary.empty,
    byCategory: <CategoryTotal>[],
    byMonth: <MonthlyTotal>[],
    recent: <TransactionModel>[],
  );
}
