import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../transactions/models/transaction.dart';
import '../data/dashboard_repository.dart';
import '../models/dashboard_data.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({required this.userId, DashboardRepository? repository})
    : _repository = repository ?? DashboardRepository() {
    load();
  }

  final String userId;
  final DashboardRepository _repository;

  DashboardData _data = DashboardData.empty;
  bool _isLoading = true;
  String? _errorMessage;
  int _requestId = 0;

  DashboardData get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// `true` quando não há dados para mostrar
  bool get isEmpty =>
      !_isLoading &&
      _errorMessage == null &&
      _data.recent.isEmpty &&
      _data.summary.receitas == 0 &&
      _data.summary.despesas == 0;

  Future<void> load() async {
    final requestId = ++_requestId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repository.load(userId);
      if (requestId != _requestId) return;
      _data = data;
    } catch (error) {
      if (requestId != _requestId) return;
      _data = DashboardData.empty;
      _errorMessage = _friendlyError(error);
    } finally {
      if (requestId == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refresh() => load();

  /// Salva uma nova transação
  Future<bool> saveTransaction(TransactionModel transaction) async {
    try {
      await _repository.save(transaction);
    } catch (error) {
      _errorMessage = _friendlyError(error);
      notifyListeners();
      return false;
    }
    await load();
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
          return 'O painel precisa de um índice que ainda não existe no '
              'Firestore. Rode: firebase deploy --only firestore:indexes';
        case 'permission-denied':
          return 'Você não tem permissão para ver estes dados.';
        case 'unavailable':
          return 'Sem conexão com o servidor. Verifique a internet.';
      }
    }
    return 'Não foi possível carregar o painel. Tente novamente.';
  }
}
