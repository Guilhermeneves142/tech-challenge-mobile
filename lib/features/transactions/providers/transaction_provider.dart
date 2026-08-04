import 'package:flutter/foundation.dart';

import '../../auth/data/auth_api.dart';
import '../data/transaction_api.dart';
import '../models/transaction.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider({
    TransactionApi? api,
  }) : _api = api ?? TransactionApi();

  final TransactionApi _api;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;


  Future<bool> create(Transaction transaction) async {
     debugPrint('''
========== CRIANDO TRANSAÇÃO ==========
ID: ${transaction.id}
Descrição: ${transaction.description}
Valor: ${transaction.amount}
Categoria: ${transaction.category}
Tipo: ${transaction.type}
Data: ${transaction.date}
=======================================
''');

    return _run(() async {
    final created = await _api.create(transaction);

    debugPrint('''
========== TRANSAÇÃO CRIADA ==========
ID: ${created.id}
Descrição: ${created.description}
Valor: ${created.amount}
Categoria: ${created.category}
Tipo: ${created.type}
Data: ${created.date}
=====================================
''');

    return created;
  });
}


  Future<bool> update(Transaction transaction) async {
    debugPrint('''
========== ATUALIZANDO TRANSAÇÃO ==========
ID: ${transaction.id}
Descrição: ${transaction.description}
Valor: ${transaction.amount}
Categoria: ${transaction.category}
Tipo: ${transaction.type}
Data: ${transaction.date}
===========================================
''');
    return _run(() => _api.update(transaction));
  }


  Future<bool> _run(
    Future<Transaction> Function() action,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await action();
      return true;

    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;

    } catch (_) {
      _errorMessage = 'Não foi possível salvar a transação.';
      return false;

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void clearError() {
    if (_errorMessage == null) return;

    _errorMessage = null;
    notifyListeners();
  }
}