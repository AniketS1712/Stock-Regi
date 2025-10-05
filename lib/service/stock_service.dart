import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stock_register/models/stock_model.dart';

class StockService {
  final String userId;

  StockService({required this.userId});

  CollectionReference<Map<String, dynamic>> get _currentCollection =>
      FirebaseFirestore.instance.collection('users/$userId/stocks_current');

  CollectionReference<Map<String, dynamic>> get _historyCollection =>
      FirebaseFirestore.instance.collection('users/$userId/stocks_history');

  /// 🔹 Add or update stock
  Future<void> addStock(StockModel stock) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final query = await _currentCollection
            .where('name', isEqualTo: stock.name)
            .where('color', isEqualTo: stock.color)
            .where('size', isEqualTo: stock.size)
            .limit(1)
            .get();

        DocumentReference currentDoc;
        double newQuantity = stock.quantity;

        if (query.docs.isNotEmpty) {
          final doc = query.docs.first;
          currentDoc = doc.reference;
          final currentData = doc.data();
          newQuantity += (currentData['quantity'] ?? 0).toDouble();

          transaction.update(currentDoc, {
            'quantity': newQuantity,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          currentDoc = _currentCollection.doc();
          transaction.set(currentDoc, {
            ...stock.toMap(),
            'quantity': newQuantity,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }

        _recordHistory(transaction, currentDoc.id, stock.toMap());
      });
    } catch (e, st) {
      debugPrint('Error adding stock to current: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  /// 🔹 Delete stock
  Future<void> deleteStock(String id) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final currentDoc = _currentCollection.doc(id);
        final snapshot = await transaction.get(currentDoc);
        if (!snapshot.exists) throw Exception('Stock not found');

        transaction.delete(currentDoc);
      });
    } catch (e) {
      debugPrint('Error deleting stock: $e');
      rethrow;
    }
  }

  /// 🔹 Adjust stock quantity
  Future<void> adjustStockQuantity({
    required String id,
    required double quantityChange,
  }) async {
    if (quantityChange == 0) return;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final currentDoc = _currentCollection.doc(id);
        final snapshot = await transaction.get(currentDoc);
        if (!snapshot.exists) throw Exception('Stock not found');

        final currentData = snapshot.data()!;
        final newQty = (currentData['quantity'] ?? 0) + quantityChange;
        if (newQty < 0) throw Exception('Quantity cannot be negative');

        transaction.update(currentDoc, {
          'quantity': newQty,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        _recordHistory(transaction, id, currentData);
      });
    } catch (e) {
      debugPrint('Error adjusting stock: $e');
      rethrow;
    }
  }

  /// 🔹 Stream current stocks
  Stream<List<StockModel>> getCurrentStocks() {
    return _currentCollection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => StockModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  /// 🔹 Stream stock history
  Stream<List<StockModel>> getStockHistory() {
    return _historyCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StockModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// 🔹 Fetch current stocks once
  Future<List<StockModel>> fetchCurrentStocks() async {
    final snapshot = await _currentCollection.get();
    return snapshot.docs
        .map((doc) => StockModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// 🔹 Fetch stock history once
  Future<List<StockModel>> fetchStockHistory() async {
    final snapshot = await _historyCollection
        .orderBy('timestamp', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => StockModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// 🔹 Private helper to record history
  void _recordHistory(
    Transaction transaction,
    String currentId,
    Map<String, dynamic> data,
  ) {
    final historyDoc = _historyCollection.doc();
    transaction.set(historyDoc, {
      ...data,
      'id': currentId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> adjustStockQuantityByName({
    required String stockName,
    required double quantityChange,
  }) async {
    final stockDoc = await _currentCollection
        .where('name', isEqualTo: stockName)
        .limit(1)
        .get();

    if (stockDoc.docs.isEmpty) {
      throw Exception('Stock not found: $stockName');
    }

    final docRef = stockDoc.docs.first.reference;

    await docRef.update({'quantity': FieldValue.increment(quantityChange)});
  }

  Future<StockModel?> getStockById(String id) async {
    final doc = await _currentCollection.doc(id).get();
    if (!doc.exists) return null;
    return StockModel.fromMap(doc.data()!, doc.id);
  }
}
