class Subcategory {
  final int? id;
  final int categoryId;
  final String name;
  final double balance;
  final String? icon;
  final String? color;
  final int order;
  final DateTime createdDate;

  Subcategory({
    this.id,
    required this.categoryId,
    required this.name,
    this.balance = 0.0,
    this.icon,
    this.color,
    this.order = 0,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'balance': balance,
      'icon': icon,
      'color': color,
      'order': order,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory Subcategory.fromMap(Map<String, dynamic> map) {
    return Subcategory(
      id: map['id'] as int?,
      categoryId: map['categoryId'] as int,
      name: map['name'] as String,
      balance: map['balance'] as double? ?? 0.0,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      order: map['order'] as int? ?? 0,
      createdDate: DateTime.parse(map['createdDate'] as String),
    );
  }

  Subcategory copyWith({
    int? id,
    int? categoryId,
    String? name,
    double? balance,
    String? icon,
    String? color,
    int? order,
    DateTime? createdDate,
  }) {
    return Subcategory(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      order: order ?? this.order,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}
