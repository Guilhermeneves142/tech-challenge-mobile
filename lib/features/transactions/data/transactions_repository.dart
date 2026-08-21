import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction.dart';
import '../models/transaction_filters.dart';

class TransactionPage {
  const TransactionPage({
    required this.items,
    required this.cursor,
    required this.hasMore,
  });

  final List<TransactionModel> items;

  final DocumentSnapshot<Map<String, dynamic>>? cursor;
  final bool hasMore;

  static const empty = TransactionPage(
    items: <TransactionModel>[],
    cursor: null,
    hasMore: false,
  );
}

class TransactionsSummary {
  const TransactionsSummary({this.receitas = 0, this.despesas = 0});

  final double receitas;
  final double despesas;

  double get saldo => receitas - despesas;

  static const empty = TransactionsSummary();
}

class TransactionsRepository {
  TransactionsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const int pageSize = 10;

  static final String _searchUpperBound = String.fromCharCode(0xF8FF);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('transactions');

  Query<Map<String, dynamic>> _query(
    String userId,
    TransactionFilters filters, {
    bool ordered = true,
  }) {
    Query<Map<String, dynamic>> query = _collection.where(
      'userId',
      isEqualTo: userId,
    );

    final type = filters.type;
    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    final prefix = filters.searchPrefix;
    if (prefix != null) {
      query = query
          .where('descriptionLower', isGreaterThanOrEqualTo: prefix)
          .where('descriptionLower', isLessThan: '$prefix$_searchUpperBound');
    }

    final range = filters.range;
    if (range != null) {
      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(range.end));
    }

    if (!ordered) return query;

    if (prefix != null) query = query.orderBy('descriptionLower');
    return query.orderBy('date', descending: true);
  }

  Future<TransactionPage> fetchPage({
    required String userId,
    required TransactionFilters filters,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int limit = pageSize,
  }) async {
    var query = _query(userId, filters);
    if (startAfter != null) query = query.startAfterDocument(startAfter);

    final snapshot = await query.limit(limit).get();
    final docs = snapshot.docs;

    return TransactionPage(
      items: docs.map(TransactionModel.fromDoc).toList(),
      cursor: docs.isEmpty ? null : docs.last,
      hasMore: docs.length == limit,
    );
  }

  Future<TransactionsSummary> fetchSummary({
    required String userId,
    required TransactionFilters filters,
  }) async {
    final receitas = _sumOf(userId, filters, TransactionType.receita);
    final despesas = _sumOf(userId, filters, TransactionType.despesa);

    return TransactionsSummary(
      receitas: await receitas,
      despesas: await despesas,
    );
  }

  Future<double> _sumOf(
    String userId,
    TransactionFilters filters,
    TransactionType type,
  ) async {
    if (filters.type != null && filters.type != type) return 0;

    final query = _query(userId, filters.copyWith(type: type), ordered: false);
    final snapshot = await query.aggregate(sum('amount')).get();
    return snapshot.getSum('amount') ?? 0;
  }

  Future<TransactionModel> save(TransactionModel transaction) async {
    final data = transaction.toFirestore();

    if (transaction.isNew) {
      final doc = await _collection.add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return transaction.copyWith(
        id: doc.id,
      );
    }

    await _collection.doc(transaction.id).update(data);

    return transaction;
  }

  Future<void> updateReceiptUrl(
    String transactionId,
    String receiptUrl,
  ) {
    return _collection.doc(transactionId).update({
      'receiptUrl': receiptUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String transactionId) =>
      _collection.doc(transactionId).delete();
}
