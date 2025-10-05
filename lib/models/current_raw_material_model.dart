import 'package:stock_register/enum/unit_type.dart';

class CurrentRawMaterialModel {
  final String id;
  final String materialName;
  final String materialType;
  final String materialColor;
  final UnitType materialUnit;
  final double availableQuantity;
  final double totalPrice;
  final double unitPrice;

  const CurrentRawMaterialModel({
    required this.id,
    required this.materialName,
    required this.materialType,
    required this.materialColor,
    required this.materialUnit,
    required this.availableQuantity,
    required this.totalPrice,
    required this.unitPrice,
  });

  CurrentRawMaterialModel copyWith({
    String? id,
    String? materialName,
    String? materialType,
    String? materialColor,
    UnitType? materialUnit,
    double? availableQuantity,
    double? totalPrice,
    double? unitPrice,
  }) {
    return CurrentRawMaterialModel(
      id: id ?? this.id,
      materialName: materialName ?? this.materialName,
      materialType: materialType ?? this.materialType,
      materialColor: materialColor ?? this.materialColor,
      materialUnit: materialUnit ?? this.materialUnit,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      totalPrice: totalPrice ?? this.totalPrice,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'materialName': materialName,
      'materialType': materialType,
      'materialColor': materialColor,
      'materialUnit': materialUnit.name,
      'availableQuantity': availableQuantity,
      'totalPrice': totalPrice,
      'unitPrice': unitPrice,
    };
  }

  factory CurrentRawMaterialModel.fromMap(Map<String, dynamic> map, String id) {
    double parseDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '0') ?? 0.0;
    }

    return CurrentRawMaterialModel(
      id: id,
      materialName: (map['materialName'] ?? '').toString(),
      materialType: (map['materialType'] ?? '').toString(),
      materialColor: (map['materialColor'] ?? '').toString(),
      materialUnit: UnitType.values.byName((map['materialUnit'] ?? 'kg')),
      availableQuantity: parseDouble(map['availableQuantity']),
      totalPrice: parseDouble(map['totalPrice']),
      unitPrice: parseDouble(map['unitPrice']),
    );
  }
}
