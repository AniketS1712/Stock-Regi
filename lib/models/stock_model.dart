class StockModel {
  final String id;
  final String name;
  final String color;
  final String size;
  final double quantity;

  StockModel({
    required this.id,
    required this.name,
    required this.color,
    required this.size,
    required this.quantity,
  });

  StockModel copyWith({
    String? id,
    String? name,
    String? color,
    String? size,
    double? quantity,
  }) {
    return StockModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'color': color, 'size': size, 'quantity': quantity};
  }

  factory StockModel.fromMap(Map<String, dynamic> map, String id) {
    return StockModel(
      id: id,
      name: map['name'] ?? '',
      color: map['color'] ?? '',
      size: map['size'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
    );
  }
}
