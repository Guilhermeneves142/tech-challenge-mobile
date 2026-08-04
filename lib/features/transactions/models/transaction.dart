class Transaction {
  final int? id;
  final String description;
  final double amount;
  final String type;
  final String category;
  final String date;

  const Transaction({
    this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as int?,
        description: json['description'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: json['type'] as String,
        category: json['category'] as String,
        date: json['date'] as String,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'description': description,
        'amount': amount,
        'type': type,
        'category': category,
        'date': date,
      };
}