import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/formatters.dart';

/// Tipo da transação — define o sinal do valor e alimenta os cards de resumo.
///
/// Só existem dois: "Transferência", "Renda" etc. são *categorias*. Assim
/// Saldo = Receitas − Despesas fecha sempre.
enum TransactionType {
  receita('Receita'),
  despesa('Despesa');

  const TransactionType(this.label);

  final String label;

  static TransactionType fromName(String? name) => values.firstWhere(
    (type) => type.name == name,
    orElse: () => TransactionType.despesa,
  );
}

/// Categoria da transação (coluna "CATEGORIA" da listagem).
enum TransactionCategory {
  alimentacao('Alimentação'),
  renda('Renda'),
  transporte('Transporte'),
  moradia('Moradia'),
  educacao('Educação'),
  saude('Saúde'),
  lazer('Lazer'),
  transferencia('Transferência'),
  outros('Outros');

  const TransactionCategory(this.label);

  final String label;

  static TransactionCategory fromName(String? name) => values.firstWhere(
    (category) => category.name == name,
    orElse: () => TransactionCategory.outros,
  );
}

/// Uma transação do usuário (documento da coleção `transactions`).
///
/// [amount] é sempre positivo; quem manda no sinal é o [type]. Guardar o valor
/// absoluto simplifica as agregações (somar receitas e despesas separadamente).
class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.userId,
    required this.description,
    required this.category,
    required this.type,
    required this.amount,
    required this.date,
    this.receiptUrl,
  });

  /// `id` vazio = transação ainda não salva (o repositório faz `add`).
  final String id;
  final String userId;
  final String description;
  final TransactionCategory category;
  final TransactionType type;

  /// Sempre positivo (o sinal vem de [type]).
  final double amount;
  final DateTime date;

  /// Recibo no Firebase Storage — preenchido pela tela de add/editar.
  final String? receiptUrl;

  bool get isNew => id.isEmpty;

  /// Valor com sinal, para exibição e para somar saldo.
  double get signedAmount =>
      type == TransactionType.receita ? amount : -amount;

  factory TransactionModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: TransactionCategory.fromName(data['category'] as String?),
      type: TransactionType.fromName(data['type'] as String?),
      amount: ((data['amount'] as num?)?.toDouble() ?? 0).abs(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      receiptUrl: data['receiptUrl'] as String?,
    );
  }

  /// `descriptionLower` é o campo indexado que viabiliza a busca por prefixo
  /// no Firestore (ver [TransactionsRepository]).
  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'description': description.trim(),
    'descriptionLower': normalizeForSearch(description),
    'category': category.name,
    'type': type.name,
    'amount': amount.abs(),
    'date': Timestamp.fromDate(date),
    if (receiptUrl != null) 'receiptUrl': receiptUrl,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  TransactionModel copyWith({
    String? id,
    String? description,
    TransactionCategory? category,
    TransactionType? type,
    double? amount,
    DateTime? date,
    String? receiptUrl,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
    );
  }
}
