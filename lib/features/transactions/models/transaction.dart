import 'package:cloud_firestore/cloud_firestore.dart';

/// Transação financeira — espelha o contrato do web + `userId` no Firestore.
class TransactionModel {
  const TransactionModel({
    required this.docId,
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
    required this.dateLabel,
    required this.type,
    required this.userId,
  });

  /// ID do documento Firestore (usado em delete/update).
  final String docId;

  /// ID numérico do contrato web.
  final int id;
  final String description;
  final String category;
  final double amount;

  /// Data ISO `yyyy-MM-dd` (ordenável no Firestore).
  final String date;
  final String dateLabel;

  /// Ex.: `income` / `expense` (ou equivalentes do web).
  final String type;
  final String userId;

  bool get isIncome {
    final t = type.trim().toLowerCase();
    return t == 'income' || t == 'receita' || t == 'entrada';
  }

  bool get isExpense => !isIncome;

  factory TransactionModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return TransactionModel(
      docId: doc.id,
      id: _asInt(data['id']),
      description: (data['description'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      amount: _asDouble(data['amount']),
      date: (data['date'] as String?) ?? '',
      dateLabel: (data['dateLabel'] as String?) ?? '',
      type: (data['type'] as String?) ?? '',
      userId: (data['userId'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'description': description,
        'category': category,
        'amount': amount,
        'date': date,
        'dateLabel': dateLabel,
        'type': type,
        'userId': userId,
      };

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
