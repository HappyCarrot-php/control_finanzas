class ShoppingCartItem {
  final int? id;
  final String productName;
  final double price;
  final int quantity;
  final DateTime dateAdded;
  final String? notes;

  ShoppingCartItem({
    this.id,
    required this.productName,
    required this.price,
    this.quantity = 1,
    DateTime? dateAdded,
    this.notes,
  }) : dateAdded = dateAdded ?? DateTime.now();

  double get total => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'dateAdded': dateAdded.toIso8601String(),
      'notes': notes,
    };
  }

  factory ShoppingCartItem.fromMap(Map<String, dynamic> map) {
    return ShoppingCartItem(
      id: map['id'],
      productName: map['productName'],
      price: map['price'],
      quantity: map['quantity'] ?? 1,
      dateAdded: DateTime.parse(map['dateAdded']),
      notes: map['notes'],
    );
  }

  ShoppingCartItem copyWith({
    int? id,
    String? productName,
    double? price,
    int? quantity,
    DateTime? dateAdded,
    String? notes,
  }) {
    return ShoppingCartItem(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      dateAdded: dateAdded ?? this.dateAdded,
      notes: notes ?? this.notes,
    );
  }
}
