import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_register/enum/unit_type.dart';

class OrdersModel {
  final String id;
  final String buyerName;
  final DateTime orderDate;
  final double quantity;
  final UnitType unit;
  final String stockId;
  final String stockName;
  final String stockColor;
  final String stockSize;

  OrdersModel({
    required this.id,
    required this.buyerName,
    required this.orderDate,
    required this.quantity,
    required this.unit,
    required this.stockId,
    required this.stockName,
    required this.stockColor,
    required this.stockSize,
  });

  OrdersModel copyWith({
    String? id,
    String? buyerName,
    DateTime? orderDate,
    double? quantity,
    UnitType? unit,
    String? stockId,
    String? stockName,
    String? stockColor,
    String? stockSize,
  }) {
    return OrdersModel(
      id: id ?? this.id,
      buyerName: buyerName ?? this.buyerName,
      orderDate: orderDate ?? this.orderDate,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      stockId: stockId ?? this.stockId,
      stockName: stockName ?? this.stockName,
      stockColor: stockColor ?? this.stockColor,
      stockSize: stockSize ?? this.stockSize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerName': buyerName,
      'orderDate': Timestamp.fromDate(orderDate),
      'quantity': quantity,
      'unit': unit.label,
      'stockId': stockId,
      'stockName': stockName,
      'stockColor': stockColor,
      'stockSize': stockSize,
    };
  }

  factory OrdersModel.fromMap(Map<String, dynamic> map, String id) {
    final timestamp = map['orderDate'] as Timestamp?;
    return OrdersModel(
      id: id,
      buyerName: map['buyerName'] ?? '',
      orderDate: timestamp?.toDate() ?? DateTime.now(),
      quantity: (map['quantity'] ?? 0).toDouble(),
      unit: UnitType.values.firstWhere(
        (e) => e.label == map['unit'],
        orElse: () => UnitType.kg,
      ),
      stockId: map['stockId'] ?? '',
      stockName: map['stockName'] ?? '',
      stockColor: map['stockColor'] ?? '',
      stockSize: map['stockSize'] ?? '',
    );
  }
}
