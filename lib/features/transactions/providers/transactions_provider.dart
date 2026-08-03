import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/transactions_repository.dart';
import '../models/transaction.dart';

/// Estado da listagem de transações (Provider).
class TransactionsProvider extends ChangeNotifier {
  TransactionsProvider({TransactionsRepository? repository})
      : _repository = repository ?? TransactionsRepository();

  final TransactionsRepository _repository;

  final List<TransactionModel> _items = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDoc;

  String? _userId;
  String? _category;
  String? _startDate;
  String? _endDate;

  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  List<TransactionModel> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  String? get categoryFilter => _category;
  String? get startDateFilter => _startDate;
  String? get endDateFilter => _endDate;
  bool get hasActiveFilters =>
      (_category != null && _category!.isNotEmpty) ||
      (_startDate != null && _startDate!.isNotEmpty) ||
      (_endDate != null && _endDate!.isNotEmpty);

  Future<void> loadInitial(String userId) async {
    _userId = userId;
    _items.clear();
    _lastDoc = null;
    _hasMore = true;
    _errorMessage = null;
    _loading = true;
    notifyListeners();

    try {
      final page = await _repository.fetchPage(
        userId: userId,
        category: _category,
        startDate: _startDate,
        endDate: _endDate,
      );
      _items.addAll(page.items);
      _lastDoc = page.lastDoc;
      _hasMore = page.hasMore;
    } catch (e) {
      _errorMessage = _friendlyError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_userId == null || _loading || _loadingMore || !_hasMore) return;

    _loadingMore = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final page = await _repository.fetchPage(
        userId: _userId!,
        category: _category,
        startDate: _startDate,
        endDate: _endDate,
        startAfter: _lastDoc,
      );
      _items.addAll(page.items);
      _lastDoc = page.lastDoc ?? _lastDoc;
      _hasMore = page.hasMore;
    } catch (e) {
      _errorMessage = _friendlyError(e);
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> applyFilters({
    String? category,
    String? startDate,
    String? endDate,
  }) async {
    _category = category;
    _startDate = startDate;
    _endDate = endDate;
    if (_userId == null) {
      notifyListeners();
      return;
    }
    await loadInitial(_userId!);
  }

  Future<void> clearFilters() async {
    await applyFilters(category: null, startDate: null, endDate: null);
  }

  Future<bool> remove(String docId) async {
    _errorMessage = null;
    try {
      await _repository.delete(docId);
      _items.removeWhere((t) => t.docId == docId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  String _friendlyError(Object e) {
    final text = e.toString();
    if (text.contains('failed-precondition') || text.contains('index')) {
      return 'É necessário criar um índice no Firestore. Confira o link no log.';
    }
    if (text.contains('permission-denied')) {
      return 'Sem permissão para acessar as transações.';
    }
    if (text.contains('REPLACE_ME') || text.contains('unavailable')) {
      return 'Firebase não configurado. Rode `flutterfire configure`.';
    }
    return 'Não foi possível carregar as transações. Tente novamente.';
  }
}
