import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_register/models/current_raw_material_model.dart';
import 'package:stock_register/utils/exceptions.dart';

/// 🔹 Deduct stock for a given material
Future<void> deductStock({
  required Transaction txn,
  required CollectionReference<Map<String, dynamic>> currentCollection,
  required String materialName,
  required String materialType,
  required String materialColor,
  required double qtyToDeduct,
}) async {
  if (qtyToDeduct <= 0) {
    throw InvalidQuantityException('Entered quantity must be greater than 0.');
  }

  // Get current stock for this material
  final query = await currentCollection
      .where('materialName', isEqualTo: materialName)
      .where('materialType', isEqualTo: materialType)
      .where('materialColor', isEqualTo: materialColor)
      .limit(1)
      .get();

  if (query.docs.isEmpty) {
    throw StockNotFoundException('No stock found for $materialName');
  }

  final doc = query.docs.first;
  final current = CurrentRawMaterialModel.fromMap(doc.data(), doc.id);

  if (current.availableQuantity < qtyToDeduct) {
    throw InvalidQuantityException(
      'Not enough stock of $materialName. '
      'Available: ${current.availableQuantity}, Required: $qtyToDeduct',
    );
  }

  final newQty = current.availableQuantity - qtyToDeduct;
  final newTotalPrice = current.unitPrice * newQty;

  final updatedStock = current.copyWith(
    availableQuantity: newQty,
    totalPrice: newTotalPrice,
  );

  if (newQty == 0) {
    txn.delete(doc.reference);
  } else {
    txn.set(doc.reference, updatedStock.toMap());
  }
}
