import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_register/enum/unit_type.dart';

class RawMaterialModel {
  final String id;
  final String materialName;
  final UnitType materialUnit;
  final double materialQuantity;
  final String materialType;
  final String materialColor;
  final DateTime purchaseDate;
  final String materialSupplier;
  final double totalPrice;

  const RawMaterialModel({
    required this.id,
    required this.materialName,
    required this.materialUnit,
    required this.materialQuantity,
    required this.materialType,
    required this.materialColor,
    required this.purchaseDate,
    required this.materialSupplier,
    required this.totalPrice,
  });

  RawMaterialModel copyWith({
    String? id,
    String? materialName,
    UnitType? materialUnit,
    double? materialQuantity,
    String? materialType,
    String? materialColor,
    DateTime? purchaseDate,
    String? materialSupplier,
    double? totalPrice,
  }) {
    return RawMaterialModel(
      id: id ?? this.id,
      materialName: materialName ?? this.materialName,
      materialUnit: materialUnit ?? this.materialUnit,
      materialQuantity: materialQuantity ?? this.materialQuantity,
      materialType: materialType ?? this.materialType,
      materialColor: materialColor ?? this.materialColor,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      materialSupplier: materialSupplier ?? this.materialSupplier,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'materialName': materialName,
      'materialUnit': materialUnit.name,
      'materialQuantity': materialQuantity,
      'materialType': materialType,
      'materialColor': materialColor,
      'purchaseDate': Timestamp.fromDate(purchaseDate),
      'materialSupplier': materialSupplier,
      'totalPrice': totalPrice,
    };
  }

  factory RawMaterialModel.fromMap(Map<String, dynamic> map, String id) {
    return RawMaterialModel(
      id: id,
      materialName: (map['materialName'] ?? '').toString(),
      materialUnit: UnitType.values.byName((map['materialUnit'])),
      materialQuantity: (map['materialQuantity'] is num)
          ? (map['materialQuantity'] as num).toDouble()
          : double.tryParse(map['materialQuantity']?.toString() ?? '0') ?? 0,
      materialType: (map['materialType'] ?? '').toString(),
      materialColor: (map['materialColor'] ?? '').toString(),
      purchaseDate: (map['purchaseDate'] is Timestamp)
          ? (map['purchaseDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['purchaseDate']?.toString() ?? '') ??
                DateTime.now(),
      materialSupplier: (map['materialSupplier'] ?? '').toString(),
      totalPrice: (map['totalPrice'] is num)
          ? (map['totalPrice'] as num).toDouble()
          : double.tryParse(map['totalPrice']?.toString() ?? '0') ?? 0,
    );
  }
}
