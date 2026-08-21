import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/transactions_repository.dart';
import '../models/transaction.dart';
import '../models/transaction_filters.dart';
import 'dart:io';
import '../data/receipt_img_storage_service.dart';

class TransactionsProvider extends ChangeNotifier {
  TransactionsProvider({
    required this.userId,
    TransactionsRepository? repository,
  }) : _repository = repository ?? TransactionsRepository() {
    refresh();
  }

  final String userId;
  final TransactionsRepository _repository;

  static const Duration searchDebounce = Duration(milliseconds: 400);

  List<TransactionModel> _items = const [];
  TransactionsSummary _summary = TransactionsSummary.empty;
  TransactionFilters _filters = const TransactionFilters();
  DocumentSnapshot<Map<String, dynamic>>? _cursor;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String? _errorMessage;

  Timer? _debounce;

  int _requestId = 0;

  List<TransactionModel> get items => List.unmodifiable(_items);
  TransactionsSummary get summary => _summary;
  TransactionFilters get filters => _filters;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => !_isLoading && _items.isEmpty;

  void searchChanged(String term) {
    _debounce?.cancel();
    _debounce = Timer(searchDebounce, () {
      _applyFilters(_filters.copyWith(search: term));
    });
  }

  void periodChanged(DateRange? range) {
    _applyFilters(
      _filters.copyWith(range: range, clearRange: range == null),
    );
  }

  void typeChanged(TransactionType? type) {
    _applyFilters(_filters.copyWith(type: type, clearType: type == null));
  }

  void clearFilters() {
    _debounce?.cancel();
    _applyFilters(const TransactionFilters());
  }

  void _applyFilters(TransactionFilters next) {
    if (next == _filters) return;
    _filters = next;
    refresh();
  }

  Future<void> refresh() async {
    final requestId = ++_requestId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final pageFuture = _repository.fetchPage(
        userId: userId,
        filters: _filters,
      );
      final summaryFuture = _repository.fetchSummary(
        userId: userId,
        filters: _filters,
      );

      final page = await pageFuture;
      final summary = await summaryFuture;
      if (requestId != _requestId) return; // filtro mudou no meio: descarta

      _items = page.items;
      _cursor = page.cursor;
      _hasMore = page.hasMore;
      _summary = summary;
    } catch (error) {
      if (requestId != _requestId) return;
      _items = const [];
      _cursor = null;
      _hasMore = false;
      _summary = TransactionsSummary.empty;
      _errorMessage = _friendlyError(error);
    } finally {
      if (requestId == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore || _cursor == null) return;

    final requestId = _requestId;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final page = await _repository.fetchPage(
        userId: userId,
        filters: _filters,
        startAfter: _cursor,
      );
      if (requestId != _requestId) return;

      _items = [..._items, ...page.items];
      _cursor = page.cursor ?? _cursor;
      _hasMore = page.hasMore;
    } catch (error) {
      if (requestId != _requestId) return;
      _hasMore = false;
      _errorMessage = _friendlyError(error);
    } finally {
      if (requestId == _requestId) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  final ReceiptStorageService _receiptStorage = ReceiptStorageService();

  Future<bool> save(
    TransactionModel transaction, {
    File? receiptFile,
  }) async {
    try {
      final savedTransaction = await _repository.save(transaction);

      if (receiptFile != null) {
        final receiptUrl = await _receiptStorage.upload(
          userId: userId,
          transactionId: savedTransaction.id,
          file: receiptFile,
        );

        await _repository.updateReceiptUrl(
          savedTransaction.id,
          receiptUrl,
        );
      }

      await refresh();

      return true;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(TransactionModel transaction) async {
    try {
      await _repository.delete(transaction.id);
    } catch (error) {
      _errorMessage = _friendlyError(error);
      notifyListeners();
      return false;
    }

    _items = _items.where((item) => item.id != transaction.id).toList();
    notifyListeners();

    try {
      _summary = await _repository.fetchSummary(
        userId: userId,
        filters: _filters,
      );
      notifyListeners();
    } catch (_) {
    }
    return true;
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  String _friendlyError(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'failed-precondition':
          return 'Esta combinação de filtros precisa de um índice que ainda '
              'não existe no Firestore. Rode: firebase deploy --only '
              'firestore:indexes';
        case 'permission-denied':
          return 'Você não tem permissão para ver estas transações.';
        case 'unavailable':
          return 'Sem conexão com o servidor. Verifique a internet.';
      }
    }
    return 'Não foi possível carregar as transações. Tente novamente.';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
