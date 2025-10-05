import 'package:stock_register/enum/unit_type.dart';

class ProductionMaterialModel {
  final String materialName;
  final String materialType;
  final String materialColor;
  final double quantityUsed;
  final UnitType unit;

  ProductionMaterialModel({
    required this.materialName,
    required this.quantityUsed,
    required this.unit,
    String? materialType,
    String? materialColor,
  }) : materialType = (materialType == null || materialType.trim().isEmpty)
           ? '-'
           : materialType.trim(),
       materialColor = (materialColor == null || materialColor.trim().isEmpty)
           ? '-'
           : materialColor.trim();

  ProductionMaterialModel copyWith({
    String? materialName,
    String? materialType,
    String? materialColor,
    double? quantityUsed,
    UnitType? unit,
  }) {
    return ProductionMaterialModel(
      materialName: materialName ?? this.materialName,
      materialType: materialType ?? this.materialType,
      materialColor: materialColor ?? this.materialColor,
      quantityUsed: quantityUsed ?? this.quantityUsed,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toMap() => {
    'materialName': materialName,
    'materialType': materialType,
    'materialColor': materialColor,
    'quantityUsed': quantityUsed,
    'unit': unit.name,
  };

  factory ProductionMaterialModel.fromMap(Map<String, dynamic> map) {
    return ProductionMaterialModel(
      materialName: (map['materialName'] ?? '').toString(),
      materialType: (map['materialType'] ?? '-').toString(),
      materialColor: (map['materialColor'] ?? '-').toString(),
      quantityUsed: (map['quantityUsed'] as num?)?.toDouble() ?? 0.0,
      unit: UnitType.values.firstWhere(
        (e) => e.label == (map['unit'] ?? ''),
        orElse: () => UnitType.kg,
      ),
    );
  }

  String currentStockDocId() {
    final n = materialName.trim().toLowerCase();
    final t = materialType.trim().toLowerCase();
    final c = materialColor.trim().toLowerCase();
    final u = unit.name;
    return '$n|$t|$c|$u';
  }
}
