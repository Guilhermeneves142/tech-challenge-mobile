import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/app_config.dart';
import '../../auth/data/auth_api.dart';
import '../models/transaction.dart';

/// Responsável por fazer as chamadas HTTP e transformar as respostas em objetos Dart.
class TransactionApi {
  final http.Client _client;

  TransactionApi({http.Client? client}) : _client = client ?? http.Client();

  static const _headers = {'Content-Type': 'application/json'};

  Future<Transaction> create(Transaction transaction) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/transactions');

    final res = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode(transaction.toJson()),
    );

    final data = res.body.isNotEmpty
        ? jsonDecode(res.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (res.statusCode >= 200 && res.statusCode < 300) {
      debugPrint('========== RESPONSE CREATE ==========');
      debugPrint(res.body);
      debugPrint('====================================');

      return Transaction.fromJson(data);
    }

    final message = (data['message'] as String?) ?? 'Erro inesperado.';
    throw ApiException(message, res.statusCode);
  }

  Future<Transaction> update(Transaction transaction) async {
    final uri = Uri.parse(
      '${AppConfig.apiBaseUrl}/transactions/${transaction.id}',
    );

    final res = await _client.patch(
      uri,
      headers: _headers,
      body: jsonEncode(transaction.toJson()),
    );

    final data = res.body.isNotEmpty
        ? jsonDecode(res.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return Transaction.fromJson(data);
    }

    final message = (data['message'] as String?) ?? 'Erro inesperado.';
    throw ApiException(message, res.statusCode);
  }
}
