import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction.dart';

/// Página retornada pelo Firestore (scroll infinito).
class TransactionsPage {
  const TransactionsPage({
    required this.items,
    required this.lastDoc,
    required this.hasMore,
  });

  final List<TransactionModel> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  final bool hasMore;
}

/// Acesso à coleção `transactions` no Cloud Firestore.
class TransactionsRepository {
  TransactionsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const _collection = 'transactions';
  static const defaultPageSize = 20;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(_collection);

  Future<TransactionsPage> fetchPage({
    required String userId,
    String? category,
    String? startDate,
    String? endDate,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int limit = defaultPageSize,
  }) async {
    Query<Map<String, dynamic>> query =
        _col.where('userId', isEqualTo: userId);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    if (startDate != null && startDate.isNotEmpty) {
      query = query.where('date', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null && endDate.isNotEmpty) {
      query = query.where('date', isLessThanOrEqualTo: endDate);
    }

    query = query.orderBy('date', descending: true).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final items = snapshot.docs
        .map(TransactionModel.fromFirestore)
        .toList(growable: false);

    return TransactionsPage(
      items: items,
      lastDoc: snapshot.docs.isEmpty ? null : snapshot.docs.last,
      hasMore: snapshot.docs.length >= limit,
    );
  }

  Future<void> delete(String docId) {
    return _col.doc(docId).delete();
  }
}
