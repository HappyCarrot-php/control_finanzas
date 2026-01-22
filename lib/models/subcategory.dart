class Subcategory {
  final int? id;
  final int categoryId;
  final String name;
  final double balance;
  final String? icon;
  final String? color;
  final int order;
  final DateTime createdDate;
  final bool isInterestBearing;
  final double interestRate;
  final DateTime? lastInterestApplied;

  Subcategory({
    this.id,
    required this.categoryId,
    required this.name,
    this.balance = 0.0,
    this.icon,
    this.color,
    this.order = 0,
    DateTime? createdDate,
    this.isInterestBearing = false,
    this.interestRate = 0.0,
    this.lastInterestApplied,
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
      'isInterestBearing': isInterestBearing ? 1 : 0,
      'interestRate': interestRate,
      'lastInterestApplied': lastInterestApplied?.toIso8601String(),
    };
  }

  factory Subcategory.fromMap(Map<String, dynamic> map) {
    final dynamic lastInterestValue = map['lastInterestApplied'];
    return Subcategory(
      id: map['id'] as int?,
      categoryId: map['categoryId'] as int,
      name: map['name'] as String,
      balance: map['balance'] as double? ?? 0.0,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      order: map['order'] as int? ?? 0,
      createdDate: DateTime.parse(map['createdDate'] as String),
      isInterestBearing: _parseBool(map['isInterestBearing']),
      interestRate: _parseDouble(map['interestRate']),
      lastInterestApplied: lastInterestValue is String && lastInterestValue.isNotEmpty
          ? DateTime.tryParse(lastInterestValue)
          : null,
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
    bool? isInterestBearing,
    double? interestRate,
    DateTime? lastInterestApplied,
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
      isInterestBearing: isInterestBearing ?? this.isInterestBearing,
      interestRate: interestRate ?? this.interestRate,
      lastInterestApplied: lastInterestApplied ?? this.lastInterestApplied,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is int) {
      return value == 1;
    }
    if (value is bool) {
      return value;
    }
    return false;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
