class FinancialTransaction {
  final int? id;
  final int categoryId;
  final int? subcategoryId; // Nullable para compatibilidad con transacciones antiguas
  final double amount;
  final String description;
  final DateTime date;
  final String type; // 'income' o 'expense'

  FinancialTransaction({
    this.id,
    required this.categoryId,
    this.subcategoryId,
    required this.amount,
    required this.description,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory FinancialTransaction.fromMap(Map<String, dynamic> map) {
    return FinancialTransaction(
      id: map['id'],
      categoryId: map['categoryId'],
      subcategoryId: map['subcategoryId'],
      amount: map['amount'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      type: map['type'],
    );
  }

  FinancialTransaction copyWith({
    int? id,
    int? categoryId,
    int? subcategoryId,
    double? amount,
    String? description,
    DateTime? date,
    String? type,
  }) {
    return FinancialTransaction(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }
}
