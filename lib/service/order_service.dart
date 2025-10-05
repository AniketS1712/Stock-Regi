import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stock_register/models/orders_model.dart';
import 'package:stock_register/models/stock_model.dart';
import 'package:stock_register/service/stock_service.dart';

class OrdersService {
  final String userId;
  final StockService stockService;

  OrdersService({required this.userId, required this.stockService});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ordersCollection =>
      _firestore.collection('users/$userId/orders');

  /// 🔹 Add order and reduce stock
  Future<void> addOrder(OrdersModel order) async {
    try {
      await _firestore.runTransaction((txn) async {
        // 1️⃣ Fetch stock
        final StockModel? stock = await stockService.getStockById(
          order.stockId,
        );
        if (stock == null) throw Exception('Stock not found: ${order.stockId}');

        // 2️⃣ Adjust stock quantity
        if (order.quantity > stock.quantity) {
          throw Exception('Not enough stock available');
        }
        await stockService.adjustStockQuantity(
          id: stock.id,
          quantityChange: -order.quantity,
        );

        // 3️⃣ Save order with stock snapshot
        final orderRef = _ordersCollection.doc();
        final orderWithStockSnapshot = order.copyWith(
          id: orderRef.id,
          stockName: stock.name,
          stockColor: stock.color,
          stockSize: stock.size,
        );
        txn.set(orderRef, orderWithStockSnapshot.toMap());
      });
    } catch (e, st) {
      debugPrint('Error adding order: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  /// 🔹 Delete order and restore stock
  Future<void> deleteOrder(OrdersModel order) async {
    try {
      await _firestore.runTransaction((txn) async {
        // 1️⃣ Restore stock
        await stockService.adjustStockQuantity(
          id: order.stockId,
          quantityChange: order.quantity,
        );

        // 2️⃣ Delete order
        final orderRef = _ordersCollection.doc(order.id);
        txn.delete(orderRef);
      });
    } catch (e, st) {
      debugPrint('Error deleting order: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  /// 🔹 Stream orders
  Stream<List<OrdersModel>> getOrders() {
    return _ordersCollection
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrdersModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// 🔹 Fetch all orders once
  Future<List<OrdersModel>> fetchOrders() async {
    final snapshot = await _ordersCollection
        .orderBy('orderDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => OrdersModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
