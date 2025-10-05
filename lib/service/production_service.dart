import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stock_register/models/production_model.dart';
import 'package:stock_register/service/raw_material_service.dart';
import 'package:stock_register/utils/deduct_stock.dart';
import 'package:stock_register/utils/exceptions.dart';

class ProductionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final RawMaterialService _rawMaterialService = RawMaterialService();

  /// 🔹 User-specific collection path
  CollectionReference<Map<String, dynamic>> _collection(String userId) =>
      _db.collection('users').doc(userId).collection('productions');

  /// 🔹 Add new production (deduct stock atomically)
  Future<void> addProduction(String userId, ProductionModel production) async {
    try {
      await _db.runTransaction((txn) async {
        // Deduct stock for all materials
        for (final material in production.materialsUsed) {
          await deductStock(
            txn: txn,
            currentCollection: _rawMaterialService.currentCollection(userId),
            materialName: material.materialName,
            materialType: material.materialType,
            materialColor: material.materialColor,
            qtyToDeduct: material.quantityUsed,
          );
        }

        // Save production
        final docRef = _collection(userId).doc();
        txn.set(docRef, production.toMap());
      });
    } on StockNotFoundException catch (e) {
      debugPrint('⚠️ Stock not found: ${e.message}');
      throw Exception("Stock not found: ${e.message}");
    } on InvalidQuantityException catch (e) {
      debugPrint('⚠️ Invalid quantity: ${e.message}');
      throw Exception("Invalid quantity: ${e.message}");
    } catch (e, st) {
      debugPrint('🔥 Unexpected error adding production: $e\n$st');
      throw Exception(
        "Something went wrong while adding production. Please try again.",
      );
    }
  }

  /// 🔹 Update production (deduct stock if status changes to in-progress)
  Future<void> updateProduction(
    String userId,
    ProductionModel production,
  ) async {
    try {
      final docRef = _collection(userId).doc(production.id);
      final snapshot = await docRef.get();
      if (!snapshot.exists) throw Exception('Production not found');

      final previousStatus = snapshot['status'] ?? '';

      await docRef.update(production.toMap());

      if (previousStatus != 'in-progress' &&
          production.status == 'in-progress') {
        await _deductStockForProduction(userId, production);
      }
    } catch (e, st) {
      debugPrint('🔥 Error updating production: $e\n$st');
      rethrow;
    }
  }

  /// 🔹 Delete production
  Future<void> deleteProduction(String userId, String id) async {
    try {
      await _collection(userId).doc(id).delete();
    } catch (e, st) {
      debugPrint('🔥 Error deleting production: $e\n$st');
      rethrow;
    }
  }

  /// 🔹 Stream of productions (real-time)
  Stream<List<ProductionModel>> getProductions(String userId) {
    return _collection(userId)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductionModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// 🔹 Fetch productions once
  Future<List<ProductionModel>> fetchProductions(String userId) async {
    try {
      final snapshot = await _collection(
        userId,
      ).orderBy('startDate', descending: true).get();
      return snapshot.docs
          .map((doc) => ProductionModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e, st) {
      debugPrint('🔥 Error fetching productions: $e\n$st');
      rethrow;
    }
  }

  /// 🔹 Helper: Deduct stock for a production
  Future<void> _deductStockForProduction(
    String userId,
    ProductionModel production,
  ) async {
    await _db.runTransaction((txn) async {
      for (final material in production.materialsUsed) {
        await deductStock(
          txn: txn,
          currentCollection: _rawMaterialService.currentCollection(userId),
          materialName: material.materialName,
          materialType: material.materialType,
          materialColor: material.materialColor,
          qtyToDeduct: material.quantityUsed,
        );
      }
    });
  }
}
