import 'package:cloud_firestore/cloud_firestore.dart';

import '../../transactions/data/transactions_repository.dart';
import '../../transactions/models/transaction.dart';
import '../models/dashboard_data.dart';

/// Fonte de dados do Dashboard.
class DashboardRepository {
  DashboardRepository({
    FirebaseFirestore? firestore,
    TransactionsRepository? transactions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _transactions =
           transactions ?? TransactionsRepository(firestore: firestore);

  final FirebaseFirestore _firestore;
  final TransactionsRepository _transactions;

  /// Quantos meses o gráfico de evolução cobre
  static const int monthsWindow = 6;

  /// Quantas transações a lista "últimas transações" mostra
  static const int recentCount = 5;

  /// Teto de segurança de leitura evita baixar volumes garndes de uma vez
  static const int _maxDocs = 500;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('transactions');

  Future<DashboardData> load(String userId) async {
    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .limit(_maxDocs)
        .get();

    final all = snapshot.docs.map(TransactionModel.fromDoc).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // mais recentes primeiro

    final now = DateTime.now();

    return DashboardData(
      summary: _summaryOf(all),
      byCategory: _byCategory(all, now),
      byMonth: _byMonth(all, now),
      recent: all.take(recentCount).toList(),
      transactionCount: all.length,
    );
  }

  TransactionsSummary _summaryOf(List<TransactionModel> transactions) {
    var receitas = 0.0;
    var despesas = 0.0;
    for (final tx in transactions) {
      if (tx.type == TransactionType.receita) {
        receitas += tx.amount;
      } else {
        despesas += tx.amount;
      }
    }
    return TransactionsSummary(receitas: receitas, despesas: despesas);
  }

  List<CategoryTotal> _byCategory(
    List<TransactionModel> transactions,
    DateTime now,
  ) {
    final totals = <TransactionCategory, double>{};

    for (final tx in transactions) {
      if (tx.type != TransactionType.despesa) continue;
      if (tx.date.year != now.year || tx.date.month != now.month) continue;
      totals.update(
        tx.category,
        (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }

    final result = totals.entries
        .map((e) => CategoryTotal(category: e.key, total: e.value))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return result;
  }

  List<MonthlyTotal> _byMonth(
    List<TransactionModel> transactions,
    DateTime now,
  ) {
    final receitas = <String, double>{};
    final despesas = <String, double>{};
    final months = <DateTime>[];

    for (var i = monthsWindow - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      months.add(month);
      receitas['${month.year}-${month.month}'] = 0;
      despesas['${month.year}-${month.month}'] = 0;
    }

    for (final tx in transactions) {
      final key = '${tx.date.year}-${tx.date.month}';
      if (!receitas.containsKey(key)) continue; // fora da janela
      if (tx.type == TransactionType.receita) {
        receitas[key] = receitas[key]! + tx.amount;
      } else {
        despesas[key] = despesas[key]! + tx.amount;
      }
    }

    return months.map((month) {
      final key = '${month.year}-${month.month}';
      return MonthlyTotal(
        month: month,
        receitas: receitas[key] ?? 0,
        despesas: despesas[key] ?? 0,
      );
    }).toList();
  }

  /// Salva/atualiza uma transação
  Future<void> save(TransactionModel transaction) =>
      _transactions.save(transaction);
}
