import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_register/models/current_raw_material_model.dart';
import 'package:stock_register/models/raw_material_model.dart';
import 'package:stock_register/utils/exceptions.dart';

/// Updates the current stock of a raw material in a transaction.
/// Can handle addition, subtraction, and removal if quantity hits 0.
Future<CurrentRawMaterialModel?> updateCurrentRawMaterial({
  required Transaction txn,
  required RawMaterialModel material,
  required double qtyChange,
  required double priceChange,
  required CollectionReference<Map<String, dynamic>> currentCollection,
}) async {
  if (material.materialQuantity <= 0) {
    throw InvalidQuantityException('Material quantity must be greater than 0.');
  }
  if (material.totalPrice <= 0) {
    throw InvalidPriceException('Total price must be greater than 0.');
  }

  final currentQuery = await currentCollection
      .where('materialName', isEqualTo: material.materialName)
      .where('materialType', isEqualTo: material.materialType)
      .where('materialColor', isEqualTo: material.materialColor)
      .where('materialUnit', isEqualTo: material.materialUnit.name)
      .limit(1)
      .get();

  final current = currentQuery.docs.isNotEmpty
      ? CurrentRawMaterialModel.fromMap(
          currentQuery.docs.first.data(),
          currentQuery.docs.first.id,
        )
      : null;

  final currentRef = current != null
      ? currentCollection.doc(current.id)
      : currentCollection.doc();

  final newQty = (current?.availableQuantity ?? 0) + qtyChange;
  final newPrice = (current?.totalPrice ?? 0) + priceChange;

  if (newQty < 0) {
    throw InvalidQuantityException(
      'Resulting quantity cannot be negative for ${material.materialName}',
    );
  } else if (newQty == 0) {
    txn.delete(currentRef);
    return null;
  } else {
    final updated = CurrentRawMaterialModel(
      id: currentRef.id,
      materialName: material.materialName,
      materialType: material.materialType,
      materialColor: material.materialColor,
      materialUnit: material.materialUnit,
      availableQuantity: newQty,
      totalPrice: newPrice,
      unitPrice: newQty > 0 ? newPrice / newQty : 0,
    );
    txn.set(currentRef, updated.toMap());
    return updated;
  }
}
