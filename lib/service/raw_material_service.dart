import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stock_register/models/raw_material_model.dart';
import 'package:stock_register/models/current_raw_material_model.dart';
import 'package:stock_register/utils/exceptions.dart';
import 'package:stock_register/utils/update_current_raw_material.dart';

class RawMaterialService {
  /// 🔹 Collections
  CollectionReference<Map<String, dynamic>> _purchaseCollection(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('raw_materials_purchases');

  CollectionReference<Map<String, dynamic>> _currentCollection(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('raw_materials_current');

  CollectionReference<Map<String, dynamic>> currentCollection(String uid) =>
      _currentCollection(uid);

  /// 🔹 Add a new raw material purchase
  Future<void> addRawMaterial(String uid, RawMaterialModel material) async {
    if (material.materialQuantity <= 0) {
      throw InvalidQuantityException(
        'Material quantity must be greater than 0.',
      );
    }
    if (material.totalPrice <= 0) {
      throw InvalidPriceException('Total price must be greater than 0.');
    }

    try {
      await FirebaseFirestore.instance.runTransaction((txn) async {
        // Save purchase
        final purchaseRef = _purchaseCollection(uid).doc();
        txn.set(purchaseRef, material.toMap());

        // Update current stock
        await updateCurrentRawMaterial(
          txn: txn,
          material: material,
          qtyChange: material.materialQuantity,
          priceChange: material.totalPrice,
          currentCollection: _currentCollection(uid),
        );
      });
    } catch (e) {
      debugPrint('Error adding raw material: $e');
      throw Exception('Failed to add raw material: $e');
    }
  }

  /// 🔹 Update a purchase & adjust stock
  Future<void> updateRawMaterial(String uid, RawMaterialModel updated) async {
    if (updated.materialQuantity <= 0) {
      throw InvalidQuantityException(
        'Material quantity must be greater than 0.',
      );
    }
    if (updated.totalPrice <= 0) {
      throw InvalidPriceException('Total price must be greater than 0.');
    }

    try {
      await FirebaseFirestore.instance.runTransaction((txn) async {
        final purchaseRef = _purchaseCollection(uid).doc(updated.id);
        final oldSnap = await txn.get(purchaseRef);

        if (!oldSnap.exists) throw StockNotFoundException('Purchase not found');

        final old = RawMaterialModel.fromMap(oldSnap.data()!, oldSnap.id);

        // Fetch current stock
        final currentQuery = await _currentCollection(uid)
            .where('materialName', isEqualTo: old.materialName)
            .where('materialType', isEqualTo: old.materialType)
            .where('materialColor', isEqualTo: old.materialColor)
            .limit(1)
            .get();

        if (currentQuery.docs.isEmpty) {
          throw StockNotFoundException('Current stock not found');
        }

        final currentDoc = currentQuery.docs.first;
        final current = CurrentRawMaterialModel.fromMap(
          currentDoc.data(),
          currentDoc.id,
        );

        // Check unit consistency BEFORE updating purchase
        if (current.materialUnit != updated.materialUnit) {
          throw UnitMismatchException(
            'Cannot update: unit mismatch for ${updated.materialName}',
          );
        }

        // Calculate differences
        final qtyDiff = updated.materialQuantity - old.materialQuantity;
        final priceDiff = updated.totalPrice - old.totalPrice;

        final newQty = current.availableQuantity + qtyDiff;
        final newPrice = current.totalPrice + priceDiff;

        if (newQty < 0) {
          throw InvalidQuantityException(
            'Resulting quantity cannot be negative for ${updated.materialName}',
          );
        }

        // Update purchase doc
        txn.set(purchaseRef, updated.toMap());

        // Update current stock
        final updatedStock = current.copyWith(
          availableQuantity: newQty,
          totalPrice: newPrice,
          unitPrice: newQty > 0 ? newPrice / newQty : 0,
        );

        if (updatedStock.availableQuantity == 0) {
          txn.delete(currentDoc.reference);
        } else {
          txn.set(currentDoc.reference, updatedStock.toMap());
        }
      });
    } catch (e) {
      debugPrint('Error updating raw material: $e');
      throw Exception('Failed to update raw material: $e');
    }
  }

  /// 🔹 Delete a purchase & adjust stock
  Future<void> deleteRawMaterial(String uid, String id) async {
    try {
      await FirebaseFirestore.instance.runTransaction((txn) async {
        final purchaseRef = _purchaseCollection(uid).doc(id);
        final snap = await txn.get(purchaseRef);

        if (!snap.exists) throw StockNotFoundException('Purchase not found');

        final old = RawMaterialModel.fromMap(snap.data()!, snap.id);

        txn.delete(purchaseRef);

        await updateCurrentRawMaterial(
          txn: txn,
          material: old,
          qtyChange: -old.materialQuantity,
          priceChange: -old.totalPrice,
          currentCollection: _currentCollection(uid),
        );
      });
    } catch (e) {
      debugPrint('Error deleting raw material: $e');
      throw Exception('Failed to delete raw material: $e');
    }
  }

  /// 🔹 Stream of all purchases for a user
  Stream<List<RawMaterialModel>> getRawMaterials(String uid) {
    return _purchaseCollection(uid).snapshots().map(
      (snap) => snap.docs
          .map((d) => RawMaterialModel.fromMap(d.data(), d.id))
          .toList(),
    );
  }

  /// 🔹 Stream of current stock for a user
  Stream<List<CurrentRawMaterialModel>> getCurrentRawMaterialStream(
    String uid,
  ) {
    return _currentCollection(uid).snapshots().map(
      (snap) => snap.docs
          .map((d) => CurrentRawMaterialModel.fromMap(d.data(), d.id))
          .toList(),
    );
  }
}
