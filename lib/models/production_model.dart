import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_register/models/production_material_model.dart';

class ProductionModel {
  final String id;
  final String batchNumber;
  final DateTime startDate;
  final DateTime? endDate;
  final List<ProductionMaterialModel> materialsUsed;
  final String status;

  ProductionModel({
    required this.id,
    required this.batchNumber,
    required this.startDate,
    this.endDate,
    required this.materialsUsed,
    this.status = 'in-progress',
  });

  ProductionModel copyWith({
    String? id,
    String? batchNumber,
    DateTime? startDate,
    DateTime? endDate,
    List<ProductionMaterialModel>? materialsUsed,
    String? status,
  }) {
    return ProductionModel(
      id: id ?? this.id,
      batchNumber: batchNumber ?? this.batchNumber,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      materialsUsed: materialsUsed != null
          ? List.from(materialsUsed)
          : List.from(this.materialsUsed),
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'batchNumber': batchNumber,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'materialsUsed': materialsUsed.map((m) => m.toMap()).toList(),
      'status': status,
    };
  }

  factory ProductionModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductionModel(
      id: id,
      batchNumber: map['batchNumber'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: map['endDate'] != null
          ? (map['endDate'] as Timestamp).toDate()
          : null,
      materialsUsed:
          (map['materialsUsed'] as List<dynamic>?)
              ?.map((m) => ProductionMaterialModel.fromMap(m))
              .toList() ??
          [],
      status: map['status'] ?? 'in-progress',
    );
  }
}
