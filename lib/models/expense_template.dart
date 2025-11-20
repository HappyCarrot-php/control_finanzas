class ExpenseTemplate {
  final int? id;
  final String name;
  final String icon;
  final String color;
  final double? defaultAmount;
  final int order;

  ExpenseTemplate({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.defaultAmount,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'defaultAmount': defaultAmount,
      'order': order,
    };
  }

  factory ExpenseTemplate.fromMap(Map<String, dynamic> map) {
    return ExpenseTemplate(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
      defaultAmount: map['defaultAmount'],
      order: map['order'],
    );
  }

  ExpenseTemplate copyWith({
    int? id,
    String? name,
    String? icon,
    String? color,
    double? defaultAmount,
    int? order,
  }) {
    return ExpenseTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      defaultAmount: defaultAmount ?? this.defaultAmount,
      order: order ?? this.order,
    );
  }
}
