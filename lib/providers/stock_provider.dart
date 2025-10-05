import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stock_register/models/stock_model.dart';
import 'package:stock_register/service/stock_service.dart';

class StockProvider extends ChangeNotifier {
  final String userId;
  late final StockService _service;

  List<StockModel> currentStock = [];
  List<StockModel> stockHistory = [];

  bool isLoading = false;
  String? errorMessage;

  StreamSubscription<List<StockModel>>? _currentSub;
  StreamSubscription<List<StockModel>>? _historySub;

  StockProvider({required this.userId}) {
    _service = StockService(userId: userId);
    _subscribeStreams();
  }

  // 🔹 PRIVATE HELPERS
  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? msg) {
    errorMessage = msg;
    notifyListeners();
  }

  void _subscribeStreams() {
    _currentSub?.cancel();
    _historySub?.cancel();

    _currentSub = _service.getCurrentStocks().listen((list) {
      currentStock = list;
      notifyListeners();
    }, onError: (e) => _setError(e.toString()));

    _historySub = _service.getStockHistory().listen((list) {
      stockHistory = list;
      notifyListeners();
    }, onError: (e) => _setError(e.toString()));
  }

  // 🔹 CRUD OPERATIONS
  Future<void> addStock(StockModel stock) async =>
      _performServiceAction(() => _service.addStock(stock));

  Future<void> deleteStock(String id) async =>
      _performServiceAction(() => _service.deleteStock(id));

  Future<void> adjustStockQuantity(String id, double quantityChange) async =>
      _performServiceAction(
        () => _service.adjustStockQuantity(
          id: id,
          quantityChange: quantityChange,
        ),
      );

  // 🔹 General helper for loading/error handling
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

  // 🔹 REFRESH STREAMS
  void refresh() => _subscribeStreams();

  // 🔹 CLEAR PROVIDER STATE
  void clear() {
    currentStock = [];
    stockHistory = [];
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _currentSub?.cancel();
    _historySub?.cancel();
    super.dispose();
  }
}
