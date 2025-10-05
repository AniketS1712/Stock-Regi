import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stock_register/models/orders_model.dart';
import 'package:stock_register/service/order_service.dart';
import 'package:stock_register/service/stock_service.dart';

class OrdersProvider extends ChangeNotifier {
  final String userId;
  late final OrdersService _service;

  List<OrdersModel> orders = [];
  bool isLoading = false;
  String? errorMessage;

  StreamSubscription<List<OrdersModel>>? _ordersSub;

  OrdersProvider({required this.userId, required StockService stockService}) {
    _service = OrdersService(userId: userId, stockService: stockService);
    _subscribeOrders();
  }

  // 🔹 PRIVATE HELPERS
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  void _subscribeOrders() {
    _ordersSub?.cancel();
    _ordersSub = _service.getOrders().listen((list) {
      orders = list;
      notifyListeners();
    }, onError: (e) => _setError(e.toString()));
  }

  // 🔹 CRUD OPERATIONS
  Future<void> addOrder(OrdersModel order) async {
    await _performServiceAction(() => _service.addOrder(order));
  }

  Future<void> deleteOrder(OrdersModel order) async {
    await _performServiceAction(() => _service.deleteOrder(order));
  }

  // 🔹 GENERAL HELPER
  Future<void> _performServiceAction(Future<void> Function() action) async {
    _setLoading(true);
    try {
      await action();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // 🔹 REFRESH STREAM
  void refresh() => _subscribeOrders();

  // 🔹 CLEAR STATE
  void clear() {
    orders = [];
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    super.dispose();
  }
}
