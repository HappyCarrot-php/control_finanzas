class FinancialCategory {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final int order;

  FinancialCategory({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'order': order,
    };
  }

  factory FinancialCategory.fromMap(Map<String, dynamic> map) {
    return FinancialCategory(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
      order: map['order'],
    );
  }

  FinancialCategory copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    int? order,
  }) {
    return FinancialCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      order: order ?? this.order,
    );
  }
}
